@echo off
setlocal EnableDelayedExpansion
title Windows Script Launcher - Control Center
color 0E

:: Set console window size
mode con: cols=90 lines=30

:: Save original path
set "LAUNCHER_PATH=%~dp0"
cd /d "%LAUNCHER_PATH%"

:: Check Administrator Privileges
:checkPrivileges
NET FILE >nul 2>&1
if '%errorlevel%'=='0' (
    goto gotPrivileges
) else (
    cls
    echo ==================================================================================================
    echo                                    ADMINISTRATOR PRIVILEGES REQUIRED
    echo ==================================================================================================
    echo.
    echo  This launcher requires administrator privileges to execute some scripts properly.
    echo  Most tools in this collection need elevated permissions to modify system settings,
    echo  manage Windows services, and perform system-level operations.
    echo.
    echo  Attempting automatic elevation...
    echo  If UAC dialog appears, please click "Yes" to continue.
    echo.
    echo ==================================================================================================
    echo. 
    goto getPrivileges
)

:getPrivileges
set "vbsfile=%temp%\getadmin.vbs"
(
    echo Set UAC = CreateObject^("Shell.Application"^)
    echo UAC.ShellExecute "cmd.exe", "/c ""cd /d %LAUNCHER_PATH% && %~f0"" %*", "", "runas", 1
) > "%vbsfile%"
cscript //nologo "%vbsfile%"
del /q "%vbsfile%" >nul 2>&1
exit /b

:gotPrivileges
cls
echo ===============================================================================
echo                         ADMINISTRATOR PRIVILEGES OBTAINED
echo ===============================================================================
timeout /t 1 >nul
goto mainMenu

:mainMenu
cls
echo ===============================================================================
echo                           WINDOWS SCRIPT LAUNCHER
echo ===============================================================================
echo.
echo  [1] System Cache Cleaner      - Clean temp files and browser cache
echo  [2] Chrome Policy Remover     - Remove Chrome management policies  
echo  [3] Power Management Suite    - Shutdown, restart, and power options
echo  [4] Windows Update Controller - Delay or pause Windows updates
echo  [5] WiFi Profile Manager      - Backup, restore, and manage WiFi profiles
echo  [6] TTL Bypass Tool           - Modify TTL settings for tethering bypass
echo  [7] OneDrive Switcher         - Enable/disable OneDrive startup and sync
echo  [8] Windows Activator         - Activate Windows and Office
echo  [9] WinUtils (ChrisTitusTech) - Optimize and debloat Windows
echo.
echo  [R] Refresh Menu    [H] Help / About    [Q] Quit Launcher
echo ===============================================================================
choice /c 123456789RHQ /n /m "Select option: "

if errorlevel 12 goto exitLauncher
if errorlevel 11 goto showHelp
if errorlevel 10 goto mainMenu
if errorlevel 9 goto runWinUtils
if errorlevel 8 goto runWindowsActivator
if errorlevel 7 goto runOneDriveSwitcher
if errorlevel 6 goto runTTLBypass
if errorlevel 5 goto runWiFiManager
if errorlevel 4 goto runWindowsUpdate
if errorlevel 3 goto runPowerManager
if errorlevel 2 goto runChromePolicy
if errorlevel 1 goto runCacheCleaner

goto mainMenu

