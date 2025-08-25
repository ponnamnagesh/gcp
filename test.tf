name: Configure environments

on:
  workflow_dispatch:
    inputs:
      ENV_NAME:
        description: "Target environment"
        required: true
        default: dev

jobs:
  setup-service-account:
    runs-on: ubuntu-latest
    steps:
      - name: Do something
        run: echo "setup"

  configure-multiple-server-environment:
    if: ${{ inputs.ENV_NAME == 'prod' }}
    needs: setup-service-account
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        server: ${{ fromJSON('["' + join(split(vars.SERVER_NAME, ','), '","') + '"]') }}

    steps:
      - name: Normalize server value
        id: normalize
        run: |
          s='${{ matrix.server }}'
          echo "server=$(echo "$s" | xargs)" >> "$GITHUB_OUTPUT"

      - name: Retrieve credentials from Safeguard
        uses: charlesschwab/safeguard-secrets-action@v4
        with:
          certificate: "${{ secrets.SAFEGUARD_CERTIFICATE }}"
          certificate-private-key-phrase: "${{ secrets.SAFEGUARD_PRIVATE_KEY_PHRASE }}"
          account-name: root
          account-system: "${{ steps.normalize.outputs.server }}"
          github-token: "${{ steps.generate_token.outputs.token }}"
          safeguard-url: "${{ vars.SAFEGUARD_URL }}"

      - name: Configure environment on ${{ steps.normalize.outputs.server }}
        run: |
          set -euo pipefail
          retry() { t="$1"; s="$2"; shift 2; n=1; until "$@"; do ((n>=t)) && return 1; sleep "$s"; n=$((n+1)); done; }

          echo "===== Configuring env on ${{ steps.normalize.outputs.server }} ====="
          retry 4 10 \
          sshpass -p "${{ secrets.SAFEGUARD_SECRET }}" \
          ssh -o StrictHostKeyChecking=no root@"${{ steps.normalize.outputs.server }}" "
            set -euo pipefail
            cd /${{ vars.DESTINATION_PATH }}/${{ vars.PATH_TO_FILES }}
            python -m venv venv
            . venv/bin/activate
            python -m pip install --upgrade pip
            pip install --no-cache-dir setuptools==75.8.0 wheel==0.45.1 build==1.2.2.post1 bump2version==1.0.1 twine==5.1.1 -v -q \
              -i https://${{ secrets.WPC_PRO_API_USER }}:${{ secrets.WPC_PRO_API_SECRET }}@${{ secrets.WPC_PRO_HOST }}/pypi/simple
            pip install -r requirements/requirements.txt -v -q
            chmod -R 775 /${
