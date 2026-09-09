#!/usr/bin/env bash
# ==============================================================================
# SOC Pipeline Test Dispatcher (cURL / Bash)
# ==============================================================================

WEBHOOK_URL="${1:-http://localhost:5678/webhook/wazuh-alerts}"
PAYLOAD_FILE="$(dirname "$0")/sample-wazuh-alert.json"

echo "=========================================================="
echo "  Dispatching Test Wazuh Alert to n8n Pipeline"
echo "=========================================================="
echo "Target Webhook: ${WEBHOOK_URL}"
echo "Payload:        ${PAYLOAD_FILE}"

if [ ! -f "$PAYLOAD_FILE" ]; then
    echo "[-] Error: Payload file not found at $PAYLOAD_FILE"
    exit 1
fi

curl -X POST "${WEBHOOK_URL}" \
     -H "Content-Type: application/json" \
     --data-binary "@${PAYLOAD_FILE}"

echo -e "\n[+] Alert dispatched!"
