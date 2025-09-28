# Variables
$FortiGateIP = "192.168.8.15"
$Token       = "bxg37kQ899603bNNp6p10nnhz3j8Qm"
# This endpoint gives the full config
$Uri         = "https://$FortiGateIP/api/v2/monitor/system/config/backup?scope=global"

# Headers
$Headers = @{
    "Authorization" = "Bearer $Token"
}

# Get full config (skip SSL check)
try {
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -SkipCertificateCheck
    # $Response is already a JSON object if returned as JSON
    $Response | ConvertTo-Json -Depth 10 | Out-File "/root/fortigate-conf/fortigate-full-config.json"
    Write-Host "Full configuration saved."
} catch {
    Write-Error "Request failed: $_"
}
