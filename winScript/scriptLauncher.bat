@echo off
setlocal EnableDelayedExpansion

:: Set window size and color
mode con: cols=92 lines=52
color 0B
title Windows Script Launcher v1.0

:: Position window to top-left corner
powershell -command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Win32 { [DllImport(\"user32.dll\")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags); [DllImport(\"kernel32.dll\")] public static extern IntPtr GetConsoleWindow(); }'; $hwnd = [Win32]::GetConsoleWindow(); [Win32]::SetWindowPos($hwnd, 0, 0, 0, 0, 0, 0x0001)"

:: Get current directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:checkFiles
:: Check if all required scripts exist
set "missing_files="
if not exist "CacheCleaner\wintrace_cleaner.bat" (
    set "missing_files=!missing_files! CacheCleaner\wintrace_cleaner.bat"
)
if not exist "PowerManager\NewShutdown.bat" (
    set "missing_files=!missing_files! PowerManager\NewShutdown.bat"
)
if not exist "WindowsTTLChanger\BypassTethering-Throttling.bat" (
    set "missing_files=!missing_files! WindowsTTLChanger\BypassTethering-Throttling.bat"
)

if not "!missing_files!"=="" (
    cls
    echo =====================================================================================
    echo                                  FILE TIDAK DITEMUKAN
    echo =====================================================================================
    echo.
    echo  Script berikut tidak ditemukan:
    for %%f in (!missing_files!) do (
        echo    - %%f
    )
    echo.
    echo  Pastikan struktur folder seperti ini:
    echo    E:\Windows\winScript\
    echo    ├───CacheCleaner\
    echo    │   └───wintrace_cleaner.bat
    echo    ├───PowerManager\
    echo    │   └───NewShutdown.bat
    echo    └───WindowsTTLChanger\
    echo        └───BypassTethering-Throttling.bat
    echo.
    echo =====================================================================================
    echo.
    pause
    exit /b 1
)

:mainMenu
cls
echo =====================================================================================
echo                                 WINDOWS SCRIPT LAUNCHER
echo                                      Version 1.0
echo =====================================================================================
echo.
echo   Selamat datang di Windows Script Launcher!
echo   Pilih tools yang ingin Anda jalankan:
echo.
echo ---------------------------------------------------------------------------------
echo.
echo   [1] Cache Cleaner          - Bersihkan file temporary dan cache sistem
echo   [2] Power Manager          - Kelola shutdown, restart, dan power options
echo   [3] Windows TTL Changer    - Ubah TTL untuk bypass tethering throttling
echo.
echo ---------------------------------------------------------------------------------
echo.
echo   [4] Buka Windows Explorer  - Buka folder script di explorer
echo   [5] Informasi System       - Tampilkan informasi sistem
echo   [6] Keluar                 - Tutup aplikasi
echo.
echo =====================================================================================

CHOICE /C 123456 /N /M "Pilih opsi (1-6): "

if errorlevel 6 goto exitLauncher
if errorlevel 5 goto showSystemInfo
if errorlevel 4 goto openExplorer
if errorlevel 3 goto runTTLChanger
if errorlevel 2 goto runPowerManager
if errorlevel 1 goto runCacheCleaner

goto mainMenu

:runCacheCleaner
cls
echo =====================================================================================
echo                               MENJALANKAN CACHE CLEANER
echo =====================================================================================
echo.
echo  Memulai Windows Cache Cleaner...
echo  Script akan terbuka dalam window terpisah.
echo.
echo ---------------------------------------------------------------------------------
timeout /t 2 /nobreak >nul

start "Cache Cleaner" /wait cmd /c ""%SCRIPT_DIR%CacheCleaner\wintrace_cleaner.bat""

echo.
echo  Cache Cleaner telah selesai dijalankan.
echo  Tekan tombol apa saja untuk kembali ke menu utama...
pause >nul
goto mainMenu

:runPowerManager
cls
echo =====================================================================================
echo                               MENJALANKAN POWER MANAGER
echo =====================================================================================
echo.
echo  Memulai Power Manager...
echo  Script akan terbuka dalam window terpisah.
echo.
echo ---------------------------------------------------------------------------------
timeout /t 2 /nobreak >nul

start "Power Manager" /wait cmd /c ""%SCRIPT_DIR%PowerManager\NewShutdown.bat""

echo.
echo  Power Manager telah selesai dijalankan.
echo  Tekan tombol apa saja untuk kembali ke menu utama...
pause >nul
goto mainMenu

:runTTLChanger
cls
echo =====================================================================================
echo                             MENJALANKAN WINDOWS TTL CHANGER
echo =====================================================================================
echo.
echo  Memulai Windows TTL Changer...
echo  Script akan terbuka dalam window terpisah.
echo  
echo  CATATAN: Script ini memerlukan hak administrator!
echo.
echo ---------------------------------------------------------------------------------
timeout /t 2 /nobreak >nul

start "TTL Changer" /wait cmd /c ""%SCRIPT_DIR%WindowsTTLChanger\BypassTethering-Throttling.bat""

echo.
echo  TTL Changer telah selesai dijalankan.
echo  Tekan tombol apa saja untuk kembali ke menu utama...
pause >nul
goto mainMenu

:openExplorer
cls
echo =====================================================================================
echo                              MEMBUKA WINDOWS EXPLORER
echo =====================================================================================
echo.
echo  Membuka folder script di Windows Explorer...
echo.
timeout /t 1 /nobreak >nul

explorer "%SCRIPT_DIR%"

echo  Windows Explorer telah dibuka.
echo  Tekan tombol apa saja untuk kembali ke menu utama...
pause >nul
goto mainMenu

:showSystemInfo
cls
echo =====================================================================================
echo                                INFORMASI SISTEM
echo.
echo  Computer Name    : %COMPUTERNAME%
echo  Username         : %USERNAME%
echo  OS Version       : 
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.
echo  Hardware Information:
powershell -Command "$cs = Get-WmiObject -Class Win32_ComputerSystem; $bios = Get-WmiObject -Class Win32_BIOS; Write-Output \"    Manufacturer     : $($cs.Manufacturer)\"; Write-Output \"    Model            : $($cs.Model)\"; Write-Output \"    Serial Number    : $($bios.SerialNumber)\"; Write-Output \"    BIOS Version     : $($bios.SMBIOSBIOSVersion)\""
echo.
echo  Script Directory : %SCRIPT_DIR%
echo  Current Time     : %DATE% %TIME%
echo.
echo ---------------------------------------------------------------------------------
echo                               INFORMASI MEMORY DAN STORAGE
echo.
echo  Memory (RAM):
powershell -Command "$totalRAM = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB; $availRAM = (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory / 1MB; $usedRAM = $totalRAM - ($availRAM / 1024); Write-Output \"    Total RAM        : $([math]::Round($totalRAM, 2)) GB\"; Write-Output \"    Used RAM         : $([math]::Round($usedRAM, 2)) GB\"; Write-Output \"    Available RAM    : $([math]::Round($availRAM / 1024, 2)) GB\""
echo.
echo  Virtual Memory (Pagefile):
powershell -Command "$os = Get-WmiObject -Class Win32_OperatingSystem; $totalVirtual = $os.TotalVirtualMemorySize / 1MB; $freeVirtual = $os.FreeVirtualMemory / 1MB; $usedVirtual = $totalVirtual - $freeVirtual; Write-Output \"    Total Pagefile   : $([math]::Round($totalVirtual, 2)) GB\"; Write-Output \"    Used Pagefile    : $([math]::Round($usedVirtual, 2)) GB\"; Write-Output \"    Available Pagefile: $([math]::Round($freeVirtual, 2)) GB\""
echo.
echo  Storage Information:
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object { $totalGB = [math]::Round($_.Size / 1GB, 2); $freeGB = [math]::Round($_.FreeSpace / 1GB, 2); $usedGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2); $usedPercent = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1); Write-Output \"    Drive $($_.DeviceID) - Total: $totalGB GB, Used: $usedGB GB ($usedPercent%%), Free: $freeGB GB\" }"
echo.
echo ---------------------------------------------------------------------------------
echo                                TOOLS TERSEDIA
echo.
echo  Daftar Tools yang Tersedia:
echo    [OK] Cache Cleaner         - CacheCleaner\wintrace_cleaner.bat
echo    [OK] Power Manager         - PowerManager\NewShutdown.bat  
echo    [OK] Windows TTL Changer   - WindowsTTLChanger\BypassTethering-Throttling.bat
echo.
echo =====================================================================================
echo.
echo  Tekan tombol apa saja untuk kembali ke menu utama...
pause >nul
goto mainMenu

:exitLauncher
cls
echo =====================================================================================
echo                                   KELUAR APLIKASI
echo.
echo  Terima kasih telah menggunakan Windows Script Launcher!
echo.
echo  Dibuat untuk mempermudah pengelolaan script Windows :D by risunCode
echo.
echo ---------------------------------------------------------------------------------
echo.
echo  Aplikasi akan ditutup dalam 3 detik...
timeout /t 3 /nobreak >nul
exit /b 0