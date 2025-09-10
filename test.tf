# --- Attempt 1 ---
cd-workflow-pro-attempt1:
  name: CD - Workflow for Prod Deployments (try 1)
  if: ${{ github.event_name == 'workflow_dispatch' && github.event.inputs.envname == 'sandbox' }}
  needs: validate-cd-user
  uses: charlesschwab/samda-action-workflows/.github/workflows/cd-python-scp-deploy.yml@pipeline-shared-testprodserver-deploy
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: [ SVM4090BDV, SVM4091BDV ]
  with:
    SERVER_NAME: "${{ matrix.server }}"
    PATH_TO_FILES: "${{ vars.PATH_TO_FILES }}"
    DESTINATION_PATH: "${{ vars.DESTINATION_PATH }}"
    RELEASE_VERSION: "${{ github.event.inputs.RELEASE_VERSION }}"
    ENV_NAME: "${{ github.event.inputs.envname }}"
    SAFEGUARD_URL: "${{ vars.SAFEGUARD_URL }}"
    SERVICE_ACNT: "${{ vars.SERVICE_ACNT }}"
  secrets: inherit
  continue-on-error: true

# --- Attempt 2 (only if attempt 1 failed) ---
cd-workflow-pro-attempt2:
  name: CD - Workflow for Prod Deployments (try 2)
  if: ${{ github.event_name == 'workflow_dispatch'
          && github.event.inputs.envname == 'sandbox'
          && needs.cd-workflow-pro-attempt1.result != 'success' }}
  needs: [validate-cd-user, cd-workflow-pro-attempt1]
  uses: charlesschwab/samda-action-workflows/.github/workflows/cd-python-scp-deploy.yml@pipeline-shared-testprodserver-deploy
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: [ SVM4090BDV, SVM4091BDV ]
  with:
    SERVER_NAME: "${{ matrix.server }}"
    PATH_TO_FILES: "${{ vars.PATH_TO_FILES }}"
    DESTINATION_PATH: "${{ vars.DESTINATION_PATH }}"
    RELEASE_VERSION: "${{ github.event.inputs.RELEASE_VERSION }}"
    ENV_NAME: "${{ github.event.inputs.envname }}"
    SAFEGUARD_URL: "${{ vars.SAFEGUARD_URL }}"
    SERVICE_ACNT: "${{ vars.SERVICE_ACNT }}"
  secrets: inherit
  continue-on-error: true

# --- Attempt 3 (final; fails the workflow if still not successful) ---
cd-workflow-pro-attempt3:
  name: CD - Workflow for Prod Deployments (try 3)
  if: ${{ github.event_name == 'workflow_dispatch'
          && github.event.inputs.envname == 'sandbox'
          && needs.cd-workflow-pro-attempt2.result != 'success' }}
  needs: [validate-cd-user, cd-workflow-pro-attempt2]
  uses: charlesschwab/samda-action-workflows/.github/workflows/cd-python-scp-deploy.yml@pipeline-shared-testprodserver-deploy
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: [ SVM4090BDV, SVM4091BDV ]
  with:
    SERVER_NAME: "${{ matrix.server }}"
    PATH_TO_FILES: "${{ vars.PATH_TO_FILES }}"
    DESTINATION_PATH: "${{ vars.DESTINATION_PATH }}"
    RELEASE_VERSION: "${{ github.event.inputs.RELEASE_VERSION }}"
    ENV_NAME: "${{ github.event.inputs.envname }}"
    SAFEGUARD_URL: "${{ vars.SAFEGUARD_URL }}"
    SERVICE_ACNT: "${{ vars.SERVICE_ACNT }}"
  secrets: inherit
  # no continue-on-error here → the workflow fails if try 3 also fails
