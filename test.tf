- name: Test SSH/SCP inline with Python
  shell: bash
  run: |
    python3 - <<'EOF'
    import os
    import subprocess
    import sys

    server = os.getenv("SERVER_NAME")
    safeguard_secret = os.getenv("SAFEGUARD_SECRET")

    print(f"DEBUG: running SCP/SSH test for {server}")

    try:
        # Example SSH command (skip host key verification for testing)
        result = subprocess.run(
            [
                "ssh",
                "-o", "StrictHostKeyChecking=no",
                f"root@{server}",
                "echo connected"
            ],
            check=True,
            capture_output=True,
            text=True
        )
        print("SSH Output:", result.stdout.strip())
    except subprocess.CalledProcessError as e:
        print("SSH failed:", e.stderr.strip())
        sys.exit(e.returncode)

    try:
        # Example SCP command (copy a test file)
        result = subprocess.run(
            [
                "scp",
                "-o", "StrictHostKeyChecking=no",
                "/etc/hosts",              # local test file
                f"root@{server}:/tmp/hosts_test"  # remote path
            ],
            check=True,
            capture_output=True,
            text=True
        )
        print("SCP Output:", result.stdout.strip())
    except subprocess.CalledProcessError as e:
        print("SCP failed:", e.stderr.strip())
        sys.exit(e.returncode)
    EOF
  env:
    SERVER_NAME: ${{ inputs.SERVER_NAME }}
    SAFEGUARD_SECRET: ${{ env.SAFEGUARD_SECRET }}
