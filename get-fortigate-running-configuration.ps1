# Requires -Version 5.1

# -----------------------------------------------------------------------------
# CONFIGURATION VARIABLES
# -----------------------------------------------------------------------------
$FortiGateIP     = "192.168.8.15"
$FortiGatePort   = "443"
$Token           = "bxg37kQ899603bNNp6p10nnhz3j8Qm"
$BackupDir       = "/root/fortigate-backup-conf"
$BackupFileName  = "fortigate-full-config"
$BackupFileExt   = "json"
# The number of days to keep files before deletion
$RetentionDays   = 5

# API Endpoint
$Uri = "https://${FortiGateIP}:${FortiGatePort}/api/v2/monitor/system/config/backup?scope=global"

# Construct the dated file path
$BackupDateTime  = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$FullFileName    = "${BackupFileName}-${BackupDateTime}.${BackupFileExt}"
$BackupFile      = Join-Path -Path $BackupDir -ChildPath $FullFileName

# Headers for API call
$Headers = @{
    "Authorization" = "Bearer $Token"
}

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

function Cleanup-OldBackups {
<#
.SYNOPSIS
    Deletes files older than a specified number of days from a directory.
.PARAMETER BackupPath
    The directory containing the backup files.
.PARAMETER Retention
    The number of days to retain files. Files older than this will be deleted.
#>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BackupPath,

        [Parameter(Mandatory=$true)]
        [int]$Retention
    )

    Write-Host "--- Starting cleanup process in '$BackupPath' (Retention: $Retention days) ---" -ForegroundColor Yellow

    # Calculate the cutoff date (now minus retention days)
    $CutoffDate = (Get-Date).AddDays(-$Retention)
    Write-Host "Deleting files older than: $($CutoffDate)" -ForegroundColor Cyan

    try {
        # 1. Check if the directory exists
        if (-not (Test-Path -Path $BackupPath -PathType Container)) {
            Write-Warning "Backup directory not found: '$BackupPath'. Skipping cleanup."
            return
        }

        # 2. Find files older than the cutoff date
        $OldFiles = Get-ChildItem -Path $BackupPath -File | Where-Object { $_.LastWriteTime -lt $CutoffDate }

        if ($OldFiles.Count -eq 0) {
            Write-Host "No files found older than $Retention days. Cleanup complete." -ForegroundColor Green
        } else {
            Write-Host "Found $($OldFiles.Count) files to delete:" -ForegroundColor Red
            
            $OldFiles | ForEach-Object {
                Write-Host "Deleting file: $($_.Name)"
                Remove-Item -Path $_.FullName -Force -Confirm:$false
            }
            Write-Host "Successfully deleted $($OldFiles.Count) old files. Cleanup complete." -ForegroundColor Green
        }
    } catch {
        Write-Error "An error occurred during cleanup: $($_.Exception.Message)"
    }

    Write-Host "---------------------------------------------------------------------" -ForegroundColor Yellow
}

# -----------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION
# -----------------------------------------------------------------------------

# 1. RUN BACKUP
Write-Host "--- Starting FortiGate Configuration Backup ---" -ForegroundColor Yellow
try {
    # Check if directory exists, create it if not
    if (-not (Test-Path -Path $BackupDir)) {
        New-Item -Path $BackupDir -ItemType Directory | Out-Null
        Write-Host "Created backup directory: ${BackupDir}"
    }

    # Get full config (skip SSL check is important here)
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -SkipCertificateCheck
    
    # Convert response object to JSON string and save to file
    $Response | ConvertTo-Json -Depth 10 | Out-File $BackupFile
    
    Write-Host "SUCCESS: Full configuration saved into ${BackupFile}" -ForegroundColor Green

} catch {
    Write-Error "FATAL: FortiGate request failed: $($_.Exception.Message)"
}

# 2. RUN CLEANUP
Cleanup-OldBackups -BackupPath $BackupDir -Retention $RetentionDays
