  per-server-deploy:
    # Run this job only if the environment is prod (passed in from caller)
    if: ${{ inputs.ENV_NAME == 'prod' }}

    # Required: every job must specify runs-on (use your own runner group if needed)
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false          # Don’t stop all matrix jobs if one fails
      max-parallel: 1           # Run servers sequentially to avoid Safeguard overlap
      matrix:
        # Matrix expands into one run per server.
        # vars.SERVER_NAME can be a single server string or a JSON array of servers.
        server: ${{ fromJSON(startsWith(vars.SERVER_NAME, '[') && vars.SERVER_NAME || format('["{0}"]', vars.SERVER_NAME)) }}

    steps:
      # Step 1: Clean up server string (removes extra spaces if present)
      - name: Normalize server value
        id: normalize
        shell: bash
        run: |
          s='${{ matrix.server }}'
          echo "server=$(echo "$s" | xargs)" >> "$GITHUB_OUTPUT"

      # Step 2: Pull root password for this server from Safeguard
      # Each matrix run executes this separately, so no overlap
      - name: Retrieve credentials from Safeguard (root) for ${{ steps.normalize.outputs.server }}
        id: sg
        uses: charlesschwab/safeguard-secrets-action@v4
        with:
          certificate: "${{ secrets.SAFEGUARD_CERTIFICATE }}"                # Safeguard auth cert
          certificate-private-key-phrase: "${{ secrets.SAFEGUARD_PRIVATE_KEY_PHRASE }}"
          account-name: root                                                 # always root
          account-system: "${{ steps.normalize.outputs.server }}"            # target server
          safeguard-url: "${{ vars.SAFEGUARD_URL }}"                         # Safeguard endpoint
          environment-variable-name: SAFEGUARD_SECRET                        # export as env var
          set-environment-variable: true

      # Step 3: Copy files to server via scp
      - name: SCP files to ${{ steps.normalize.outputs.server }}
        shell: bash
        env:
          SERVER: ${{ steps.normalize.outputs.server }}
        run: |
          set -euo pipefail

          # Retry helper: retry <tries> <sleep> <cmd...>
          retry() { local t="$1" s="$2"; shift 2; local n=1; until "$@"; do
            (( n >= t )) && return 1; sleep "$s"; n=$((n+1))
          done; }

          DEST_PATH="/${{ vars.DESTINATION_PATH }}/${{ vars.PATH_TO_FILES }}"
          SRC_PATH="${{ vars.PATH_TO_FILES }}"

          echo ">>> Copying files to $SERVER:$DEST_PATH"
          retry 4 10 \
          sshpass -p "${SAFEGUARD_SECRET}" \
          scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r \
            "$SRC_PATH" \
            root@"$SERVER":"$DEST_PATH"

      # Step 4: Configure Python virtual environment on server
      - name: Configure virtual env on ${{ steps.normalize.outputs.server }}
        shell: bash
        env:
          SERVER: ${{ steps.normalize.outputs.server }}
        run: |
          set -euo pipefail

          # Retry helper again for SSH
          retry() { local t="$1" s="$2"; shift 2; local n=1; until "$@"; do
            (( n >= t )) && return 1; sleep "$s"; n=$((n+1))
          done; }

          DEST_PATH="/${{ vars.DESTINATION_PATH }}/${{ vars.PATH_TO_FILES }}"
          WPC_INDEX="https://${{ secrets.WPC_PRO_API_USER }}:${{ secrets.WPC_PRO_API_SECRET }}@${{ secrets.WPC_PRO_HOST }}/pypi/simple"
          SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=1 -o ConnectTimeout=10"

          echo ">>> Configuring env on $SERVER"
          retry 4 10 \
          sshpass -p "${SAFEGUARD_SECRET}" \
          ssh $SSH_OPTS root@"$SERVER" "
            set -euo pipefail
            cd '${DEST_PATH}'

            # Create and activate virtual environment
            python -m venv venv
            . venv/bin/activate

            # Upgrade pip
            python -m pip install --upgrade pip

            # Install required Python packages from WPC index
            pip install --no-cache-dir setuptools==75.8.0 wheel==0.45.1 build==1.2.2.post1 bump2version==1.0.1 twine==5.1.1 -v -q -i '${WPC_INDEX}'
            pip install -r requirements/requirements.txt -v -q -i '${WPC_INDEX}'

            # Fix permissions on the destination path
            chmod -R 775 '${DEST_PATH}'
            chown -R '${{ vars.SERVICE_ACNT }}' '${DEST_PATH}'
          "