:runCacheCleaner
cls
echo ===============================================================================
echo                           SYSTEM CACHE CLEANER
echo ===============================================================================
if not exist "CacheCleaner\wintrace_cleaner.bat" (
    echo ERROR: Script file not found - CacheCleaner\wintrace_cleaner.bat
    pause
    goto mainMenu
)
call "CacheCleaner\wintrace_cleaner.bat"
echo ===============================================================================
echo Cache Cleaner completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runChromePolicy
cls
echo ===============================================================================
echo                          CHROME POLICY REMOVER
echo ===============================================================================
if not exist "ChromePolicy\Chrome_Policy_Remover.bat" (
    echo ERROR: Script file not found - ChromePolicy\Chrome_Policy_Remover.bat
    pause
    goto mainMenu
)
call "ChromePolicy\Chrome_Policy_Remover.bat"
echo ===============================================================================
echo Chrome Policy Remover completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runPowerManager
cls
echo ===============================================================================
echo                          POWER MANAGEMENT SUITE
echo ===============================================================================
if not exist "PowerManager\NewShutdown.bat" (
    echo ERROR: Script file not found - PowerManager\NewShutdown.bat
    pause
    goto mainMenu
)
call "PowerManager\NewShutdown.bat"
echo ===============================================================================
echo Power Manager completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runWindowsUpdate
cls
echo                            WINDOWS UPDATE CONTROLLER 
echo ===============================================================================
echo. 
echo [BAHASA INDONESIA] =============================================
echo Script ini memerlukan WORKAROUND MANUAL agar dapat berfungsi dengan benar.
echo Sebelum melanjutkan, Anda HARUS menekan tombol
echo "Pause updates for 1 week" secara manual di pengaturan Windows Update.
echo.
echo Langkah ini penting karena Windows tidak akan menghentikan proses update
echo hanya dengan mengubah registry melalui script.
echo Setelah Anda selesai melakukan workaround manual, ketik: confirm
echo. 
echo. 
echo. 
echo [ENGLISH] ============================================= 
echo This script requires a MANUAL WORKAROUND to function properly.
echo Before proceeding, you MUST click "Pause updates for 1 week" manually
echo in the Windows Update settings.
echo.
echo This step is crucial because Windows will not fully pause updates
echo just by modifying the registry via script.
echo.
echo Once you've clicked the pause update button, type: confirm
echo ===============================================================================
echo.

:waitForConfirmation
set /p userInput="Type 'confirm' to continue or 'back' to return to main menu: "

if /i "%userInput%"=="confirm" (
    goto showUpdateMenu
) else if /i "%userInput%"=="back" (
    goto mainMenu
) else (
    echo Invalid input. Please type 'confirm' or 'back'.
    echo.
    goto waitForConfirmation
)

:showUpdateMenu
cls
echo ===============================================================================
echo                            WINDOWS UPDATE CONTROLLER
echo ===============================================================================
echo.
echo  Select pause duration for Windows Updates:
echo.
echo  [1] Pause for 1 week from today
echo  [2] Pause until 2040 (Standard)
echo  [3] Pause until 2199 (Maximum)
echo  [4] Custom pause year
echo  [0] Back to Main Menu
echo.
echo ===============================================================================
choice /c 12340 /n /m "Select option: "

if errorlevel 5 goto mainMenu
if errorlevel 4 goto updateCustomYear
if errorlevel 3 goto updateUntil2199
if errorlevel 2 goto updateUntil2040
if errorlevel 1 goto updateOneWeek

goto showUpdateMenu

:updateOneWeek
cls
echo ===============================================================================
echo                          PAUSING UPDATES FOR 1 WEEK
echo ===============================================================================
echo.
echo Calculating target date (current date + 7 days)...
powershell -Command "$currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; Write-Host 'Current date:' $currentDate -ForegroundColor Cyan; $targetDate = (Get-Date).AddDays(7).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'); Write-Host 'Target date:' $targetDate -ForegroundColor Yellow; Write-Host 'Applying pause configuration...' -ForegroundColor White; $registryPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }; Set-ItemProperty -Path $registryPath -Name 'PauseUpdatesExpiryTime' -Value $targetDate -Force; Set-ItemProperty -Path $registryPath -Name 'PauseFeatureUpdatesEndTime' -Value $targetDate -Force; Set-ItemProperty -Path $registryPath -Name 'PauseQualityUpdatesEndTime' -Value $targetDate -Force; Write-Host 'Windows Updates successfully paused for 1 week' -ForegroundColor Green; Write-Host 'Check Windows Settings > Update & Security to verify the pause status' -ForegroundColor Cyan; Write-Host 'Press any key to continue . . .' -ForegroundColor White"
echo.
pause >nul
goto showUpdateMenu

