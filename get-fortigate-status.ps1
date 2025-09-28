# Define variables
$FortiGateIP   = "192.168.8.15"
$Token         = "bxg37kQ899603bNNp6p10nnhz3j8Qm" # CHANGE to your API KEY
$Uri           = "https://$FortiGateIP/api/v2/monitor/system/status"

# Prepare headers
$Headers = @{
    "Accept"        = "application/json"
    "Authorization" = "Bearer $Token"
}

# Call FortiGate API (skip self-signed cert check)
$Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -SkipCertificateCheck
$Response
