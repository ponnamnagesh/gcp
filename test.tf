- name: Test SSH/SCP with Python
  run: python3 .github/scripts/test_scp_ssh.py
  env:
    SERVER_NAME: ${{ inputs.SERVER_NAME }}        # from your matrix/caller
    SAFEGUARD_SECRET: ${{ env.SAFEGUARD_SECRET }} # set by Safeguard step




#!/usr/bin/env python3
import subprocess, os, sys

# Read server and password from environment variables
server = os.environ.get("SERVER_NAME")
user = "root"
password = os.environ.get("SAFEGUARD_SECRET")

# Paths for the test
src_path = "./testfile.txt"
dest_path = "/tmp/test_scp.txt"

# Validate inputs
if not server:
    print("❌ SERVER_NAME environment variable is not set")
    sys.exit(1)
if not password:
    print("❌ SAFEGUARD_SECRET environment variable is not set")
    sys.exit(1)

# Create a test file if it doesn’t exist
with open(src_path, "w") as f:
    f.write("scp/ssh test\n")

# SSH options to mimic your GitHub Actions job
ssh_opts = [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-o", "PreferredAuthentications=password,keyboard-interactive",
    "-o", "PubkeyAuthentication=no",
    "-o", "GSSAPIAuthentication=no",
    "-o", "KbdInteractiveAuthentication=no",
    "-o", "NumberOfPasswordPrompts=1",
    "-o", "ConnectTimeout=10",
]

def run_command(cmd, desc):
    print(f"\n🔹 {desc}")
    print(" ".join(cmd))  # print the command for visibility
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        if result.stdout:
            print("stdout:", result.stdout.strip())
        if result.stderr:
            print("stderr:", result.stderr.strip())
        print("✅ Success")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed with exit code {e.returncode}")
        if e.stdout:
            print("stdout:", e.stdout.strip())
        if e.stderr:
            print("stderr:", e.stderr.strip())
        sys.exit(e.returncode)

# Test SCP
scp_cmd = ["sshpass", "-p", password, "scp"] + ssh_opts + [src_path, f"{user}@{server}:{dest_path}"]
run_command(scp_cmd, f"SCP test to {server}")

# Test SSH
ssh_cmd = ["sshpass", "-p", password, "ssh"] + ssh_opts + [f"{user}@{server}", "whoami"]
run_command(ssh_cmd, f"SSH test to {server}")
