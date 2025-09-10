cd-workflow-pro:
  name: CD - Workflow for Prod Deployments
  if: ${{ github.event_name == 'workflow_dispatch' && github.event.inputs.envname == 'sandbox' }}
  needs: validate-cd-user
  strategy:
    fail-fast: false
    max-parallel: 1
    matrix:
      server: [ SVM4090BDV, SVM4091BDV ]

  steps:
    - name: Retry Deploy for ${{ matrix.server }}
      shell: bash
      env:
        GH_TOKEN: ${{ github.token }}
      run: |
        set -euo pipefail
        max_attempts=3
        wait_secs=60
        attempt=1

        until [ "$attempt" -gt "$max_attempts" ]; do
          echo "🚀 Attempt ${attempt} for ${{ matrix.server }}"

          gh workflow run .github/workflows/cd-python-scp-deploy.yml \
            --ref pipeline-shared-testprodserver-deploy \
            -f SERVER_NAME="${{ matrix.server }}" \
            -f PATH_TO_FILES="${{ vars.PATH_TO_FILES }}" \
            -f DESTINATION_PATH="${{ vars.DESTINATION_PATH }}" \
            -f RELEASE_VERSION="${{ github.event.inputs.RELEASE_VERSION }}" \
            -f ENV_NAME="${{ github.event.inputs.envname }}" \
            -f SAFEGUARD_URL="${{ vars.SAFEGUARD_URL }}" \
            -f SERVICE_ACNT="${{ vars.SERVICE_ACNT }}"

          echo "⏳ Waiting for the triggered run to complete…"
          if gh run watch --exit-status --workflow cd-python-scp-deploy.yml; then
            echo "✅ Deployment succeeded on attempt ${attempt} for ${{ matrix.server }}"
            exit 0
          fi

          if [ "$attempt" -eq "$max_attempts" ]; then
            echo "❌ Deployment failed after ${max_attempts} attempts for ${{ matrix.server }}"
            exit 1
          fi

          echo "⚠️ Attempt ${attempt} failed. Retrying in ${wait_secs}s…"
          attempt=$((attempt+1))
          sleep "${wait_secs}"
        done
