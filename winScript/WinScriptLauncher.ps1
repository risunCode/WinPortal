# Windows Script Launcher - PowerShell Edition
# Version: 2.0
# Compatible with PowerShell 5.1+ and PowerShell Core
# Can be run online via: iex (irm 'your-url/WinScriptLauncher.ps1')

param(
    [switch]$Online,
    [string]$WorkingDirectory = $PSScriptRoot
)

# Set console properties
if ($Host.Name -eq "ConsoleHost") {
    try {
        $Host.UI.RawUI.WindowTitle = "Windows Script Launcher - PowerShell Edition"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Yellow"
        Clear-Host
    } catch {
        # Ignore errors in non-console environments
    }
}

# Global variables
$script:LauncherPath = if ($Online) { $env:TEMP } else { $WorkingDirectory }
$script:IsOnlineMode = $Online
$script:OutputFolder = "$env:PUBLIC\Desktop\winScriptOutput"

# Ensure output folder exists
function Initialize-OutputFolder {
    if (-not (Test-Path $script:OutputFolder)) {
        try {
            New-Item -ItemType Directory -Path $script:OutputFolder -Force | Out-Null
            Write-Host "✓ Created output folder: $script:OutputFolder" -ForegroundColor Green
        } catch {
            Write-Host "✗ Error creating output folder: $($_.Exception.Message)" -ForegroundColor Red
            $script:OutputFolder = $env:TEMP
        }
    }
}

# Ensure we're running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Administrator {
    if (-not (Test-Administrator)) {
        Write-Host "===============================================================================" -ForegroundColor Red
        Write-Host "                    ADMINISTRATOR PRIVILEGES REQUIRED" -ForegroundColor Red
        Write-Host "===============================================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "This launcher requires administrator privileges to execute scripts properly." -ForegroundColor White
        Write-Host "Most tools need elevated permissions to modify system settings," -ForegroundColor White
        Write-Host "manage Windows services, and perform system-level operations." -ForegroundColor White
        Write-Host ""
        Write-Host "Attempting to restart with administrator privileges..." -ForegroundColor Yellow
        Write-Host ""
        
        if ($script:IsOnlineMode) {
            Write-Host "Please restart PowerShell as Administrator and run the script again." -ForegroundColor Red
            Write-Host "Press any key to exit..." -ForegroundColor White
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        } else {
            try {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
                exit 0
            } catch {
                Write-Host "Failed to restart with administrator privileges." -ForegroundColor Red
                Write-Host "Please right-click PowerShell and select 'Run as Administrator'." -ForegroundColor Yellow
                Write-Host "Press any key to exit..." -ForegroundColor White
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit 1
            }
        }
    }
}

# Main Menu Function
function Show-MainMenu {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                           WINDOWS SCRIPT LAUNCHER" -ForegroundColor Green
    Write-Host "                              PowerShell Edition" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    if ($script:IsOnlineMode) {
        Write-Host "  🌐 ONLINE MODE - Scripts will be downloaded and executed" -ForegroundColor Cyan
        Write-Host ""
    }
    Write-Host "  📁 Output Folder: $script:OutputFolder" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] System Cache Cleaner      - Clean temp files and browser cache" -ForegroundColor White
    Write-Host "  [2] Chrome Policy Remover     - Remove Chrome management policies" -ForegroundColor White  
    Write-Host "  [3] Power Management Suite    - Shutdown, restart, and power options" -ForegroundColor White
    Write-Host "  [4] Windows Update Controller - Delay or pause Windows updates" -ForegroundColor White
    Write-Host "  [5] WiFi Profile Manager      - Backup, restore, and manage WiFi profiles" -ForegroundColor White
    Write-Host "  [6] TTL Bypass Tool           - Modify TTL settings for tethering bypass" -ForegroundColor White
    Write-Host "" 
    Write-Host "  [R] Refresh Menu    [H] Help / About    [Q] Quit Launcher" -ForegroundColor Gray
    Write-Host "===============================================================================" -ForegroundColor Green
    
    $choice = Read-Host "Select option"
    
    switch ($choice.ToLower()) {
        '1' { Invoke-CacheCleaner }
        '2' { Invoke-ChromePolicyRemover }
        '3' { Invoke-PowerManager }
        '4' { Invoke-WindowsUpdateController }
        '5' { Invoke-WiFiManager }
        '6' { Invoke-TTLBypass }
        'r' { Show-MainMenu }
        'h' { Show-Help }
        'q' { Exit-Launcher }
        default { 
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-MainMenu 
        }
    }
}

