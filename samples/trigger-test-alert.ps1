# ==============================================================================
# SOC Pipeline Test Dispatcher (PowerShell)
# Dispatches sample-wazuh-alert.json to the n8n Webhook
# ==============================================================================

param (
    [string]$WebhookUrl = "http://localhost:5678/webhook/wazuh-alerts",
    [string]$PayloadFile = "$PSScriptRoot\sample-wazuh-alert.json"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Dispatched Test Wazuh Alert to n8n SOAR Pipeline" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target URL : $WebhookUrl" -ForegroundColor Yellow
Write-Host "Payload    : $PayloadFile" -ForegroundColor Yellow

if (-not (Test-Path $PayloadFile)) {
    Write-Error "Payload file not found: $PayloadFile"
    exit 1
}

$body = Get-Content -Path $PayloadFile -Raw

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType "application/json" -TimeoutSec 30
    Write-Host "`n[+] Alert successfully dispatched to pipeline!" -ForegroundColor Green
    Write-Host "[+] Webhook Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
} catch {
    Write-Error "Failed to send alert: $_"
    Write-Host "`nTip: Ensure n8n is running and the workflow webhook is active (listening on $WebhookUrl)." -ForegroundColor Yellow
}
