# Windows Script Launcher - All in One PowerShell Version
# Author: Based on existing winScript collection
# Date: September 15, 2025

# Set console properties for better display
$Host.UI.RawUI.WindowTitle = "Windows Script Launcher - All in One"
try {
    # Set console size
    $console = $Host.UI.RawUI
    $size = $console.WindowSize
    $size.Width = 90
    $size.Height = 30
    $console.WindowSize = $size
    
    # Set buffer size
    $buffer = $console.BufferSize
    $buffer.Width = 90
    $buffer.Height = 3000
    $console.BufferSize = $buffer
} catch {
    # Ignore if can't set console properties
}

# Function to check administrator privileges
function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to request administrator privileges
function Request-AdminPrivileges {
    if (-not (Test-AdminPrivileges)) {
        Clear-Host
        Write-Host "===============================================================================" -ForegroundColor Yellow
        Write-Host "                        ADMINISTRATOR PRIVILEGES REQUIRED" -ForegroundColor Yellow
        Write-Host "===============================================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  This launcher requires administrator privileges to execute tools properly." -ForegroundColor White
        Write-Host "  Most tools in this collection need elevated permissions to modify system" -ForegroundColor White
        Write-Host "  settings, manage Windows services, and perform system-level operations." -ForegroundColor White
        Write-Host ""
        Write-Host "  Attempting automatic elevation..." -ForegroundColor Cyan
        Write-Host "  If UAC dialog appears, please click 'Yes' to continue." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "===============================================================================" -ForegroundColor Yellow
        
        try {
            Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        } catch {
            Write-Host "Failed to request admin privileges. Please run this script as Administrator manually." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

# Check admin privileges at startup
Request-AdminPrivileges

# Clear screen and show admin confirmation
Clear-Host
Write-Host "===============================================================================" -ForegroundColor Green
Write-Host "                         ADMINISTRATOR PRIVILEGES OBTAINED" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Green
Start-Sleep -Seconds 1

# Main menu function
function Show-MainMenu {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                           WINDOWS SCRIPT LAUNCHER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] System Cache Cleaner      - Clean temp files and browser cache" -ForegroundColor White
    Write-Host "  [2] Chrome Policy Remover     - Remove Chrome management policies" -ForegroundColor White
    Write-Host "  [3] Power Management Suite    - Shutdown, restart, and power options" -ForegroundColor White
    Write-Host "  [4] Windows Update Controller - Delay or pause Windows updates" -ForegroundColor White
    Write-Host "  [5] WiFi Profile Manager      - Backup, restore, and manage WiFi profiles" -ForegroundColor White
    Write-Host "  [6] TTL Bypass Tool           - Modify TTL settings for tethering bypass" -ForegroundColor White
    Write-Host "  [7] OneDrive Switcher         - Enable/disable OneDrive startup and sync" -ForegroundColor White
    Write-Host "  [8] Windows Activator         - Activate Windows and Office" -ForegroundColor White
    Write-Host "  [9] WinUtils (ChrisTitusTech) - Optimize and debloat Windows" -ForegroundColor White
    Write-Host ""
    Write-Host "  [R] Refresh Menu    [H] Help / About    [Q] Quit Launcher" -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $choice = Read-Host "Select option (1-9, R, H, Q)"
    
    switch ($choice.ToUpper()) {
        "1" { Invoke-CacheCleaner }
        "2" { Invoke-ChromePolicyRemover }
        "3" { Invoke-PowerManager }
        "4" { Invoke-WindowsUpdateController }
        "5" { Invoke-WiFiManager }
        "6" { Invoke-TTLBypass }
        "7" { Invoke-OneDriveSwitcher }
        "8" { Invoke-WindowsActivator }
        "9" { Invoke-WinUtils }
        "R" { Show-MainMenu }
        "H" { Show-Help }
        "Q" { Exit-Launcher }
        default { 
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Show-MainMenu 
        }
    }
}

# Cache Cleaner function
function Invoke-CacheCleaner {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                           SYSTEM CACHE CLEANER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Select cleanup mode:" -ForegroundColor Yellow
    Write-Host "1. Standard cleanup (recommended)" -ForegroundColor White
    Write-Host "2. Deep cleanup (includes Recycle Bin)" -ForegroundColor White
    Write-Host ""
    
    $mode = Read-Host "Press 1 or 2 to select"
    
    $cleanupMode = switch ($mode) {
        "1" { "standard" }
        "2" { "deep" }
        default { 
            Write-Host "Invalid selection. Using standard mode." -ForegroundColor Yellow
            "standard" 
        }
    }
    
    Write-Host ""
    Write-Host "Starting $cleanupMode cleanup..." -ForegroundColor Green
    
    # User temp files
    Write-Host "Deleting User temp files..." -ForegroundColor Yellow
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error cleaning user temp: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # System temp files
    Write-Host "Deleting Windows temp files..." -ForegroundColor Yellow
    try {
        Remove-Item -Path "$env:WINDIR\temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error cleaning system temp: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # LocalAppData temp
    Write-Host "Cleaning LocalAppData temp files..." -ForegroundColor Yellow
    try {
        $localTempPath = "$env:LOCALAPPDATA\Temp"
        if (Test-Path $localTempPath) {
            Remove-Item -Path "$localTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Error cleaning LocalAppData temp: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Prefetch files
    Write-Host "Cleaning Prefetch files..." -ForegroundColor Yellow
    try {
        $prefetchPath = "$env:WINDIR\Prefetch"
        if (Test-Path $prefetchPath) {
            Remove-Item -Path "$prefetchPath\*" -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Error cleaning Prefetch: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Recent files
    Write-Host "Cleaning Recent files..." -ForegroundColor Yellow
    try {
        $recentPath = "$env:USERPROFILE\Recent"
        if (Test-Path $recentPath) {
            Remove-Item -Path "$recentPath\*" -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Error cleaning Recent files: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Browser caches
    Write-Host "Cleaning Browser caches..." -ForegroundColor Yellow
    
    # Chrome cache
    try {
        $chromeCachePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        if (Test-Path $chromeCachePath) {
            Remove-Item -Path "$chromeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Error cleaning Chrome cache: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Firefox cache
    try {
        $firefoxPath = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $firefoxPath) {
            Get-ChildItem -Path $firefoxPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $cachePath = Join-Path $_.FullName "cache2"
                if (Test-Path $cachePath) {
                    Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    } catch {
        Write-Host "Error cleaning Firefox cache: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Edge cache
    try {
        $edgeCachePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
        if (Test-Path $edgeCachePath) {
            Remove-Item -Path "$edgeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Error cleaning Edge cache: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Recycle Bin (only in deep mode)
    if ($cleanupMode -eq "deep") {
        Write-Host "Cleaning Recycle Bin..." -ForegroundColor Yellow
        try {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Error cleaning Recycle Bin: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    
    Write-Host ""
    Write-Host "-------------------------------------------------------" -ForegroundColor Green
    if ($cleanupMode -eq "deep") {
        Write-Host "           Deep Cleanup completed !!!" -ForegroundColor Green
        Write-Host "[SUCCESS] Successfully cleaned: User Temp, System Temp, LocalAppData Temp, Prefetch, Recent files, Recycle Bin, Browser caches" -ForegroundColor Cyan
    } else {
        Write-Host "         Standard Cleanup completed !!!" -ForegroundColor Green
        Write-Host "[SUCCESS] Successfully cleaned: User Temp, System Temp, LocalAppData Temp, Prefetch, Recent files, Browser caches" -ForegroundColor Cyan
    }
    Write-Host "-------------------------------------------------------" -ForegroundColor Green
    Write-Host ""
    Write-Host "Cleanup mode: $cleanupMode" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Cache Cleaner completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# Chrome Policy Remover function
function Invoke-ChromePolicyRemover {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                          CHROME POLICY REMOVER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "WARNING: This script will forcefully remove Chrome policies and settings." -ForegroundColor Yellow
    Write-Host "Please close Chrome before continuing." -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Continue? (Y/N)"
    
    if ($confirm.ToUpper() -ne "Y") {
        Show-MainMenu
        return
    }
    
    Write-Host ""
    Write-Host "Starting comprehensive Chrome cleanup with elevated privileges..." -ForegroundColor Green
    
    # Step 1: Kill Chrome processes
    Write-Host "Step 1: Removing Chrome processes..." -ForegroundColor Yellow
    try {
        Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Chrome processes terminated." -ForegroundColor Green
    } catch {
        Write-Host "No Chrome processes found or already terminated." -ForegroundColor Cyan
    }
    
    # Step 2: Remove registry keys
    Write-Host "Step 2: Removing Chrome registry keys..." -ForegroundColor Yellow
    
    $registryPaths = @(
        "HKCU:\Software\Google\Chrome",
        "HKCU:\Software\Policies\Google\Chrome",
        "HKLM:\Software\Google\Chrome",
        "HKLM:\Software\Policies\Google\Chrome",
        "HKLM:\Software\Policies\Google\Update",
        "HKLM:\Software\WOW6432Node\Google\Enrollment"
    )
    
    foreach ($path in $registryPaths) {
        try {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "Removed: $path" -ForegroundColor Green
            }
        } catch {
            Write-Host "Could not remove: $path" -ForegroundColor Yellow
        }
    }
    
    # Step 3: Remove CloudManagementEnrollmentToken
    Write-Host "Step 3: Removing CloudManagementEnrollmentToken..." -ForegroundColor Yellow
    try {
        $tokenPath = "HKLM:\Software\WOW6432Node\Google\Update\ClientState\{430FD4D0-B729-4F61-AA34-91526481799D}"
        if (Test-Path $tokenPath) {
            Remove-ItemProperty -Path $tokenPath -Name "CloudManagementEnrollmentToken" -ErrorAction SilentlyContinue
            Write-Host "CloudManagementEnrollmentToken removed." -ForegroundColor Green
        }
    } catch {
        Write-Host "CloudManagementEnrollmentToken not found or already removed." -ForegroundColor Cyan
    }
    
    # Step 4: Remove Google Policies directory
    Write-Host "Step 4: Taking ownership and removing Google Policies directory..." -ForegroundColor Yellow
    try {
        $policiesPath = "${env:ProgramFiles(x86)}\Google\Policies"
        if (Test-Path $policiesPath) {
            # Take ownership
            & takeown /F $policiesPath /A /R /D Y 2>$null
            & icacls $policiesPath /grant Administrators:F /T /C 2>$null
            
            # Remove directory
            Remove-Item -Path $policiesPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Policies directory removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Policies directory not found - skipping." -ForegroundColor Cyan
        }
    } catch {
        Write-Host "Could not remove policies directory: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Step 5: Clear Chrome preferences
    Write-Host "Step 5: Additional policy cleanup for 'Managed by organization'..." -ForegroundColor Yellow
    try {
        $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"
        if (Test-Path $preferencesPath) {
            Write-Host "Clearing Chrome preferences file..." -ForegroundColor Yellow
            Remove-Item -Path $preferencesPath -Force -ErrorAction SilentlyContinue
            Write-Host "Chrome preferences cleared." -ForegroundColor Green
        }
    } catch {
        Write-Host "Could not clear Chrome preferences: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                            CLEANUP COMPLETE!" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please note:" -ForegroundColor Cyan
    Write-Host "- You should restart Chrome to apply all changes" -ForegroundColor White
    Write-Host "- If your device is domain-joined or managed by your organization," -ForegroundColor White
    Write-Host "  these policies might be automatically reinstated" -ForegroundColor White
    Write-Host "- If you still see 'Managed by your organization', your device" -ForegroundColor White
    Write-Host "  might be managed through Group Policy or your organization's domain" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Chrome Policy Remover completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# Power Manager function
function Invoke-PowerManager {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                          POWER MANAGEMENT SUITE" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "WARNING: Power operations will affect your system immediately." -ForegroundColor Yellow
    Write-Host "Make sure all your work is saved before proceeding." -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Are you sure you want to continue? (Y/N)"
    
    if ($confirm.ToUpper() -ne "Y") {
        Show-MainMenu
        return
    }
    
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                          POWER MANAGEMENT SUITE" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Select power operation:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Forced Shutdown (shutdown /s /f /t 0)" -ForegroundColor White
    Write-Host "2. Normal Shutdown (shutdown /s)" -ForegroundColor White
    Write-Host "3. Boot to UEFI Menu (shutdown /r /fw /t 0)" -ForegroundColor White
    Write-Host "4. Sleep Mode (standby)" -ForegroundColor White
    Write-Host "5. Hibernate" -ForegroundColor White
    Write-Host "6. Reboot System (restart normal)" -ForegroundColor White
    Write-Host "7. Soft Reboot (restart with /soft option)" -ForegroundColor White
    Write-Host "8. Custom Command (custom shutdown command)" -ForegroundColor White
    Write-Host "9. Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Select option (1-9)"
    
    $datetime = Get-Date
    
    switch ($choice) {
        "1" { 
            Write-Host ""
            Write-Host "Computer will be forcefully shut down in 5 seconds..." -ForegroundColor Red
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Red
                Write-Host "User Choice: Forced Shutdown - Make sure all apps are closed!" -ForegroundColor Red
                Write-Host "===============================================================================" -ForegroundColor Red
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            Write-Host "[SUCCESS] Forced shutdown command executed successfully!" -ForegroundColor Green
            shutdown /s /f /t 0
        }
        "2" { 
            Write-Host ""
            Write-Host "Computer will be shut down normally in 5 seconds..." -ForegroundColor Yellow
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Yellow
                Write-Host "User Choice: Normal Shutdown - Make sure all apps are closed!" -ForegroundColor Yellow
                Write-Host "===============================================================================" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Cyan
                Start-Sleep -Seconds 1
            }
            Write-Host "[SUCCESS] Normal shutdown command executed successfully!" -ForegroundColor Green
            shutdown /s /t 0
        }
        "3" { 
            Write-Host ""
            Write-Host "Boot to UEFI menu in 5 seconds..." -ForegroundColor Cyan
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Cyan
                Write-Host "User Choice: Boot to UEFI Menu" -ForegroundColor Cyan
                Write-Host "===============================================================================" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            Write-Host "[SUCCESS] UEFI boot command executed successfully!" -ForegroundColor Green
            shutdown /r /fw /t 0
        }
        "4" { 
            Write-Host ""
            Write-Host "Computer will enter Sleep mode in 5 seconds..." -ForegroundColor Green
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Green
                Write-Host "User Choice: Sleep Mode (Standby)" -ForegroundColor Green
                Write-Host "===============================================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            # Disable hibernate and enter sleep
            powercfg -hibernate off | Out-Null
            Write-Host "[SUCCESS] Sleep mode command executed successfully!" -ForegroundColor Green
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
        }
        "5" { 
            Write-Host ""
            Write-Host "Computer will enter Hibernate mode in 5 seconds..." -ForegroundColor Magenta
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Magenta
                Write-Host "User Choice: Hibernate Mode" -ForegroundColor Magenta
                Write-Host "===============================================================================" -ForegroundColor Magenta
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            # Enable hibernate and enter hibernation
            powercfg -hibernate on | Out-Null
            Write-Host "[SUCCESS] Hibernate mode command executed successfully!" -ForegroundColor Green
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Hibernate, $false, $false)
        }
        "6" { 
            Write-Host ""
            Write-Host "Computer will restart in 5 seconds..." -ForegroundColor Blue
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Blue
                Write-Host "User Choice: Reboot System" -ForegroundColor Blue
                Write-Host "===============================================================================" -ForegroundColor Blue
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            Write-Host "[SUCCESS] System reboot command executed successfully!" -ForegroundColor Green
            shutdown /r /t 0
        }
        "7" { 
            Write-Host ""
            Write-Host "Computer will soft reboot in 5 seconds..." -ForegroundColor DarkCyan
            for ($i = 4; $i -ge 1; $i--) {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor DarkCyan
                Write-Host "User Choice: Soft Reboot" -ForegroundColor DarkCyan
                Write-Host "===============================================================================" -ForegroundColor DarkCyan
                Write-Host ""
                Write-Host "Countdown: $i seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
            Write-Host "[SUCCESS] Soft reboot command executed successfully!" -ForegroundColor Green
            shutdown /r /soft /t 0
        }
        "8" { 
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor White
            Write-Host "                     CUSTOM COMMAND EXECUTION" -ForegroundColor White
            Write-Host "===============================================================================" -ForegroundColor White
            Write-Host ""
            Write-Host "Enter custom shutdown command parameters:" -ForegroundColor Yellow
            Write-Host "(example: /r /o /t 0 for restart to advanced options)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "------------------------------------------------------------------" -ForegroundColor White
            
            $customCmd = Read-Host "Command parameters (after 'shutdown ')"
            
            if ([string]::IsNullOrWhiteSpace($customCmd)) {
                Write-Host "No command entered. Returning to menu." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                Invoke-PowerManager
                return
            }
            
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor White
            Write-Host "User Choice: Custom Command" -ForegroundColor White
            Write-Host "Command to execute: shutdown $customCmd" -ForegroundColor Yellow
            Write-Host "===============================================================================" -ForegroundColor White
            Write-Host ""
            
            $confirm = Read-Host "Are you sure you want to execute this command? (Y/N)"
            
            if ($confirm.ToUpper() -eq "Y") {
                Write-Host "[SUCCESS] Custom shutdown command executed successfully!" -ForegroundColor Green
                shutdown $customCmd.Split(' ')
            } else {
                Invoke-PowerManager
                return
            }
        }
        "9" { 
            Show-MainMenu
            return
        }
        default { 
            Write-Host "Invalid selection. Returning to Power Manager menu." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Invoke-PowerManager
            return
        }
    }
}

# Windows Update Controller function
function Invoke-WindowsUpdateController {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                            WINDOWS UPDATE CONTROLLER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INDONESIA]==========================================" -ForegroundColor Cyan
    Write-Host "Script ini memerlukan WORKAROUND MANUAL agar dapat berfungsi dengan benar." -ForegroundColor White
    Write-Host "Sebelum melanjutkan, Anda HARUS menekan tombol" -ForegroundColor White
    Write-Host "'Pause updates for 1 week' secara manual di pengaturan Windows Update." -ForegroundColor White
    Write-Host ""
    Write-Host "Langkah ini penting karena Windows tidak akan menghentikan proses update" -ForegroundColor White
    Write-Host "hanya dengan mengubah registry melalui script." -ForegroundColor White 
    Write-Host "Setelah Anda selesai melakukan workaround manual, ketik: confirm" -ForegroundColor Green
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "[ENGLISH]==========================================" -ForegroundColor Cyan
    Write-Host "This script requires a MANUAL WORKAROUND to function properly." -ForegroundColor White
    Write-Host "Before proceeding, you MUST click 'Pause updates for 1 week' manually" -ForegroundColor White
    Write-Host "in the Windows Update settings." -ForegroundColor White
    Write-Host ""
    Write-Host "This step is crucial because Windows will not fully pause updates" -ForegroundColor White
    Write-Host "just by modifying the registry via script." -ForegroundColor White 
    Write-Host "Once you've clicked the pause update button, type: confirm" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $userInput = Read-Host "Type 'confirm' to continue or 'back' to return to main menu"
        
        if ($userInput.ToLower() -eq "confirm") {
            break
        } elseif ($userInput.ToLower() -eq "back") {
            Show-MainMenu
            return
        } else {
            Write-Host "Invalid input. Please type 'confirm' or 'back'." -ForegroundColor Red
            Write-Host ""
        }
    } while ($true)
    
    # Show Update Menu
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                            WINDOWS UPDATE CONTROLLER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Select pause duration for Windows Updates:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Pause for 1 week from today" -ForegroundColor White
    Write-Host "  [2] Pause until 2040 (Standard)" -ForegroundColor White
    Write-Host "  [3] Pause until 2199 (Maximum)" -ForegroundColor White
    Write-Host "  [4] Custom pause year" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option (0-4)"
    
    # Function to stop Windows Update service
    function Stop-WindowsUpdateService {
        Write-Host "Attempting to stop Windows Update service..." -ForegroundColor Yellow
        try {
            Stop-Service -Name "wuauserv" -Force -ErrorAction Stop
            Write-Host "Windows Update service successfully stopped." -ForegroundColor Green
        } catch {
            Write-Host "Failed to stop Windows Update service. It may already be stopped or there might be permission issues." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
        Write-Host ""
    }
    
    # Function to set registry values
    function Set-UpdateRegistryValues {
        param (
            [string]$ExpiryTime
        )
        
        $registryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
        
        try {
            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $registryPath -Name "PauseUpdatesExpiryTime" -Value $ExpiryTime -Force
            Set-ItemProperty -Path $registryPath -Name "PauseFeatureUpdatesEndTime" -Value $ExpiryTime -Force
            Set-ItemProperty -Path $registryPath -Name "PauseQualityUpdatesEndTime" -Value $ExpiryTime -Force
            
            return $true
        } catch {
            Write-Host "Failed to set registry values. Make sure you're running as Administrator." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            return $false
        }
    }
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "                          PAUSING UPDATES FOR 1 WEEK" -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            Stop-WindowsUpdateService
            
            $currentDate = Get-Date
            $targetDate = $currentDate.AddDays(7).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            
            Write-Host "Current date: $($currentDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
            Write-Host "Target date: $targetDate" -ForegroundColor Yellow
            Write-Host "Applying pause configuration..." -ForegroundColor White
            
            if (Set-UpdateRegistryValues -ExpiryTime $targetDate) {
                Write-Host "Windows Updates successfully paused for 1 week" -ForegroundColor Green
                Write-Host "Check Windows Settings > Update & Security to verify the pause status" -ForegroundColor Cyan
            }
        }
        "2" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "                         PAUSING UPDATES UNTIL 2040" -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            Stop-WindowsUpdateService
            
            $expiryTime = "2040-01-01T10:38:56Z"
            Write-Host "Target date: $expiryTime" -ForegroundColor Yellow
            Write-Host "Applying pause configuration..." -ForegroundColor White
            
            if (Set-UpdateRegistryValues -ExpiryTime $expiryTime) {
                Write-Host "Windows Updates successfully paused until 2040" -ForegroundColor Green
                Write-Host "Check Windows Settings > Update & Security to verify the pause status" -ForegroundColor Cyan
            }
        }
        "3" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "                         PAUSING UPDATES UNTIL 2199" -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            Stop-WindowsUpdateService
            
            $expiryTime = "2199-01-01T10:38:56Z"
            Write-Host "Target date: $expiryTime" -ForegroundColor Yellow
            Write-Host "Applying pause configuration..." -ForegroundColor White
            
            if (Set-UpdateRegistryValues -ExpiryTime $expiryTime) {
                Write-Host "Windows Updates successfully paused until 2199" -ForegroundColor Green
                Write-Host "Check Windows Settings > Update & Security to verify the pause status" -ForegroundColor Cyan
            }
        }
        "4" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "                           CUSTOM PAUSE YEAR" -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            do {
                $customYear = Read-Host "Enter target year (e.g., 2030)"
                
                # Validate year input
                if ([string]::IsNullOrWhiteSpace($customYear)) {
                    Write-Host "Year cannot be empty!" -ForegroundColor Red
                    continue
                }
                
                try {
                    $yearInt = [int]$customYear
                } catch {
                    Write-Host "Invalid input! Please enter numbers only." -ForegroundColor Red
                    continue
                }
                
                if ($yearInt -lt 2024) {
                    Write-Host "Year must be 2024 or later!" -ForegroundColor Red
                    continue
                }
                
                if ($yearInt -gt 2199) {
                    Write-Host "Maximum year is 2199!" -ForegroundColor Red
                    continue
                }
                
                break
            } while ($true)
            
            Stop-WindowsUpdateService
            
            $customDate = "$customYear-01-01T10:38:56Z"
            Write-Host "Target date: $customDate" -ForegroundColor Yellow
            Write-Host "Applying pause configuration..." -ForegroundColor White
            
            if (Set-UpdateRegistryValues -ExpiryTime $customDate) {
                Write-Host "Windows Updates successfully paused until $customYear" -ForegroundColor Green
                Write-Host "Check Windows Settings > Update & Security to verify the pause status" -ForegroundColor Cyan
            }
        }
        "0" {
            Show-MainMenu
            return
        }
        default {
            Write-Host "Invalid selection. Returning to main menu..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-MainMenu
            return
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Windows Update Controller completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# WiFi Profile Manager function
function Invoke-WiFiManager {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                          WIFI PROFILE MANAGER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Set backup folder to Public Desktop
    $publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
    $backupFolder = Join-Path $publicDesktop "winScriptOutput\SavedWifiBackups"
    
    # Get current WiFi profiles count
    $currentProfiles = (netsh wlan show profiles | Select-String "All User Profile" | Measure-Object).Count
    
    # Check backup count
    $backupCount = 0
    if (Test-Path $backupFolder) {
        $backupCount = (Get-ChildItem -Path $backupFolder -Filter "*.xml" | Measure-Object).Count
    }
    
    Write-Host "Current WiFi Networks: $currentProfiles" -ForegroundColor Cyan
    Write-Host "Saved WiFi Backups: $backupCount" -ForegroundColor Cyan
    if (Test-Path $backupFolder) {
        Write-Host "Backup Folder: $backupFolder\ [EXISTS]" -ForegroundColor Green
    } else {
        Write-Host "Backup Folder: $backupFolder\ [NOT CREATED]" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Backup WiFi Profiles" -ForegroundColor White
    Write-Host "[2] Restore All WiFi Profiles" -ForegroundColor White
    Write-Host "[3] View Saved Profiles" -ForegroundColor White
    Write-Host "[4] Remove All Current Profiles" -ForegroundColor White
    Write-Host "[5] Delete All Backups" -ForegroundColor White
    Write-Host "[0] Back to Main Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $choice = Read-Host "Select option (0-5)"
    
    switch ($choice) {
        "1" { Invoke-WiFiBackup -BackupFolder $backupFolder }
        "2" { Invoke-WiFiRestore -BackupFolder $backupFolder }
        "3" { Show-WiFiProfiles -BackupFolder $backupFolder }
        "4" { Remove-AllWiFiProfiles }
        "5" { Remove-AllBackups -BackupFolder $backupFolder }
        "0" { Show-MainMenu; return }
        default { 
            Write-Host "Invalid selection. Returning to WiFi Manager." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Invoke-WiFiManager
        }
    }
}

function Invoke-WiFiBackup {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "           Backing up WiFi Profiles..." -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-Path $BackupFolder)) {
        New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
        Write-Host "Created backup folder: $BackupFolder\" -ForegroundColor Green
        Write-Host ""
    }
    
    Push-Location $BackupFolder
    try {
        netsh wlan export profile key=clear
        $exportedCount = (Get-ChildItem -Filter "*.xml" | Measure-Object).Count
        
        Write-Host ""
        Write-Host "Backup completed successfully!" -ForegroundColor Green
        Write-Host "Exported $exportedCount WiFi profiles to $BackupFolder\" -ForegroundColor Cyan
    } catch {
        Write-Host "Error during backup: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Pop-Location
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to WiFi Manager  [0] Main Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Show-MainMenu } else { Invoke-WiFiManager }
}

function Invoke-WiFiRestore {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "          Restoring WiFi Profiles..." -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-Path $BackupFolder)) {
        Write-Host "Error: Backup folder not found! Please backup first." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $xmlCount = ($xmlFiles | Measure-Object).Count
    
    if ($xmlCount -eq 0) {
        Write-Host "No WiFi backup files found in $BackupFolder\" -ForegroundColor Red
        Write-Host "Please backup WiFi profiles first." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    Write-Host "Found $xmlCount WiFi profiles to restore." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "[Y] Continue with restore ALL profiles" -ForegroundColor White
    Write-Host "[N] Back to WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Yellow
    
    $confirm = Read-Host "Select option (Y/N)"
    
    if ($confirm.ToUpper() -eq "Y") {
        Write-Host ""
        Write-Host "Restoring profiles..." -ForegroundColor Green
        
        foreach ($file in $xmlFiles) {
            $profileName = $file.BaseName -replace "^Wi-Fi-", ""
            Write-Host "Importing: $profileName" -ForegroundColor Cyan
            try {
                netsh wlan add profile $file.FullName | Out-Null
            } catch {
                Write-Host "  Error importing $profileName" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "Restore completed successfully!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to WiFi Manager  [0] Main Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Show-MainMenu } else { Invoke-WiFiManager }
}

function Show-WiFiProfiles {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "            Saved WiFi Profiles" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-Path $BackupFolder)) {
        Write-Host "No backup folder found." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $profileCount = ($xmlFiles | Measure-Object).Count
    
    if ($profileCount -eq 0) {
        Write-Host "No saved WiFi profiles found." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    Write-Host "Total: $profileCount saved profiles" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] List All Profiles & View Password" -ForegroundColor White
    Write-Host "[2] Search WiFi by Name" -ForegroundColor White
    Write-Host "[3] Show All Passwords" -ForegroundColor White
    Write-Host "[4] Selective Restore" -ForegroundColor White
    Write-Host "[0] Back to WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option (0-4)"
    
    switch ($choice) {
        "1" { Show-ProfileList -BackupFolder $BackupFolder }
        "2" { Search-WiFiProfile -BackupFolder $BackupFolder }
        "3" { Show-AllPasswords -BackupFolder $BackupFolder }
        "4" { Invoke-SelectiveRestore -BackupFolder $BackupFolder }
        "0" { Invoke-WiFiManager }
        default { Show-WiFiProfiles -BackupFolder $BackupFolder }
    }
}

function Show-ProfileList {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "          Select WiFi Profile to View" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $profiles = @()
    
    for ($i = 0; $i -lt $xmlFiles.Count; $i++) {
        $profileName = $xmlFiles[$i].BaseName -replace "^Wi-Fi-", ""
        $profiles += $profileName
        Write-Host "[$($i+1)] $profileName" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "[0] Back to Profiles Menu" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $selection = Read-Host "Enter profile number (0-$($profiles.Count))"
    
    if ($selection -eq "0") {
        Show-WiFiProfiles -BackupFolder $BackupFolder
        return
    }
    
    try {
        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $profiles.Count) {
            Show-WiFiPassword -BackupFolder $BackupFolder -ProfileName $profiles[$index] -FileName $xmlFiles[$index].Name
        } else {
            Write-Host "Invalid selection!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-ProfileList -BackupFolder $BackupFolder
        }
    } catch {
        Write-Host "Invalid selection!" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Show-ProfileList -BackupFolder $BackupFolder
    }
}

function Show-WiFiPassword {
    param([string]$BackupFolder, [string]$ProfileName, [string]$FileName)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "          WiFi Profile: $ProfileName" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $xmlPath = Join-Path $BackupFolder $FileName
    $password = ""
    
    try {
        $content = Get-Content -Path $xmlPath -Raw
        if ($content -match '<keyMaterial>([^<]*)</keyMaterial>') {
            $password = $matches[1]
        }
    } catch {
        Write-Host "Error reading profile file." -ForegroundColor Red
    }
    
    Write-Host "WiFi Name: $ProfileName" -ForegroundColor Cyan
    if ([string]::IsNullOrWhiteSpace($password)) {
        Write-Host "Password: [No password / Open network]" -ForegroundColor Yellow
    } else {
        Write-Host "Password: $password" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] View Another Profile  [2] Back to Profiles Menu" -ForegroundColor White
    Write-Host "[0] Back to WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    switch ($choice) {
        "1" { Show-ProfileList -BackupFolder $BackupFolder }
        "2" { Show-WiFiProfiles -BackupFolder $BackupFolder }
        "0" { Invoke-WiFiManager }
        default { Show-WiFiPassword -BackupFolder $BackupFolder -ProfileName $ProfileName -FileName $FileName }
    }
}

function Show-AllPasswords {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "            All WiFi Passwords" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $displayCount = 0
    
    foreach ($file in $xmlFiles) {
        $displayCount++
        $profileName = $file.BaseName -replace "^Wi-Fi-", ""
        $password = ""
        
        try {
            $content = Get-Content -Path $file.FullName -Raw
            if ($content -match '<keyMaterial>([^<]*)</keyMaterial>') {
                $password = $matches[1]
            }
        } catch {
            $password = "[Error reading file]"
        }
        
        if ([string]::IsNullOrWhiteSpace($password)) {
            Write-Host "[$displayCount] $profileName : [No password / Open]" -ForegroundColor Yellow
        } else {
            Write-Host "[$displayCount] $profileName : $password" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "Showing $displayCount WiFi profiles" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to Profiles Menu  [0] WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Invoke-WiFiManager } else { Show-WiFiProfiles -BackupFolder $BackupFolder }
}

function Search-WiFiProfile {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "              Search WiFi Profile" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $searchTerm = Read-Host "Enter WiFi name to search (or 0 to go back)"
    
    if ($searchTerm -eq "0") {
        Show-WiFiProfiles -BackupFolder $BackupFolder
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($searchTerm)) {
        Write-Host "Please enter a search term!" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Search-WiFiProfile -BackupFolder $BackupFolder
        return
    }
    
    Write-Host ""
    Write-Host "Search results for: '$searchTerm'" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $foundProfiles = @()
    $foundCount = 0
    
    foreach ($file in $xmlFiles) {
        $profileName = $file.BaseName -replace "^Wi-Fi-", ""
        if ($profileName -like "*$searchTerm*") {
            $foundCount++
            $foundProfiles += @{ Name = $profileName; File = $file.Name }
            Write-Host "[$foundCount] $profileName" -ForegroundColor Green
        }
    }
    
    if ($foundCount -eq 0) {
        Write-Host "No profiles found containing '$searchTerm'" -ForegroundColor Red
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "[1] Search Again  [0] Back to Profiles Menu" -ForegroundColor White
        Write-Host "===============================================" -ForegroundColor Cyan
        
        $choice = Read-Host "Select option"
        if ($choice -eq "0") { Show-WiFiProfiles -BackupFolder $BackupFolder } else { Search-WiFiProfile -BackupFolder $BackupFolder }
    } else {
        Write-Host ""
        Write-Host "[0] Search Again" -ForegroundColor Yellow
        Write-Host "===============================================" -ForegroundColor Cyan
        
        $selection = Read-Host "Enter profile number to view (0-$foundCount)"
        
        if ($selection -eq "0") {
            Search-WiFiProfile -BackupFolder $BackupFolder
        } else {
            try {
                $index = [int]$selection - 1
                if ($index -ge 0 -and $index -lt $foundProfiles.Count) {
                    Show-WiFiPassword -BackupFolder $BackupFolder -ProfileName $foundProfiles[$index].Name -FileName $foundProfiles[$index].File
                } else {
                    Write-Host "Invalid selection!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                    Search-WiFiProfile -BackupFolder $BackupFolder
                }
            } catch {
                Write-Host "Invalid selection!" -ForegroundColor Red
                Start-Sleep -Seconds 2
                Search-WiFiProfile -BackupFolder $BackupFolder
            }
        }
    }
}

function Invoke-SelectiveRestore {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "            Selective WiFi Restore" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $xmlFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $profiles = @()
    
    for ($i = 0; $i -lt $xmlFiles.Count; $i++) {
        $profileName = $xmlFiles[$i].BaseName -replace "^Wi-Fi-", ""
        $profiles += @{ Name = $profileName; File = $xmlFiles[$i] }
        Write-Host "[$($i+1)] $profileName" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "Enter profile numbers separated by commas" -ForegroundColor Yellow
    Write-Host "Example: 1,3,5,7 or 2,4,6" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[0] Back to Profiles Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $selection = Read-Host "Enter numbers"
    
    if ($selection -eq "0") {
        Show-WiFiProfiles -BackupFolder $BackupFolder
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($selection)) {
        Write-Host "Please enter at least one number!" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Invoke-SelectiveRestore -BackupFolder $BackupFolder
        return
    }
    
    Write-Host ""
    Write-Host "Restoring selected profiles..." -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $numbers = $selection.Split(',')
    $restoredCount = 0
    
    foreach ($numStr in $numbers) {
        $num = $numStr.Trim()
        try {
            $index = [int]$num - 1
            if ($index -ge 0 -and $index -lt $profiles.Count) {
                $profile = $profiles[$index]
                Write-Host "Restoring [$num]: $($profile.Name)" -ForegroundColor Cyan
                netsh wlan add profile $profile.File.FullName | Out-Null
                $restoredCount++
            } else {
                Write-Host "Invalid number: $num (skipped)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Invalid number: $num (skipped)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "Selective restore completed!" -ForegroundColor Green
    Write-Host "Restored $restoredCount WiFi profiles." -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to Profiles Menu  [0] WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Invoke-WiFiManager } else { Show-WiFiProfiles -BackupFolder $BackupFolder }
}

function Remove-AllWiFiProfiles {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "         Remove All Current WiFi Profiles" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host ""
    
    $currentProfiles = (netsh wlan show profiles | Select-String "All User Profile" | Measure-Object).Count
    
    Write-Host "This will remove ALL WiFi profiles from your system!" -ForegroundColor Yellow
    Write-Host "Current WiFi Networks: $currentProfiles" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "[Y] Remove ALL profiles  [N] Back to WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Red
    
    $confirm = Read-Host "Select option (Y/N)"
    
    if ($confirm.ToUpper() -eq "Y") {
        Write-Host ""
        Write-Host "Removing all WiFi profiles..." -ForegroundColor Red
        
        $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
            ($_ -split ":")[1].Trim()
        }
        
        foreach ($profile in $profiles) {
            Write-Host "Removing: $profile" -ForegroundColor Yellow
            try {
                netsh wlan delete profile name="$profile" | Out-Null
            } catch {
                Write-Host "  Error removing $profile" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "All WiFi profiles removed successfully!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to WiFi Manager  [0] Main Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Show-MainMenu } else { Invoke-WiFiManager }
}

function Remove-AllBackups {
    param([string]$BackupFolder)
    
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "            Delete All Backups" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host ""
    
    if (-not (Test-Path $BackupFolder)) {
        Write-Host "No backup folder found." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    $backupFiles = Get-ChildItem -Path $BackupFolder -Filter "*.xml"
    $deleteCount = ($backupFiles | Measure-Object).Count
    
    if ($deleteCount -eq 0) {
        Write-Host "No backup files to delete." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to WiFi Manager"
        Invoke-WiFiManager
        return
    }
    
    Write-Host "Found $deleteCount backup files." -ForegroundColor Cyan
    Write-Host "This will permanently delete all WiFi backup files!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "[Y] Delete all backups  [N] Back to WiFi Manager" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Red
    
    $confirm = Read-Host "Select option (Y/N)"
    
    if ($confirm.ToUpper() -eq "Y") {
        try {
            Remove-Item -Path "$BackupFolder\*.xml" -Force
            Write-Host ""
            Write-Host "All backup files deleted successfully!" -ForegroundColor Green
        } catch {
            Write-Host ""
            Write-Host "Error deleting backup files: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "[1] Back to WiFi Manager  [0] Main Menu" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option"
    if ($choice -eq "0") { Show-MainMenu } else { Invoke-WiFiManager }
}

# TTL Bypass Tool function
function Invoke-TTLBypass {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                            TTL BYPASS TOOL" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Get current TTL values
    function Get-CurrentTTL {
        $currentTTL_IPv4 = "N/A"
        $currentTTL_IPv6 = "N/A"
        
        try {
            $ipv4Output = netsh int ipv4 show global | Select-String "Default Hop Limit"
            if ($ipv4Output) {
                $currentTTL_IPv4 = ($ipv4Output.ToString() -split ":")[1].Trim()
            }
        } catch {
            $currentTTL_IPv4 = "Tidak ditemukan"
        }
        
        try {
            $ipv6Output = netsh int ipv6 show global | Select-String "Default Hop Limit"
            if ($ipv6Output) {
                $currentTTL_IPv6 = ($ipv6Output.ToString() -split ":")[1].Trim()
            }
        } catch {
            $currentTTL_IPv6 = "Tidak ditemukan"
        }
        
        return @{ IPv4 = $currentTTL_IPv4; IPv6 = $currentTTL_IPv6 }
    }
    
    $ttlValues = Get-CurrentTTL
    
    Write-Host "                Windows TTL Editor ~ Unlock Tethering Throttle!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  NOTE: saat windows di reboot, Settingan TTL akan otomatis menjadi default" -ForegroundColor Cyan
    Write-Host "  TTL Hop Limit Saat Ini:" -ForegroundColor White
    Write-Host "    IPv4 : $($ttlValues.IPv4)" -ForegroundColor Green
    Write-Host "    IPv6 : $($ttlValues.IPv6)" -ForegroundColor Green
    Write-Host ""
    Write-Host "----------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  Pilih salah satu opsi di bawah ini:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    [1] Set TTL Hop Limit ke 65 (Bypass Tethering)" -ForegroundColor White
    Write-Host "    [2] Set TTL Hop Limit ke Default Windows (128)" -ForegroundColor White
    Write-Host "    [3] Set TTL Hop Limit ke Angka Custom" -ForegroundColor White
    Write-Host "    [4] Batal / Keluar" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Tekan tombol angka untuk memilih opsi (1-4)"
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "         MENGATUR TTL HOP LIMIT KE 65..." -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            try {
                netsh int ipv4 set glob defaultcurhoplimit=65 | Out-Null
                netsh int ipv6 set glob defaultcurhoplimit=65 | Out-Null
                Write-Host "TTL Hop Limit berhasil diatur ke 65 (Bypass Tethering)." -ForegroundColor Green
            } catch {
                Write-Host "Error setting TTL: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            Write-Host "Kembali ke menu utama..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            Invoke-TTLBypass
        }
        "2" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host "         MENGATUR TTL HOP LIMIT KE DEFAULT (128)..." -ForegroundColor Green
            Write-Host "===============================================================================" -ForegroundColor Green
            Write-Host ""
            
            try {
                netsh int ipv4 set glob defaultcurhoplimit=128 | Out-Null
                netsh int ipv6 set glob defaultcurhoplimit=128 | Out-Null
                Write-Host "TTL Hop Limit berhasil diatur ke 128 (Default Windows)." -ForegroundColor Green
            } catch {
                Write-Host "Error setting TTL: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            Write-Host "Kembali ke menu utama..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            Invoke-TTLBypass
        }
        "3" {
            Clear-Host
            Write-Host "===============================================================================" -ForegroundColor Cyan
            Write-Host "            SET TTL HOP LIMIT CUSTOM" -ForegroundColor Cyan
            Write-Host "===============================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Masukkan nilai TTL yang diinginkan (1-255):" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Contoh nilai umum:" -ForegroundColor White
            Write-Host "    - 64  : Linux/Android default" -ForegroundColor Cyan
            Write-Host "    - 65  : Bypass tethering" -ForegroundColor Cyan
            Write-Host "    - 128 : Windows default" -ForegroundColor Cyan
            Write-Host "    - 255 : Maximum value" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "----------------------------------------------------------" -ForegroundColor Gray
            
            do {
                $customTTL = Read-Host "Masukkan nilai TTL (1-255) atau ketik 'back' untuk kembali"
                
                if ($customTTL.ToLower() -eq "back" -or $customTTL.ToLower() -eq "b") {
                    Invoke-TTLBypass
                    return
                }
                
                if ([string]::IsNullOrWhiteSpace($customTTL)) {
                    Write-Host ""
                    Write-Host "Error: Nilai tidak boleh kosong!" -ForegroundColor Red
                    Write-Host ""
                    continue
                }
                
                try {
                    $ttlInt = [int]$customTTL
                } catch {
                    Write-Host ""
                    Write-Host "Error: Masukkan hanya angka!" -ForegroundColor Red
                    Write-Host ""
                    continue
                }
                
                if ($ttlInt -lt 1) {
                    Write-Host ""
                    Write-Host "Error: Nilai TTL harus minimal 1!" -ForegroundColor Red
                    Write-Host ""
                    continue
                }
                
                if ($ttlInt -gt 255) {
                    Write-Host ""
                    Write-Host "Error: Nilai TTL maksimal 255!" -ForegroundColor Red
                    Write-Host ""
                    continue
                }
                
                break
            } while ($true)
            
            Write-Host ""
            Write-Host "----------------------------------------------------------" -ForegroundColor Gray
            Write-Host "  Anda akan mengatur TTL Hop Limit ke: $customTTL" -ForegroundColor Yellow
            Write-Host "----------------------------------------------------------" -ForegroundColor Gray
            Write-Host ""
            
            $confirm = Read-Host "Lanjutkan? (Y/N)"
            
            if ($confirm.ToUpper() -eq "Y") {
                Clear-Host
                Write-Host "===============================================================================" -ForegroundColor Green
                Write-Host "         MENGATUR TTL HOP LIMIT KE $customTTL..." -ForegroundColor Green
                Write-Host "===============================================================================" -ForegroundColor Green
                Write-Host ""
                
                try {
                    Write-Host "Mengatur TTL IPv4 ke $customTTL..." -ForegroundColor Cyan
                    netsh int ipv4 set glob defaultcurhoplimit=$customTTL | Out-Null
                    Write-Host ""
                    Write-Host "Mengatur TTL IPv6 ke $customTTL..." -ForegroundColor Cyan
                    netsh int ipv6 set glob defaultcurhoplimit=$customTTL | Out-Null
                    Write-Host ""
                    Write-Host "TTL Hop Limit berhasil diatur ke $customTTL." -ForegroundColor Green
                } catch {
                    Write-Host "Error setting TTL: $($_.Exception.Message)" -ForegroundColor Red
                }
                
                Write-Host "Kembali ke menu utama..." -ForegroundColor Cyan
                Start-Sleep -Seconds 3
                Invoke-TTLBypass
            } else {
                Invoke-TTLBypass
            }
        }
        "4" {
            Show-MainMenu
            return
        }
        default {
            Write-Host "Input tidak dikenal, kembali ke menu secara otomatis." -ForegroundColor Red
            Start-Sleep -Seconds 1
            Invoke-TTLBypass
        }
    }
}

# OneDrive Switcher function
function Invoke-OneDriveSwitcher {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                            ONEDRIVE SWITCHER" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check OneDrive policy status
    function Get-OneDriveStatus {
        try {
            $policyPath = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"
            $disablePolicy = Get-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue
            if ($disablePolicy -and $disablePolicy.DisableFileSyncNGSC -eq 1) {
                return "DISABLED"
            } else {
                return "ENABLED"
            }
        } catch {
            return "ENABLED"
        }
    }
    
    $status = Get-OneDriveStatus
    Write-Host "Current OneDrive Status: $status" -ForegroundColor $(if ($status -eq "ENABLED") { "Green" } else { "Red" })
    Write-Host ""
    
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Select OneDrive Action:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Disable OneDrive" -ForegroundColor Red
    Write-Host "  [2] Enable OneDrive" -ForegroundColor Green
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select option (0-2)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "[DISABLE] Menonaktifkan OneDrive..." -ForegroundColor Yellow
            
            try {
                # Add policy to block synchronization
                $policyPath = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"
                if (-not (Test-Path $policyPath)) {
                    New-Item -Path $policyPath -Force | Out-Null
                }
                Set-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force
                
                # Refresh policy
                Write-Host "Refreshing Group Policy..." -ForegroundColor Cyan
                & gpupdate /force | Out-Null
                
                Write-Host "[SUCCESS] OneDrive dinonaktifkan. Reboot untuk efek penuh." -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] Failed to disable OneDrive: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            Write-Host ""
            Write-Host "[ENABLE] Mengaktifkan OneDrive..." -ForegroundColor Yellow
            
            try {
                # Remove policy that blocks synchronization
                $policyPath = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"
                if (Test-Path $policyPath) {
                    Remove-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue
                    
                    # Optional: remove key if empty
                    try {
                        Remove-Item -Path $policyPath -Force -ErrorAction SilentlyContinue | Out-Null
                    } catch {
                        # Key might not be empty, ignore error
                    }
                }
                
                # Refresh policy
                Write-Host "Refreshing Group Policy..." -ForegroundColor Cyan
                & gpupdate /force | Out-Null
                
                # Restart Explorer
                Write-Host "Restarting Explorer..." -ForegroundColor Cyan
                Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
                Start-Process -FilePath "explorer.exe"
                
                Write-Host "[SUCCESS] OneDrive seharusnya aktif setelah reboot." -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] Failed to enable OneDrive: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "0" {
            Show-MainMenu
            return
        }
        default {
            Write-Host "Invalid selection. Returning to OneDrive Switcher." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Invoke-OneDriveSwitcher
            return
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "OneDrive Switcher completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# Windows Activator function
function Invoke-WindowsActivator {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                        WINDOWS & OFFICE ACTIVATOR" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "This tool will activate Windows and Microsoft Office using the" -ForegroundColor White
    Write-Host "Microsoft Activation Scripts (MAS) by massgravel." -ForegroundColor White
    Write-Host "" 
    Write-Host "WARNING: This will download and execute a remote PowerShell script." -ForegroundColor Yellow
    Write-Host "Make sure you understand the risks before proceeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Source: https://github.com/massgravel/Microsoft-Activation-Scripts" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $confirm = Read-Host "Continue? (Y/N)"
    
    if ($confirm.ToUpper() -ne "Y") {
        Show-MainMenu
        return
    }
    
    Write-Host ""
    Write-Host "Launching Windows Activator..." -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Cyan
    
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://get.activated.win")
    } catch {
        Write-Host "" 
        Write-Host "Error launching Windows Activator: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Windows Activator process completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# WinUtils by ChrisTitusTech function
function Invoke-WinUtils {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                   WINUTILS BY CHRISTITUSTECH" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "This tool provides various Windows optimization and debloating utilities" -ForegroundColor White
    Write-Host "created by Chris Titus Tech." -ForegroundColor White
    Write-Host ""
    Write-Host "Features:" -ForegroundColor Yellow
    Write-Host "  - Install/Remove Windows features and applications" -ForegroundColor White
    Write-Host "  - Windows optimization tweaks" -ForegroundColor White
    Write-Host "  - System debloating and cleanup" -ForegroundColor White
    Write-Host "  - Privacy settings configuration" -ForegroundColor White
    Write-Host ""
    Write-Host "WARNING: This will download and execute a remote PowerShell script." -ForegroundColor Yellow
    Write-Host "Make sure you understand the risks before proceeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Source: https://github.com/ChrisTitusTech/winutil" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $confirm = Read-Host "Continue? (Y/N)"
    
    if ($confirm.ToUpper() -ne "Y") {
        Show-MainMenu
        return
    }
    
    Write-Host ""
    Write-Host "Launching WinUtils..." -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Cyan
    
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://christitus.com/win")
    } catch {
        Write-Host ""
        Write-Host "Error launching WinUtils: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "WinUtils process completed. Press any key to return to main menu..." -ForegroundColor White
    Read-Host
    Show-MainMenu
}

# Help function
function Show-Help {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "                                HELP & TOOL INFORMATION" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  DETAILED TOOL DESCRIPTIONS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [1] System Cache Cleaner" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Cleans temporary files from user and system directories" -ForegroundColor White
    Write-Host "      • Removes browser cache (Chrome, Firefox, Edge)" -ForegroundColor White
    Write-Host "      • Clears prefetch files and recent items" -ForegroundColor White
    Write-Host "      • Optionally empties Recycle Bin (Deep Clean mode)" -ForegroundColor White
    Write-Host "      • Creates detailed log files of cleaned items" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [2] Chrome Policy Remover" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Removes Chrome management policies and restrictions" -ForegroundColor White
    Write-Host "      • Clears 'Managed by your organization' settings" -ForegroundColor White
    Write-Host "      • Removes Chrome registry entries and policy files" -ForegroundColor White
    Write-Host "      • Clears Chrome preferences that retain policy settings" -ForegroundColor White
    Write-Host "      • Requires Chrome to be closed before execution" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [3] Power Management Suite" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Advanced shutdown options (normal, forced)" -ForegroundColor White
    Write-Host "      • System restart with various modes (normal, soft, UEFI)" -ForegroundColor White
    Write-Host "      • Sleep and hibernation modes" -ForegroundColor White
    Write-Host "      • Custom shutdown command execution" -ForegroundColor White 
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [4] Windows Update Controller" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Pause Windows Updates until a specified year (default: 2040)" -ForegroundColor White
    Write-Host "      • Custom year selection for update delays" -ForegroundColor White
    Write-Host "      • Stops Windows Update service" -ForegroundColor White
    Write-Host "      • Modifies registry settings for update control" -ForegroundColor White
    Write-Host "      • Requires manual 'Pause for 1 week' button click first" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [5] WiFi Profile Manager" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Backup all WiFi profiles with passwords" -ForegroundColor White
    Write-Host "      • Restore WiFi profiles from backups" -ForegroundColor White
    Write-Host "      • View saved WiFi profiles and passwords" -ForegroundColor White
    Write-Host "      • Selective restoration of specific profiles" -ForegroundColor White
    Write-Host "      • Search WiFi profiles by name" -ForegroundColor White
    Write-Host "      • Remove all current WiFi profiles" -ForegroundColor White
    Write-Host "      • Comprehensive profile management system" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [6] TTL Bypass Tool" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Modify TTL (Time To Live) settings for IPv4 and IPv6" -ForegroundColor White
    Write-Host "      • Bypass tethering throttling restrictions" -ForegroundColor White
    Write-Host "      • Set TTL to common values (65, 128) or custom values" -ForegroundColor White
    Write-Host "      • Real-time TTL value display" -ForegroundColor White
    Write-Host "      • Supports values from 1-255 with input validation" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [7] OneDrive Switcher" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Simple OneDrive enable/disable functionality" -ForegroundColor White
    Write-Host "      • Uses Windows Group Policy for system-wide control" -ForegroundColor White
    Write-Host "      • Automatic policy refresh and Explorer restart" -ForegroundColor White
    Write-Host "      • Real-time OneDrive status monitoring" -ForegroundColor White
    Write-Host "      • Requires reboot for full effect" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [8] Windows Activator (Microsoft Activation Scripts)" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Activate Windows and Microsoft Office products" -ForegroundColor White
    Write-Host "      • Uses Microsoft Activation Scripts (MAS) by massgravel" -ForegroundColor White
    Write-Host "      • Supports multiple activation methods" -ForegroundColor White
    Write-Host "      • Open-source and regularly maintained" -ForegroundColor White
    Write-Host "      • Source: https://github.com/massgravel/Microsoft-Activation-Scripts" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  [9] WinUtils by ChrisTitusTech" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "      • Comprehensive Windows optimization utility" -ForegroundColor White
    Write-Host "      • Install/Remove Windows features and applications" -ForegroundColor White
    Write-Host "      • System debloating and cleanup tools" -ForegroundColor White
    Write-Host "      • Privacy settings configuration" -ForegroundColor White
    Write-Host "      • Performance optimization tweaks" -ForegroundColor White
    Write-Host "      • Source: https://github.com/ChrisTitusTech/winutil" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  SYSTEM REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "  • Windows 10/11 (Administrator privileges required)" -ForegroundColor White
    Write-Host "  • PowerShell 5.1 or later" -ForegroundColor White
    Write-Host "  • Network adapter with WiFi support (for WiFi Manager)" -ForegroundColor White
    Write-Host ""
    Write-Host "  SAFETY NOTES:" -ForegroundColor Yellow
    Write-Host "  • Always backup important data before using system modification tools" -ForegroundColor White
    Write-Host "  • These tools modify system settings and may require system restart" -ForegroundColor White
    Write-Host "  • Some corporate/domain policies may override these modifications" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter to return to main menu"
    Show-MainMenu
}

# Exit function
function Exit-Launcher {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host "                    EXITING WINDOWS SCRIPT LAUNCHER" -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Thank you for using the Windows Script Launcher!" -ForegroundColor Cyan
    Write-Host "Closing in 2 seconds..." -ForegroundColor White
    Start-Sleep -Seconds 2
    exit 0
}

# Main execution starts here
Show-MainMenu
