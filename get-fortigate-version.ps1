<#
.SYNOPSIS
    Retrieves the FortiGate firmware version using the REST API.

.DESCRIPTION
    This script connects to a FortiGate firewall using its IP and API key,
    queries the /api/v2/monitor/system/status endpoint, and outputs the
    current firmware version.

.NOTES
    - Requires HTTPS connection.
    - Uses -SkipCertificateCheck for self-signed or untrusted certificates.
    - API Key is passed as an 'access_token' query parameter.
#>

# --- Configuration Variables ---

# FortiGate Management IP address
$FortiGateIP = "192.168.8.15"

# FortiGate API Key provided for authentication
$ApiKey = "Qp8tr8zdmHxnkp0QG4j58scz97pmw8"

# API Endpoint for system status (which includes version information)
$ApiEndpoint = "/api/v2/monitor/system/status"

# Construct the full URI, passing the API key as the 'access_token' query parameter
$Uri = "https://$FortiGateIP$ApiEndpoint?access_token=$ApiKey"

Write-Host "Attempting to connect to FortiGate at $($FortiGateIP) to retrieve version..."

try {
    # Perform the REST API call
    # -Method Get: Standard HTTP GET request
    # -SkipCertificateCheck: Required when the FortiGate uses a self-signed or untrusted certificate.
    # -ErrorAction Stop: Ensures the 'catch' block handles non-200 responses.
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -SkipCertificateCheck -ErrorAction Stop

    # Check if the response was successful (FortiGate API uses a status code 0 for success)
    if ($Response.status -eq 0) {
        # The version information is typically nested under the 'results' property
        $Version = $Response.results.version
        $Build = $Response.results.build
        $Platform = $Response.results.platform

        Write-Host "--------------------------------------------------------"
        Write-Host "Successfully retrieved FortiGate System Status"
        Write-Host "--------------------------------------------------------"
        Write-Host "Firmware Version: $($Version)"
        Write-Host "Build Number:     $($Build)"
        Write-Host "Platform:         $($Platform)"
        Write-Host "--------------------------------------------------------"
    } else {
        # Handle API error response (e.g., invalid token, permission issue)
        Write-Error "FortiGate API returned an error (Status: $($Response.status)). Message: $($Response.http_status)"
    }

}
catch {
    # Handle connection errors (e.g., timeout, connection refused, invalid IP)
    Write-Error "An error occurred during the API request:"
    Write-Error $_.Exception.Message
    Write-Host "`nEnsure the FortiGate IP is correct, the API key is valid, and the firewall is reachable."
}

# Clean up variables (optional but good practice)
Remove-Variable FortiGateIP, ApiKey, ApiEndpoint, Uri -ErrorAction SilentlyContinue