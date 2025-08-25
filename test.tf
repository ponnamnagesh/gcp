  configure-multiple-server-environment:
    if: ${{ inputs.ENV_NAME == 'prod' }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        server: ${{ fromJSON(startsWith(vars.SERVER_NAME, '[') && vars.SERVER_NAME || format('["{0}"]', vars.SERVER_NAME)) }}



    steps:
      - name: Normalize server value
        id: normalize
        shell: bash
        run: |
          s='${{ matrix.server }}'
          echo "server=$(echo "$s" | xargs)" >> "$GITHUB_OUTPUT"

      - name: Retrieve credentials from Safeguard (root) for ${{ steps.normalize.outputs.server }}
        uses: charlesschwab/safeguard-secrets-action@v4
        with:
          certificate: "${{ secrets.SAFEGUARD_CERTIFICATE }}"
          certificate-private-key-phrase: "${{ secrets.SAFEGUARD_PRIVATE_KEY_PHRASE }}"
          account-name: root
          account-system: "${{ steps.normalize.outputs.server }}"
          github-token: "${{ steps.generate_token.outputs.token }}"
          safeguard-url: "${{ vars.SAFEGUARD_URL }}"

      - name: Configure environment on ${{ steps.normalize.outputs.server }}
        shell: bash
        run: |
          set -euo pipefail

          # retry <tries> <sleep> <cmd...>
          retry() { local t="$1" s="$2"; shift 2; local n=1; until "$@"; do
            (( n >= t )) && return 1; sleep "$s"; n=$((n+1))
          done; }

          SERVER='${{ steps.normalize.outputs.server }}'

          # constants (inline; remove if you already export them globally)
          DEST_PATH="/${{ inputs.DESTINATION_PATH != '' && inputs.DESTINATION_PATH || vars.DESTINATION_PATH }}/${{ inputs.PATH_TO_FILES != '' && inputs.PATH_TO_FILES || vars.PATH_TO_FILES }}"
          WPC_INDEX="https://${{ secrets.WPC_PRO_API_USER }}:${{ secrets.WPC_PRO_API_SECRET }}@${{ secrets.WPC_PRO_HOST }}/pypi/simple"
          SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                    -o PreferredAuthentications=password,keyboard-interactive \
                    -o PubkeyAuthentication=no -o GSSAPIAuthentication=no \
                    -o NumberOfPasswordPrompts=1 -o ConnectTimeout=10"

          echo "===== Configuring env on $SERVER ====="

          retry 4 10 \
          sshpass -p "${{ secrets.SAFEGUARD_SECRET }}" \
          ssh $SSH_OPTS root@"$SERVER" "
            set -euo pipefail
            cd '${DEST_PATH}'

            python -m venv venv
            . venv/bin/activate
            python -m pip install --upgrade pip

            pip install --no-cache-dir setuptools==75.8.0 -v -q -i '${WPC_INDEX}'
            pip install --no-cache-dir wheel==0.45.1        -v -q -i '${WPC_INDEX}'
            pip install --no-cache-dir build==1.2.2.post1   -v -q -i '${WPC_INDEX}'
            pip install --no-cache-dir bump2version==1.0.1  -v -q -i '${WPC_INDEX}'
            pip install --no-cache-dir twine==5.1.1         -v -q -i '${WPC_INDEX}'
            pip install -r requirements/requirements.txt    -v -q -i '${WPC_INDEX}'

            chmod -R 775 '${DEST_PATH}'
            chown -R '${{ vars.SERVICE_ACNT }}' '${DEST_PATH}'
          "

          echo "Environment configured on $SERVER ✅"