:updateUntil2040
cls
echo ===============================================================================
echo                         PAUSING UPDATES UNTIL 2040
echo ===============================================================================
echo.
echo Setting pause until January 1, 2040...
powershell -Command "$expiryTime = '2040-01-01T10:38:56Z'; Write-Host 'Target date:' $expiryTime -ForegroundColor Yellow; Write-Host 'Applying pause configuration...' -ForegroundColor White; $registryPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }; Set-ItemProperty -Path $registryPath -Name 'PauseUpdatesExpiryTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseFeatureUpdatesEndTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseQualityUpdatesEndTime' -Value $expiryTime -Force; Write-Host 'Windows Updates successfully paused until 2040' -ForegroundColor Green; Write-Host 'Check Windows Settings > Update & Security to verify the pause status' -ForegroundColor Cyan; Write-Host 'Press any key to continue . . .' -ForegroundColor White"
echo.
pause >nul
goto showUpdateMenu

:updateUntil2199
cls
echo ===============================================================================
echo                         PAUSING UPDATES UNTIL 2199
echo ===============================================================================
echo.
echo Setting maximum pause until January 1, 2199...
powershell -Command "$expiryTime = '2199-01-01T10:38:56Z'; Write-Host 'Target date:' $expiryTime -ForegroundColor Yellow; Write-Host 'Applying pause configuration...' -ForegroundColor White; $registryPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }; Set-ItemProperty -Path $registryPath -Name 'PauseUpdatesExpiryTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseFeatureUpdatesEndTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseQualityUpdatesEndTime' -Value $expiryTime -Force; Write-Host 'Windows Updates successfully paused until 2199' -ForegroundColor Green; Write-Host 'Check Windows Settings > Update & Security to verify the pause status' -ForegroundColor Cyan; Write-Host 'Press any key to continue . . .' -ForegroundColor White"
echo.
pause >nul
goto showUpdateMenu

:updateCustomYear
cls
echo ===============================================================================
echo                           CUSTOM PAUSE YEAR
echo ===============================================================================
echo.
set /p customYear="Enter target year (e.g., 2030): "

:: Validate year input
if "%customYear%"=="" goto updateCustomYear
for /f "delims=0123456789" %%i in ("%customYear%") do (
    echo Invalid input! Please enter numbers only.
    pause
    goto updateCustomYear
)

if %customYear% LSS 2024 (
    echo Year must be 2024 or later!
    pause
    goto updateCustomYear
)

if %customYear% GTR 2199 (
    echo Maximum year is 2199!
    pause
    goto updateCustomYear
)

echo.
echo Setting pause until January 1, %customYear%...
set "customDate=%customYear%-01-01T10:38:56Z"
powershell -Command "$expiryTime = '%customDate%'; Write-Host 'Target date:' $expiryTime -ForegroundColor Yellow; Write-Host 'Applying pause configuration...' -ForegroundColor White; $registryPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }; Set-ItemProperty -Path $registryPath -Name 'PauseUpdatesExpiryTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseFeatureUpdatesEndTime' -Value $expiryTime -Force; Set-ItemProperty -Path $registryPath -Name 'PauseQualityUpdatesEndTime' -Value $expiryTime -Force; Write-Host 'Windows Updates successfully paused until %customYear%' -ForegroundColor Green; Write-Host 'Check Windows Settings > Update & Security to verify the pause status' -ForegroundColor Cyan; Write-Host 'Press any key to continue . . .' -ForegroundColor White"
echo.
pause >nul
goto showUpdateMenu

:runWiFiManager
cls
echo ===============================================================================
echo                          WIFI PROFILE MANAGER
echo ===============================================================================
if not exist "WindowsWifiBackupRestore\WinWifiManager.bat" (
    echo ERROR: Script file not found - WindowsWifiBackupRestore\WinWifiManager.bat
    pause
    goto mainMenu
)
call "WindowsWifiBackupRestore\WinWifiManager.bat"
echo ===============================================================================
echo WiFi Manager completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runTTLBypass
cls
echo ===============================================================================
echo                            TTL BYPASS TOOL
echo ===============================================================================
if not exist "WinTTLBypass\WinTTLBypass.bat" (
    echo ERROR: Script file not found - WinTTLBypass\WinTTLBypass.bat
    pause
    goto mainMenu
)
call "WinTTLBypass\WinTTLBypass.bat"
echo ===============================================================================
echo TTL Bypass Tool completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runOneDriveSwitcher
cls
echo ===============================================================================
echo                            ONEDRIVE SWITCHER
echo ===============================================================================

