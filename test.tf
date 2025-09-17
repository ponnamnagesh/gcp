cd-workflow-non-prod:
  name: CD - Workflow for Prod Deployments
  needs: validate-cd-user
  if: github.event_name == 'workflow_dispatch' && inputs.envname == 'sandbox'
  environment: ${{ inputs.envname }}
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: ${{ fromJSON(vars.SERVER_NAME) }}
  uses: charlesschwab/samda-action-workflows/.github/workflows/cd-python-scp-deploy.yml@main
  with:
    SERVER_NAME: ${{ matrix.server }}
    PATH_TO_FILES: ${{ vars.PATH_TO_FILES }}
    DESTINATION_PATH: ${{ vars.DESTINATION_PATH }}
    RELEASE_VERSION: ${{ github.event.inputs.RELEASE_VERSION }}
    ENV_NAME: ${{ inputs.envname }}
    SAFEGUARD_URL: ${{ vars.SAFEGUARD_URL }}
    SERVICE_ACNT: ${{ vars.SERVICE_ACNT }}
  secrets: inherit
