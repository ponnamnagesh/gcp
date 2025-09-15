- name: Verify Safeguard password and wait
  shell: bash
  env:
    # Adjust these to match how your Safeguard action exposes the secret:
    # If it's already in env:
    RAW_SAFEGUARD_SECRET: ${{ env.SAFEGUARD_SECRET }}
    # Or if it comes as an output from previous step id 'safeguard':
    # RAW_SAFEGUARD_SECRET: ${{ steps.safeguard.outputs.password }}

    # Optional: how long to wait after retrieval (seconds)
    SAFEGUARD_STABILIZE_SECONDS: "20"
  run: |
    set -euo pipefail

    # 1) Normalize/trim (strip CR/LF)
    SAFE="$(printf %s "$RAW_SAFEGUARD_SECRET" | tr -d '\r\n')"

    # 2) Basic validation
    if [[ -z "${SAFE}" ]]; then
      echo "❌ Safeguard password is empty after trimming; aborting."
      exit 1
    fi
    # Guard against accidental literal templates or placeholders
    if [[ "$SAFE" =~ ^\$\{\{.*\}\}$ ]] || [[ "$SAFE" == "changeme" ]]; then
      echo "❌ Safeguard password looks like an unresolved/placeholder value; aborting."
      exit 1
    fi

    # 3) Mask and stash into a temp file for sshpass
    echo "::add-mask::${SAFE}"
    PASSFILE="$(mktemp)"
    chmod 600 "$PASSFILE"
    printf %s "$SAFE" > "$PASSFILE"

    # 4) Export for later steps
    {
      echo "SAFE_PASSFILE=$PASSFILE"
      echo "SAFE_LENGTH=${#SAFE}"
    } >> "$GITHUB_ENV"

    echo "✅ Safeguard password retrieved (length=${#SAFE}, masked)."

    # 5) Optional settle time (helps when backends have slight propagation lag)
    SLEEP_SEC="${SAFeguard_STABILIZE_SECONDS:-${SAFeguard_STABILIZE_SECONDS:-20}}"
    # normalize var name casing (handle typos/case)
    if [[ -z "${SLEEP_SEC}" ]]; then SLEEP_SEC="20"; fi
    echo "⏳ Waiting ${SLEEP_SEC}s after retrieval to stabilize…"
    sleep "$SLEEP_SEC"