:: Check OneDrive policy status
reg query "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" >nul 2>&1
if %errorlevel%==0 (
    echo Current OneDrive Status: DISABLED
) else (
    echo Current OneDrive Status: ENABLED
)
echo.

echo ===============================================================================
echo Select OneDrive Action:
echo.
echo  [1] Disable OneDrive
echo  [2] Enable OneDrive
echo  [0] Back to Main Menu
echo.
echo ===============================================================================
echo.
choice /c 120 /n /m "Select option: "

if errorlevel 3 goto mainMenu
if errorlevel 2 goto enableOneDrive
if errorlevel 1 goto disableOneDrive

goto runOneDriveSwitcher

:disableOneDrive
cls
echo ===============================================================================
echo                    DISABLING ONEDRIVE
echo ===============================================================================
echo.
echo [DISABLE] Menonaktifkan OneDrive...

:: Add policy to block synchronization
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1

:: Refresh policy
echo Refreshing Group Policy...
gpupdate /force

echo.
echo [SUCCESS] OneDrive dinonaktifkan. Reboot untuk efek penuh.
echo ===============================================================================
echo OneDrive Switcher completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:enableOneDrive
cls
echo ===============================================================================
echo                     ENABLING ONEDRIVE
echo ===============================================================================
echo.
echo [ENABLE] Mengaktifkan OneDrive...

:: Remove policy that blocks synchronization
reg delete "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /f >nul 2>&1

:: Optional: remove key if empty
reg delete "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /f >nul 2>&1

:: Refresh policy
echo Refreshing Group Policy...
gpupdate /force

:: Restart Explorer
echo Restarting Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo [SUCCESS] OneDrive seharusnya aktif setelah reboot.
echo ===============================================================================
echo OneDrive Switcher completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runWindowsActivator
cls
echo ===============================================================================
echo                        WINDOWS & OFFICE ACTIVATOR
echo ===============================================================================
echo.
echo This tool will activate Windows and Microsoft Office using the
echo Microsoft Activation Scripts (MAS) by massgravel.
echo.
echo WARNING: This will download and execute a remote PowerShell script.
echo Make sure you understand the risks before proceeding.
echo.
echo Source: https://github.com/massgravel/Microsoft-Activation-Scripts
echo ===============================================================================
echo.
pause
echo.
echo Launching Windows Activator...
echo ===============================================================================
powershell -Command "irm https://get.activated.win | iex"
echo.
echo ===============================================================================
echo Windows Activator process completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:runWinUtils
cls
echo ===============================================================================
echo                   WINUTILS BY CHRISTITUSTECH
echo ===============================================================================
echo.
echo This tool provides various Windows optimization and debloating utilities
echo created by Chris Titus Tech.
echo.
echo Features:
echo   - Install/Remove Windows features and applications
echo   - Windows optimization tweaks
echo   - System debloating and cleanup
echo   - Privacy settings configuration
echo.
echo WARNING: This will download and execute a remote PowerShell script.
echo Make sure you understand the risks before proceeding.
echo.
echo Source: https://github.com/ChrisTitusTech/winutil
echo ===============================================================================
echo.
pause
echo.
echo Launching WinUtils...
echo ===============================================================================
powershell -Command "irm 'https://christitus.com/win' | iex"
echo.
echo ===============================================================================
echo WinUtils process completed. Press any key to return to main menu...
pause >nul
goto mainMenu

