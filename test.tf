cd-workflow-non-prod:
  name: CD - Workflow for Prod Deployments
  needs: validate-cd-user
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: ${{ split(env.SERVER_NAME, ',') }}
  uses: charlesschwab/samda-action-workflows/.github/workflows/cd-python.yml
  with:
    SERVER_NAME: ${{ matrix.server }}
    PATH_TO_FILES: ${{ vars.PATH_TO_FILES }}
    DESTINATION_PATH: ${{ vars.DESTINATION_PATH }}
    RELEASE_VERSION: ${{ github.event.inputs.RELEASE_VERSION }}
    ENV_NAME: ${{ inputs.envname }}
    SAFEGUARD_URL: ${{ vars.SAFEGUARD_URL }}
    SERVICE_ACNT: ${{ vars.SERVICE_ACNT }}
  secrets: inherit
