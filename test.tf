  configure-multiple-server-environment:
    if: ${{ inputs.ENV_NAME == 'prod' }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        server: ${{ fromJSON('["' + join(split(inputs.SERVER_NAME, ','), '","') + '"]') }}

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
          echo "Configuring ${{ steps.normalize.outputs.server }} ..."
          # Your sshpass + pip + chmod/chown block goes here
