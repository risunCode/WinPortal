# Windows System Cleanup Script - PowerShell Version
# Can be run online with: irm your-link-here | iex

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-Command", "irm your-link-here | iex"
    exit
}

# Set console window size
try {
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 50)
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(80, 50)
} catch {
    # Ignore if can't resize (some terminals don't support it)
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "           Windows System Cleanup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Select cleanup mode:" -ForegroundColor Green
Write-Host "1. Standard cleanup (recommended)" -ForegroundColor White
Write-Host "2. Deep cleanup (includes Recycle Bin)" -ForegroundColor White
Write-Host ""

do {
    $choice = Read-Host "Press 1 or 2 to select"
} while ($choice -notin @('1', '2'))

$cleanupMode = if ($choice -eq '1') { 'standard' } else { 'deep' }
Write-Host "$($cleanupMode.Substring(0,1).ToUpper() + $cleanupMode.Substring(1)) cleanup mode selected." -ForegroundColor Green
Write-Host ""

# Create log file with timestamp
$timestamp = Get-Date -Format "yyyy_MM_dd_HHmmss"
$logPath = "$env:USERPROFILE\Desktop\cleanup_log_$timestamp.txt"

# Initialize log file
@"
===============================================
           Windows System Cleanup Log
           Date: $(Get-Date)
===============================================

"@ | Out-File -FilePath $logPath -Encoding UTF8

function Write-Log {
    param([string]$Message)
    Add-Content -Path $logPath -Value $Message -Encoding UTF8
}

function Clean-Location {
    param(
        [string]$Path,
        [string]$Description
    )
    
    Write-Host "Cleaning $Description..." -ForegroundColor Yellow
    Write-Log "Cleaning $Description..."
    
    if (Test-Path $Path) {
        try {
            Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    if ($_.PSIsContainer) {
                        Write-Log "Deleted folder: $($_.FullName)"
                        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        Write-Log "Deleted file: $($_.FullName)"
                        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    }
                } catch {
                    Write-Log "Failed to delete: $($_.FullName) - $($_.Exception.Message)"
                }
            }
        } catch {
            Write-Log "Error accessing $Path - $($_.Exception.Message)"
        }
    } else {
        Write-Log "$Path does not exist"
    }
}

# Clean User temp files
Clean-Location -Path $env:TEMP -Description "User temp files"

# Clean TMP files
if ($env:TMP -and ($env:TMP -ne $env:TEMP)) {
    Clean-Location -Path $env:TMP -Description "TMP files"
}

# Clean Local Settings Temp (for older Windows versions)
$localTemp = "$env:USERPROFILE\Local Settings\Temp"
if (Test-Path $localTemp) {
    Clean-Location -Path $localTemp -Description "Local Settings temp files"
}

# Clean LocalAppData Temp
$localAppDataTemp = "$env:LOCALAPPDATA\Temp"
Clean-Location -Path $localAppDataTemp -Description "LocalAppData temp files"

# Clean Windows temp files
$winTemp = "$env:WINDIR\Temp"
Clean-Location -Path $winTemp -Description "Windows temp files"

# Clean Prefetch files
Write-Host "Cleaning Prefetch files..." -ForegroundColor Yellow
Write-Log "Cleaning Prefetch files..."
$prefetchPath = "$env:WINDIR\Prefetch"
if (Test-Path $prefetchPath) {
    try {
        Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Write-Log "Deleted file: $($_.FullName)"
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Log "Failed to delete: $($_.FullName)"
            }
        }
    } catch {
        Write-Log "Error accessing Prefetch folder"
    }
}

# Clean Recent files
Write-Host "Cleaning Recent files..." -ForegroundColor Yellow
Write-Log "Cleaning Recent files..."
$recentPath = "$env:USERPROFILE\Recent"
if (Test-Path $recentPath) {
    try {
        Get-ChildItem -Path $recentPath -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Write-Log "Deleted file: $($_.FullName)"
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Log "Failed to delete: $($_.FullName)"
            }
        }
    } catch {
        Write-Log "Error accessing Recent folder"
    }
}

