- name: Test SSH/SCP inline with Python
  run: |
    python3 - <<'EOF'
    import os
    import subprocess
    import sys

    server = os.getenv("SERVER_NAME")
    safeguard_secret = os.getenv("SAFEGUARD_SECRET")

    print(f"DEBUG: running SCP test for {server}")

    try:
        # Example SSH command
        result = subprocess.run(
            ["ssh", f"root@{server}", "echo connected"],
            check=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("SSH failed:", e.stderr)
        sys.exit(1)
    EOF
  env:
    SERVER_NAME: ${{ inputs.SERVER_NAME }}
    SAFEGUARD_SECRET: ${{ env.SAFEGUARD_SECRET }}
