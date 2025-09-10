jobs:
  cd-workflow-pro:
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        server: [ SVM4090BDV, SVM4091BDV ]

    steps:
      - name: Retry Deploy for ${{ matrix.server }}
        run: |
          n=0
          until [ "$n" -ge 3 ]
          do
            echo "Attempt $((n+1)) for ${{ matrix.server }}"
            if gh workflow run .github/workflows/cd-python-scp-deploy.yml \
              --ref pipeline-shared-testprodserver-deploy \
              -f SERVER_NAME="${{ matrix.server }}" \
              -f PATH_TO_FILES="${{ vars.PATH_TO_FILES }}" \
              -f DESTINATION_PATH="${{ vars.DESTINATION_PATH }}" \
              -f RELEASE_VERSION="${{ github.event.inputs.RELEASE_VERSION }}" \
              -f ENV_NAME="${{ inputs.envname }}" \
              -f SAFEGUARD_URL="${{ vars.SAFEGUARD_URL }}" \
              -f SERVICE_ACNT="${{ vars.SERVICE_ACNT }}"
            then
              echo "✅ Deployment succeeded on attempt $((n+1)) for ${{ matrix.server }}"
              exit 0
            fi
            n=$((n+1))
            echo "Retrying in 60s..."
            sleep 60
          done
          echo "❌ Deployment failed after 3 attempts for ${{ matrix.server }}"
          exit 1