:showHelp
cls
echo ==================================================================================================
echo                                    HELP & TOOL INFORMATION
echo ==================================================================================================
echo.
echo  DETAILED TOOL DESCRIPTIONS:
echo.
echo --------------------------------------------------------------------------------------------------
echo  [1] System Cache Cleaner (CacheCleaner\wintrace_cleaner.bat)
echo --------------------------------------------------------------------------------------------------
echo      • Cleans temporary files from user and system directories
echo      • Removes browser cache (Chrome, Firefox, Edge)
echo      • Clears prefetch files and recent items
echo      • Optionally empties Recycle Bin (Deep Clean mode)
echo      • Creates detailed log files of cleaned items
echo.
echo --------------------------------------------------------------------------------------------------
echo  [2] Chrome Policy Remover (ChromePolicy\Chrome_Policy_Remover.bat)
echo --------------------------------------------------------------------------------------------------
echo      • Removes Chrome management policies and restrictions
echo      • Clears "Managed by your organization" settings
echo      • Removes Chrome registry entries and policy files
echo      • Clears Chrome preferences that retain policy settings
echo      • Requires Chrome to be closed before execution
echo.
echo --------------------------------------------------------------------------------------------------
echo  [3] Power Management Suite (PowerManager\NewShutdown.bat)
echo --------------------------------------------------------------------------------------------------
echo      • Advanced shutdown options (normal, forced)
echo      • System restart with various modes (normal, soft, UEFI)
echo      • Sleep and hibernation modes
echo      • Custom shutdown command execution
echo      • Logs all power management actions
echo.
echo --------------------------------------------------------------------------------------------------
echo  [4] Windows Update Controller (WindowsUpdate\UpdateDelay.ps1)
echo --------------------------------------------------------------------------------------------------
echo      • Pause Windows Updates until a specified year (default: 2050)
echo      • Custom year selection for update delays
echo      • Stops Windows Update service
echo      • Modifies registry settings for update control
echo      • PowerShell-based with administrator privilege checks
echo.
echo --------------------------------------------------------------------------------------------------
echo  [5] WiFi Profile Manager (WindowsWifiBackupRestore\WinWifiManager.bat)
echo --------------------------------------------------------------------------------------------------
echo      • Backup all WiFi profiles with passwords
echo      • Restore WiFi profiles from backups
echo      • View saved WiFi profiles and passwords
echo      • Selective restoration of specific profiles
echo      • Search WiFi profiles by name
echo      • Remove all current WiFi profiles
echo      • Comprehensive profile management system
echo.
echo --------------------------------------------------------------------------------------------------
echo  [6] TTL Bypass Tool (WinTTLBypass\WinTTLBypass.bat)
echo --------------------------------------------------------------------------------------------------
echo      • Modify TTL (Time To Live) settings for IPv4 and IPv6
echo      • Bypass tethering throttling restrictions
echo      • Set TTL to common values (65, 128) or custom values
echo      • Real-time TTL value display
echo      • Supports values from 1-255 with input validation
echo.
echo --------------------------------------------------------------------------------------------------
echo  [7] OneDrive Switcher (Built-in)
echo --------------------------------------------------------------------------------------------------
echo      • Simple OneDrive enable/disable functionality
echo      • Uses Windows Group Policy for system-wide control
echo      • Automatic policy refresh and Explorer restart
echo      • Real-time OneDrive status monitoring
echo      • Requires reboot for full effect
echo.
echo --------------------------------------------------------------------------------------------------
echo  [8] Windows Activator (Microsoft Activation Scripts)
echo --------------------------------------------------------------------------------------------------
echo      • Activate Windows and Microsoft Office products
echo      • Uses Microsoft Activation Scripts (MAS) by massgravel
echo      • Supports multiple activation methods
echo      • Open-source and regularly maintained
echo      • Source: https://github.com/massgravel/Microsoft-Activation-Scripts
echo.
echo --------------------------------------------------------------------------------------------------
echo  [9] WinUtils by ChrisTitusTech
echo --------------------------------------------------------------------------------------------------
echo      • Comprehensive Windows optimization utility
echo      • Install/Remove Windows features and applications
echo      • System debloating and cleanup tools
echo      • Privacy settings configuration
echo      • Performance optimization tweaks
echo      • Source: https://github.com/ChrisTitusTech/winutil
echo.
echo ==================================================================================================
echo.
echo  SYSTEM REQUIREMENTS:
echo  • Windows 10/11 (Administrator privileges required)
echo  • PowerShell (for Windows Update Controller)
echo  • Network adapter with WiFi support (for WiFi Manager)
echo.
echo  SAFETY NOTES:
echo  • Always backup important data before using system modification tools
echo  • These tools modify system settings and may require system restart
echo  • Some corporate/domain policies may override these modifications
echo.
echo ==================================================================================================
echo.
pause
goto mainMenu

:exitLauncher
cls
echo ===============================================================================
echo                    EXITING WINDOWS SCRIPT LAUNCHER
echo ===============================================================================
echo.
echo Thank you for using the Windows Script Launcher!
echo Closing in 2 seconds...
timeout /t 2 /nobreak >nul
exit /b 0