# System Cache Cleaner
function Invoke-CacheCleaner {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                           SYSTEM CACHE CLEANER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    if ($script:IsOnlineMode) {
        Write-Host "Online mode - executing cache cleaning directly..." -ForegroundColor Yellow
        Write-Host ""
        
        # Initialize output folder
        Initialize-OutputFolder
        
        # Create log file
        $logFile = Join-Path $script:OutputFolder "CacheClean_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $logContent = @()
        $logContent += "==============================================="
        $logContent += "           Windows System Cleanup Log"
        $logContent += "           Date: $(Get-Date)"
        $logContent += "==============================================="
        $logContent += ""
        
        # Direct PowerShell implementation of cache cleaning
        Write-Host "Cleaning User temp files..." -ForegroundColor White
        try {
            $userTempFiles = Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue
            $userTempCount = ($userTempFiles | Measure-Object).Count
            $userTempFiles | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ User temp files cleaned ($userTempCount items)" -ForegroundColor Green
            $logContent += "User temp files cleaned: $userTempCount items"
        } catch {
            Write-Host "✗ Error cleaning user temp files" -ForegroundColor Red
            $logContent += "Error cleaning user temp files: $($_.Exception.Message)"
        }
        
        Write-Host "Cleaning Windows temp files..." -ForegroundColor White
        try {
            $winTempFiles = Get-ChildItem -Path "$env:WINDIR\temp" -Recurse -Force -ErrorAction SilentlyContinue
            $winTempCount = ($winTempFiles | Measure-Object).Count
            $winTempFiles | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Windows temp files cleaned ($winTempCount items)" -ForegroundColor Green
            $logContent += "Windows temp files cleaned: $winTempCount items"
        } catch {
            Write-Host "✗ Error cleaning Windows temp files" -ForegroundColor Red
            $logContent += "Error cleaning Windows temp files: $($_.Exception.Message)"
        }
        
        Write-Host "Cleaning Prefetch files..." -ForegroundColor White
        try {
            $prefetchFiles = Get-ChildItem -Path "$env:WINDIR\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue
            $prefetchCount = ($prefetchFiles | Measure-Object).Count
            $prefetchFiles | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Prefetch files cleaned ($prefetchCount items)" -ForegroundColor Green
            $logContent += "Prefetch files cleaned: $prefetchCount items"
        } catch {
            Write-Host "✗ Error cleaning prefetch files" -ForegroundColor Red
            $logContent += "Error cleaning prefetch files: $($_.Exception.Message)"
        }
        
        # Save log file
        $logContent += ""
        $logContent += "-------------------------------------------------------"
        $logContent += "         Cleanup completed !!!"
        $logContent += "-------------------------------------------------------"
        $logContent | Out-File -FilePath $logFile -Encoding UTF8
        Write-Host ""
        Write-Host "✓ Log file saved: $logFile" -ForegroundColor Cyan
        
    } else {
        $scriptPath = Join-Path $script:LauncherPath "CacheCleaner\wintrace_cleaner.bat"
        if (Test-Path $scriptPath) {
            & cmd.exe /c $scriptPath
        } else {
            Write-Host "ERROR: Script file not found - CacheCleaner\wintrace_cleaner.bat" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "Cache Cleaner completed. Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

# Chrome Policy Remover
function Invoke-ChromePolicyRemover {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                          CHROME POLICY REMOVER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    if ($script:IsOnlineMode) {
        Write-Host "Online mode - executing Chrome policy removal directly..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "WARNING: This will forcefully remove Chrome policies and settings." -ForegroundColor Red
        Write-Host "Please close Chrome before continuing." -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Continue? (Y/N)"
        
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Write-Host "Stopping Chrome processes..." -ForegroundColor White
            try {
                Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                Write-Host "✓ Chrome processes stopped" -ForegroundColor Green
            } catch {
                Write-Host "✓ Chrome not running" -ForegroundColor Green
            }
            
            Write-Host "Removing Chrome registry keys..." -ForegroundColor White
            $registryPaths = @(
                "HKCU:\Software\Google\Chrome",
                "HKCU:\Software\Policies\Google\Chrome",
                "HKLM:\Software\Google\Chrome",
                "HKLM:\Software\Policies\Google\Chrome",
                "HKLM:\Software\Policies\Google\Update"
            )
            
            foreach ($path in $registryPaths) {
                try {
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "✓ Removed: $path" -ForegroundColor Green
                } catch {
                    Write-Host "- Not found: $path" -ForegroundColor Gray
                }
            }
            
            Write-Host "Removing Chrome policies directory..." -ForegroundColor White
            $policiesDir = "${env:ProgramFiles(x86)}\Google\Policies"
            if (Test-Path $policiesDir) {
                try {
                    Remove-Item -Path $policiesDir -Recurse -Force
                    Write-Host "✓ Policies directory removed" -ForegroundColor Green
                } catch {
                    Write-Host "✗ Error removing policies directory" -ForegroundColor Red
                }
            } else {
                Write-Host "- Policies directory not found" -ForegroundColor Gray
            }
        }
    } else {
        $scriptPath = Join-Path $script:LauncherPath "ChromePolicy\Chrome_Policy_Remover.bat"
        if (Test-Path $scriptPath) {
            & cmd.exe /c $scriptPath
        } else {
            Write-Host "ERROR: Script file not found - ChromePolicy\Chrome_Policy_Remover.bat" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "Chrome Policy Remover completed. Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

# Power Manager
function Invoke-PowerManager {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                          POWER MANAGEMENT SUITE" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    if ($script:IsOnlineMode) {
        Write-Host "Select power option:" -ForegroundColor White
        Write-Host ""
        Write-Host "[1] Shutdown (Normal)" -ForegroundColor White
        Write-Host "[2] Shutdown (Forced)" -ForegroundColor White
        Write-Host "[3] Restart (Normal)" -ForegroundColor White
        Write-Host "[4] Restart (Forced)" -ForegroundColor White
        Write-Host "[5] Sleep Mode" -ForegroundColor White
        Write-Host "[6] Hibernate" -ForegroundColor White
        Write-Host "[0] Back to Main Menu" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            '1' { 
                Write-Host "Shutting down system in 5 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                Stop-Computer -Force 
            }
            '2' { 
                Write-Host "Force shutting down system..." -ForegroundColor Red
                Stop-Computer -Force 
            }
            '3' { 
                Write-Host "Restarting system in 5 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                Restart-Computer -Force 
            }
            '4' { 
                Write-Host "Force restarting system..." -ForegroundColor Red
                Restart-Computer -Force 
            }
            '5' { 
                Write-Host "Entering sleep mode..." -ForegroundColor Yellow
                rundll32.exe powrprof.dll,SetSuspendState 0,1,0 
            }
            '6' { 
                Write-Host "Entering hibernate mode..." -ForegroundColor Yellow
                shutdown /h 
            }
            '0' { Show-MainMenu }
            default { 
                Write-Host "Invalid selection." -ForegroundColor Red
                Start-Sleep -Seconds 2
                Invoke-PowerManager 
            }
        }
    } else {
        $scriptPath = Join-Path $script:LauncherPath "PowerManager\NewShutdown.bat"
        if (Test-Path $scriptPath) {
            & cmd.exe /c $scriptPath
        } else {
            Write-Host "ERROR: Script file not found - PowerManager\NewShutdown.bat" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "Power Manager completed. Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

# Windows Update Controller
function Invoke-WindowsUpdateController {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                            WINDOWS UPDATE CONTROLLER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host "[WARNING] [PERINGATAN]" -ForegroundColor Red
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Script ini memerlukan WORKAROUND MANUAL agar dapat berfungsi dengan benar." -ForegroundColor White
    Write-Host "This script requires a MANUAL WORKAROUND to function properly." -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[BAHASA INDONESIA]" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Sebelum melanjutkan, Anda HARUS menekan tombol" -ForegroundColor White
    Write-Host "`"Pause updates for 1 week`" secara manual di pengaturan Windows Update." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Langkah ini penting karena Windows tidak akan menghentikan proses update" -ForegroundColor White
    Write-Host "hanya dengan mengubah registry melalui script." -ForegroundColor White
    Write-Host ""
    Write-Host "Setelah Anda menekan tombol tersebut, ketik: confirm" -ForegroundColor Green
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[ENGLISH]" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Before proceeding, you MUST click `"Pause updates for 1 week`" manually" -ForegroundColor White
    Write-Host "in the Windows Update settings." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This step is crucial because Windows will not fully pause updates" -ForegroundColor White
    Write-Host "just by modifying the registry via script." -ForegroundColor White
    Write-Host ""
    Write-Host "Once you've clicked the button, type: confirm" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $userInput = Read-Host "Type 'confirm' to continue or 'back' to return to main menu"
        
        if ($userInput.ToLower() -eq 'confirm') {
            Show-WindowsUpdateMenu
            break
        } elseif ($userInput.ToLower() -eq 'back') {
            Show-MainMenu
            break
        } else {
            Write-Host "Invalid input. Please type 'confirm' or 'back'." -ForegroundColor Red
            Write-Host ""
        }
    } while ($true)
}

function Show-WindowsUpdateMenu {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                            WINDOWS UPDATE CONTROLLER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Select pause duration for Windows Updates:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Pause for 1 week from today" -ForegroundColor White
    Write-Host "  [2] Pause until 2040 (Standard)" -ForegroundColor White
    Write-Host "  [3] Pause until 2199 (Maximum)" -ForegroundColor White
    Write-Host "  [4] Custom pause year" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    
    $choice = Read-Host "Select option"
    
    switch ($choice) {
        '1' { Set-WindowsUpdatePause -Days 7 }
        '2' { Set-WindowsUpdatePause -Year 2040 }
        '3' { Set-WindowsUpdatePause -Year 2199 }
        '4' { 
            do {
                $customYear = Read-Host "Enter target year (e.g., 2030)"
                if ($customYear -as [int] -and [int]$customYear -ge 2024 -and [int]$customYear -le 2199) {
                    Set-WindowsUpdatePause -Year ([int]$customYear)
                    break
                } else {
                    Write-Host "Invalid year. Please enter a year between 2024 and 2199." -ForegroundColor Red
                }
            } while ($true)
        }
        '0' { Show-MainMenu }
        default { 
            Write-Host "Invalid selection." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-WindowsUpdateMenu 
        }
    }
}

function Set-WindowsUpdatePause {
    param(
        [int]$Days,
        [int]$Year
    )
    
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    if ($Days) {
        Write-Host "                          PAUSING UPDATES FOR $Days DAYS" -ForegroundColor Green
        $targetDate = (Get-Date).AddDays($Days).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    } else {
        Write-Host "                         PAUSING UPDATES UNTIL $Year" -ForegroundColor Green
        $targetDate = "$Year-01-01T10:38:56Z"
    }
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    
    if ($Days) {
        Write-Host "Calculating target date (current date + $Days days)..." -ForegroundColor White
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Write-Host "Current date: $currentDate" -ForegroundColor Cyan
    } else {
        Write-Host "Setting pause until January 1, $Year..." -ForegroundColor White
    }
    
    Write-Host "Target date: $targetDate" -ForegroundColor Yellow
    Write-Host "Applying pause configuration..." -ForegroundColor White
    
    try {
        $registryPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $registryPath -Name 'PauseUpdatesExpiryTime' -Value $targetDate -Force
        Set-ItemProperty -Path $registryPath -Name 'PauseFeatureUpdatesEndTime' -Value $targetDate -Force
        Set-ItemProperty -Path $registryPath -Name 'PauseQualityUpdatesEndTime' -Value $targetDate -Force
        
        if ($Days) {
            Write-Host "Windows Updates successfully paused for $Days days" -ForegroundColor Green
        } else {
            Write-Host "Windows Updates successfully paused until $Year" -ForegroundColor Green
        }
        Write-Host "Check Windows Settings > Update & Security to verify the pause status" -ForegroundColor Cyan
    } catch {
        Write-Host "Error: Failed to configure registry settings" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    Write-Host "Press any key to continue..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-WindowsUpdateMenu
}

# WiFi Profile Manager
function Invoke-WiFiManager {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                          WIFI PROFILE MANAGER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    if ($script:IsOnlineMode) {
        Write-Host "Select WiFi management option:" -ForegroundColor White
        Write-Host ""
        Write-Host "[1] Backup all WiFi profiles" -ForegroundColor White
        Write-Host "[2] Show saved WiFi passwords" -ForegroundColor White
        Write-Host "[3] Remove all WiFi profiles" -ForegroundColor White
        Write-Host "[0] Back to Main Menu" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            '1' { 
                Write-Host "Backing up WiFi profiles..." -ForegroundColor Yellow
                
                # Initialize output folder
                Initialize-OutputFolder
                
                $backupPath = Join-Path $script:OutputFolder "WiFiBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
                
                try {
                    netsh wlan export profile folder="$backupPath" key=clear
                    
                    # Count backed up profiles
                    $backedUpProfiles = Get-ChildItem -Path $backupPath -Filter "*.xml" | Measure-Object | Select-Object -ExpandProperty Count
                    
                    Write-Host "✓ WiFi profiles backed up to: $backupPath" -ForegroundColor Green
                    Write-Host "✓ Total profiles backed up: $backedUpProfiles" -ForegroundColor Green
                    
                    # Create a summary file
                    $summaryFile = Join-Path $backupPath "BackupSummary.txt"
                    $summaryContent = @()
                    $summaryContent += "WiFi Profile Backup Summary"
                    $summaryContent += "=========================="
                    $summaryContent += "Date: $(Get-Date)"
                    $summaryContent += "Total profiles: $backedUpProfiles"
                    $summaryContent += ""
                    $summaryContent += "Backed up profiles:"
                    
                    Get-ChildItem -Path $backupPath -Filter "*.xml" | ForEach-Object {
                        $profileName = $_.BaseName -replace '^Wi-Fi-', ''
                        $summaryContent += "- $profileName"
                    }
                    
                    $summaryContent | Out-File -FilePath $summaryFile -Encoding UTF8
                    Write-Host "✓ Backup summary saved: $summaryFile" -ForegroundColor Cyan
                    
                } catch {
                    Write-Host "✗ Error backing up WiFi profiles: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            '2' { 
                Write-Host "Retrieving WiFi passwords..." -ForegroundColor Yellow
                
                # Initialize output folder
                Initialize-OutputFolder
                
                $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
                    $_.Line.Split(':')[1].Trim()
                }
                
                $passwordsFile = Join-Path $script:OutputFolder "WiFiPasswords_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                $passwordContent = @()
                $passwordContent += "WiFi Passwords Export"
                $passwordContent += "===================="
                $passwordContent += "Date: $(Get-Date)"
                $passwordContent += "Total profiles: $($profiles.Count)"
                $passwordContent += ""
                
                foreach ($profile in $profiles) {
                    try {
                        $password = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object {
                            $_.Line.Split(':')[1].Trim()
                        }
                        if ($password) {
                            Write-Host "[$profile] : $password" -ForegroundColor Green
                            $passwordContent += "[$profile] : $password"
                        } else {
                            Write-Host "[$profile] : [No password/Open]" -ForegroundColor Gray
                            $passwordContent += "[$profile] : [No password/Open]"
                        }
                    } catch {
                        Write-Host "[$profile] : [Error retrieving]" -ForegroundColor Red
                        $passwordContent += "[$profile] : [Error retrieving]"
                    }
                }
                
                $passwordContent | Out-File -FilePath $passwordsFile -Encoding UTF8
                Write-Host ""
                Write-Host "✓ WiFi passwords saved to: $passwordsFile" -ForegroundColor Cyan
            }
            '3' { 
                $confirm = Read-Host "Are you sure you want to remove all WiFi profiles? (Y/N)"
                if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                    Write-Host "Removing all WiFi profiles..." -ForegroundColor Red
                    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
                        $_.Line.Split(':')[1].Trim()
                    }
                    
                    foreach ($profile in $profiles) {
                        try {
                            netsh wlan delete profile name="$profile"
                            Write-Host "✓ Removed: $profile" -ForegroundColor Green
                        } catch {
                            Write-Host "✗ Error removing: $profile" -ForegroundColor Red
                        }
                    }
                }
            }
            '0' { Show-MainMenu }
            default { 
                Write-Host "Invalid selection." -ForegroundColor Red
                Start-Sleep -Seconds 2
                Invoke-WiFiManager 
            }
        }
    } else {
        $scriptPath = Join-Path $script:LauncherPath "WindowsWifiBackupRestore\WinWifiManager.bat"
        if (Test-Path $scriptPath) {
            & cmd.exe /c $scriptPath
        } else {
            Write-Host "ERROR: Script file not found - WindowsWifiBackupRestore\WinWifiManager.bat" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "WiFi Manager completed. Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

# TTL Bypass Tool
function Invoke-TTLBypass {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                            TTL BYPASS TOOL" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    if ($script:IsOnlineMode) {
        # Get current TTL values
        try {
            $ipv4TTL = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name DefaultTTL -ErrorAction SilentlyContinue).DefaultTTL
            $ipv6TTL = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name DefaultHopLimit -ErrorAction SilentlyContinue).DefaultHopLimit
        } catch {
            $ipv4TTL = "Unknown"
            $ipv6TTL = "Unknown"
        }
        
        Write-Host "Current TTL Values:" -ForegroundColor White
        Write-Host "IPv4: $ipv4TTL" -ForegroundColor Cyan
        Write-Host "IPv6: $ipv6TTL" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Select TTL modification option:" -ForegroundColor White
        Write-Host ""
        Write-Host "[1] Set TTL to 65 (Bypass Tethering)" -ForegroundColor White
        Write-Host "[2] Set TTL to 128 (Windows Default)" -ForegroundColor White
        Write-Host "[3] Set TTL to custom value" -ForegroundColor White
        Write-Host "[0] Back to Main Menu" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            '1' { Set-TTLValue -Value 65 }
            '2' { Set-TTLValue -Value 128 }
            '3' { 
                do {
                    $customTTL = Read-Host "Enter custom TTL value (1-255)"
                    if ($customTTL -as [int] -and [int]$customTTL -ge 1 -and [int]$customTTL -le 255) {
                        Set-TTLValue -Value ([int]$customTTL)
                        break
                    } else {
                        Write-Host "Invalid TTL value. Please enter a number between 1 and 255." -ForegroundColor Red
                    }
                } while ($true)
            }
            '0' { Show-MainMenu }
            default { 
                Write-Host "Invalid selection." -ForegroundColor Red
                Start-Sleep -Seconds 2
                Invoke-TTLBypass 
            }
        }
    } else {
        $scriptPath = Join-Path $script:LauncherPath "WinTTLBypass\WinTTLBypass.bat"
        if (Test-Path $scriptPath) {
            & cmd.exe /c $scriptPath
        } else {
            Write-Host "ERROR: Script file not found - WinTTLBypass\WinTTLBypass.bat" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "TTL Bypass Tool completed. Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

function Set-TTLValue {
    param([int]$Value)
    
    Write-Host ""
    Write-Host "Setting TTL values to $Value..." -ForegroundColor Yellow
    
    try {
        # Set IPv4 TTL
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name DefaultTTL -Value $Value -Type DWord
        Write-Host "✓ IPv4 TTL set to $Value" -ForegroundColor Green
        
        # Set IPv6 TTL
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name DefaultHopLimit -Value $Value -Type DWord
        Write-Host "✓ IPv6 TTL set to $Value" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "TTL values successfully updated!" -ForegroundColor Green
        Write-Host "Changes will take effect after network reconnection or system reboot." -ForegroundColor Yellow
        
    } catch {
        Write-Host "✗ Error setting TTL values: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Press any key to continue..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Invoke-TTLBypass
}

# Help Function
function Show-Help {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                            HELP & TOOL INFORMATION" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "DETAILED TOOL DESCRIPTIONS:" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[1] System Cache Cleaner" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Cleans temporary files from user and system directories" -ForegroundColor White
    Write-Host "• Removes browser cache (Chrome, Firefox, Edge)" -ForegroundColor White
    Write-Host "• Clears prefetch files and recent items" -ForegroundColor White
    Write-Host "• Creates detailed log files of cleaned items" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[2] Chrome Policy Remover" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Removes Chrome management policies and restrictions" -ForegroundColor White
    Write-Host "• Clears 'Managed by your organization' settings" -ForegroundColor White
    Write-Host "• Removes Chrome registry entries and policy files" -ForegroundColor White
    Write-Host "• Requires Chrome to be closed before execution" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[3] Power Management Suite" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Advanced shutdown options (normal, forced)" -ForegroundColor White
    Write-Host "• System restart with various modes" -ForegroundColor White
    Write-Host "• Sleep and hibernation modes" -ForegroundColor White
    Write-Host "• Custom power command execution" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[4] Windows Update Controller" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Pause Windows Updates for specified duration" -ForegroundColor White
    Write-Host "• Custom year selection for update delays" -ForegroundColor White
    Write-Host "• Modifies registry settings for update control" -ForegroundColor White
    Write-Host "• Requires manual confirmation step" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[5] WiFi Profile Manager" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Backup all WiFi profiles with passwords" -ForegroundColor White
    Write-Host "• View saved WiFi profiles and passwords" -ForegroundColor White
    Write-Host "• Remove all current WiFi profiles" -ForegroundColor White
    Write-Host "• Comprehensive profile management system" -ForegroundColor White
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "[6] TTL Bypass Tool" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "• Modify TTL (Time To Live) settings for IPv4 and IPv6" -ForegroundColor White
    Write-Host "• Bypass tethering throttling restrictions" -ForegroundColor White
    Write-Host "• Set TTL to common values (65, 128) or custom values" -ForegroundColor White
    Write-Host "• Real-time TTL value display" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "SYSTEM REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "• Windows 10/11 (Administrator privileges required)" -ForegroundColor White
    Write-Host "• PowerShell 5.1 or higher" -ForegroundColor White
    Write-Host "• Network adapter with WiFi support (for WiFi Manager)" -ForegroundColor White
    Write-Host ""
    Write-Host "ONLINE MODE:" -ForegroundColor Yellow
    Write-Host "• Run with -Online parameter for web-based execution" -ForegroundColor White
    Write-Host "• All functions work directly through PowerShell" -ForegroundColor White
    Write-Host "• No external script files required" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press any key to return to main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}

# Exit Function
function Exit-Launcher {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                    EXITING WINDOWS SCRIPT LAUNCHER" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Thank you for using the Windows Script Launcher PowerShell Edition!" -ForegroundColor White
    if ($script:IsOnlineMode) {
        Write-Host "Online session completed." -ForegroundColor Cyan
    }
    Write-Host "Closing in 2 seconds..." -ForegroundColor White
    Start-Sleep -Seconds 2
    exit 0
}

# Main execution
try {
    # Check if running as administrator
    Request-Administrator
    
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                         ADMINISTRATOR PRIVILEGES OBTAINED" -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    
    # Initialize output folder
    Initialize-OutputFolder
    
    Start-Sleep -Seconds 1
    
    # Start the main menu
    Show-MainMenu
    
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