# Clean Recycle Bin (only in deep mode)
if ($cleanupMode -eq 'deep') {
    Write-Host "Cleaning Recycle Bin..." -ForegroundColor Yellow
    Write-Log "Cleaning Recycle Bin..."
    
    try {
        # Use built-in PowerShell command
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Log "Recycle Bin cleared using PowerShell command"
        
        # Also manually clean $Recycle.Bin folders as backup
        Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
            $recyclePath = "$($_.DeviceID)\`$Recycle.Bin"
            if (Test-Path $recyclePath) {
                Write-Log "Cleaning Recycle Bin on drive $($_.DeviceID)..."
                try {
                    Get-ChildItem -Path $recyclePath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                        try {
                            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Log "Deleted: $($_.FullName)"
                        } catch {
                            Write-Log "Failed to delete: $($_.FullName)"
                        }
                    }
                } catch {
                    Write-Log "Error accessing $recyclePath"
                }
            }
        }
    } catch {
        Write-Log "Error cleaning Recycle Bin: $($_.Exception.Message)"
    }
}

# Clean Browser caches
Write-Host "Cleaning Browser caches..." -ForegroundColor Yellow
Write-Log "Cleaning Browser caches..."

# Chrome cache
$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache"
)

foreach ($path in $chromeCachePaths) {
    if (Test-Path $path) {
        Clean-Location -Path $path -Description "Chrome cache"
    }
}

# Firefox cache
$firefoxProfiles = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfiles) {
    Get-ChildItem -Path $firefoxProfiles -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $cachePath = Join-Path $_.FullName "cache2"
        if (Test-Path $cachePath) {
            Clean-Location -Path $cachePath -Description "Firefox cache"
        }
    }
}

# Edge cache
$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)

foreach ($path in $edgeCachePaths) {
    if (Test-Path $path) {
        Clean-Location -Path $path -Description "Edge cache"
    }
}

# Opera cache
$operaCache = "$env:APPDATA\Opera Software\Opera Stable\Cache"
if (Test-Path $operaCache) {
    Clean-Location -Path $operaCache -Description "Opera cache"
}

# Finalize log
Write-Log ""
Write-Log "-------------------------------------------------------"
if ($cleanupMode -eq 'deep') {
    Write-Log "           Deep Cleanup completed !!!"
} else {
    Write-Log "         Standard Cleanup completed !!!"
}
Write-Log "-------------------------------------------------------"

# Display completion message
Write-Host ""
Write-Host "-------------------------------------------------------" -ForegroundColor Green
if ($cleanupMode -eq 'deep') {
    Write-Host "           Deep Cleanup completed !!!" -ForegroundColor Green
} else {
    Write-Host "         Standard Cleanup completed !!!" -ForegroundColor Green
}
Write-Host "-------------------------------------------------------" -ForegroundColor Green
Write-Host ""
Write-Host "Cleaned locations:" -ForegroundColor Cyan
Write-Host "- User Temp files" -ForegroundColor White
Write-Host "- Local Temp files" -ForegroundColor White
Write-Host "- Windows Temp files" -ForegroundColor White
Write-Host "- Prefetch files" -ForegroundColor White
Write-Host "- Recent files" -ForegroundColor White
if ($cleanupMode -eq 'deep') {
    Write-Host "- Recycle Bin (all drives)" -ForegroundColor White
}
Write-Host "- Browser caches (Chrome, Firefox, Edge, Opera)" -ForegroundColor White
Write-Host ""
Write-Host "Cleanup mode: $cleanupMode" -ForegroundColor Yellow
Write-Host "Log file created: $logPath" -ForegroundColor Yellow
Write-Host ""

# Calculate and display freed space (optional)
try {
    $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    Write-Host "Current free space on C: drive: $freeSpaceGB GB" -ForegroundColor Cyan
} catch {
    # Ignore if can't get disk info
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")