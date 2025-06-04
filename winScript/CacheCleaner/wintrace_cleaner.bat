@echo off
setlocal enabledelayedexpansion

:: Set window size (width=80, height=50)
:: DISABLED. mode con: cols=80 lines=50

:: 1. UAC Bypass Check
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges detected.
) else (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ===============================================
echo           Windows System Cleanup
echo ===============================================
echo.
echo Select cleanup mode:
echo 1. Standard cleanup (recommended)
echo 2. Deep cleanup (includes Recycle Bin)
echo.
echo Press 1 or 2 to select:

:: Use choice command for single key press
choice /c 12 /n /m ""
set choice=%errorlevel%

if "%choice%"=="1" (
    set "cleanup_mode=standard"
    echo Standard cleanup mode selected.
) else if "%choice%"=="2" (
    set "cleanup_mode=deep"
    echo Deep cleanup mode selected.
)

echo.

:: Create log file with timestamp (using PowerShell as fallback)
for /f "tokens=1-6 delims=/: " %%a in ('echo %date% %time%') do (
    set "datestamp=%%c%%a%%b_%%d%%e%%f"
)
set "datestamp=%datestamp: =0%"
set "datestamp=%datestamp:,=%"
set "logfile=%~dp0cleanup_log_%datestamp%.txt"

echo =============================================== > "%logfile%"
echo           Windows System Cleanup Log >> "%logfile%"
echo           Date: %date% %time% >> "%logfile%"
echo =============================================== >> "%logfile%"
echo. >> "%logfile%"

ECHO.
ECHO Deleting User temp files...
echo Cleaning User temp files... >> "%logfile%"
if exist "%TEMP%" (
    for /f "delims=" %%f in ('dir /b "%TEMP%\*.*" 2^>nul') do (
        echo Deleted file: %TEMP%\%%f >> "%logfile%"
    )
    for /f "delims=" %%d in ('dir /b /ad "%TEMP%\*" 2^>nul') do (
        echo Deleted folder: %TEMP%\%%d >> "%logfile%"
    )
)
DEL /S /Q /F "%TEMP%\*.*" 2>nul
FOR /D %%p IN ("%TEMP%\*") DO RMDIR /S /Q "%%p" 2>nul

echo Cleaning TMP files... >> "%logfile%"
if exist "%TMP%" (
    for /f "delims=" %%f in ('dir /b "%TMP%\*.*" 2^>nul') do (
        echo Deleted file: %TMP%\%%f >> "%logfile%"
    )
    for /f "delims=" %%d in ('dir /b /ad "%TMP%\*" 2^>nul') do (
        echo Deleted folder: %TMP%\%%d >> "%logfile%"
    )
)
DEL /S /Q /F "%TMP%\*.*" 2>nul
FOR /D %%p IN ("%TMP%\*") DO RMDIR /S /Q "%%p" 2>nul

ECHO Deleting Local temp files...
echo Cleaning Local temp files... >> "%logfile%"
if exist "%USERPROFILE%\Local Settings\Temp" (
    for /f "delims=" %%f in ('dir /b "%USERPROFILE%\Local Settings\Temp\*.*" 2^>nul') do (
        echo Deleted file: %USERPROFILE%\Local Settings\Temp\%%f >> "%logfile%"
    )
    for /f "delims=" %%d in ('dir /b /ad "%USERPROFILE%\Local Settings\Temp\*" 2^>nul') do (
        echo Deleted folder: %USERPROFILE%\Local Settings\Temp\%%d >> "%logfile%"
    )
)
DEL /S /Q /F "%USERPROFILE%\Local Settings\Temp\*.*" 2>nul
FOR /D %%p IN ("%USERPROFILE%\Local Settings\Temp\*") DO RMDIR /S /Q "%%p" 2>nul

echo Cleaning LocalAppData temp files... >> "%logfile%"
if exist "%LOCALAPPDATA%\Temp" (
    for /f "delims=" %%f in ('dir /b "%LOCALAPPDATA%\Temp\*.*" 2^>nul') do (
        echo Deleted file: %LOCALAPPDATA%\Temp\%%f >> "%logfile%"
    )
    for /f "delims=" %%d in ('dir /b /ad "%LOCALAPPDATA%\Temp\*" 2^>nul') do (
        echo Deleted folder: %LOCALAPPDATA%\Temp\%%d >> "%logfile%"
    )
)
DEL /S /Q /F "%LOCALAPPDATA%\Temp\*.*" 2>nul
FOR /D %%p IN ("%LOCALAPPDATA%\Temp\*") DO RMDIR /S /Q "%%p" 2>nul

ECHO Deleting Windows temp files...
echo Cleaning Windows temp files... >> "%logfile%"
if exist "%WINDIR%\temp" (
    for /f "delims=" %%f in ('dir /b "%WINDIR%\temp\*.*" 2^>nul') do (
        echo Deleted file: %WINDIR%\temp\%%f >> "%logfile%"
    )
    for /f "delims=" %%d in ('dir /b /ad "%WINDIR%\Temp\*" 2^>nul') do (
        echo Deleted folder: %WINDIR%\Temp\%%d >> "%logfile%"
    )
)
DEL /S /Q /F "%WINDIR%\temp\*.*" 2>nul
FOR /D %%p IN ("%WINDIR%\Temp\*") DO RMDIR /S /Q "%%p" 2>nul

ECHO Cleaning Prefetch files...
echo Cleaning Prefetch files... >> "%logfile%"
if exist "%WINDIR%\Prefetch" (
    for /f "delims=" %%f in ('dir /b "%WINDIR%\Prefetch\*.*" 2^>nul') do (
        echo Deleted file: %WINDIR%\Prefetch\%%f >> "%logfile%"
    )
)
DEL /S /Q /F "%WINDIR%\Prefetch\*.*" 2>nul

ECHO Cleaning Recent files...
echo Cleaning Recent files... >> "%logfile%"
for %%f in ("%USERPROFILE%\Recent\*.*") do (
    if exist "%%f" echo Deleted file: %%f >> "%logfile%"
)
DEL /S /Q /F "%USERPROFILE%\Recent\*.*" 2>nul

:: Only clean Recycle Bin in deep mode
if "%cleanup_mode%"=="deep" (
    ECHO Cleaning Recycle Bin...
    echo Cleaning Recycle Bin... >> "%logfile%"
    
    :: Method 1: Use PowerShell to empty recycle bin (most reliable)
    powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" 2>nul
    
    :: Method 2: Manual deletion for all drives (fallback)
    for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
        if exist "%%d:\$Recycle.Bin" (
            echo Cleaning Recycle Bin on drive %%d:... >> "%logfile%"
            for /d %%f in ("%%d:\$Recycle.Bin\*") do (
                echo Deleting: %%f >> "%logfile%"
                rmdir /s /q "%%f" 2>nul
            )
            del /s /q /f "%%d:\$Recycle.Bin\*.*" 2>nul
        )
    )
    
    :: Method 3: Alternative paths
    if exist "%USERPROFILE%\$Recycle.Bin" (
        echo Cleaning user Recycle Bin... >> "%logfile%"
        rmdir /s /q "%USERPROFILE%\$Recycle.Bin" 2>nul
    )
)

ECHO Cleaning Browser caches...
echo Cleaning Browser caches... >> "%logfile%"

:: Chrome
echo Cleaning Chrome cache... >> "%logfile%"
for %%f in ("%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*") do (
    if exist "%%f" echo Deleted Chrome file: %%f >> "%logfile%"
)
for /d %%d in ("%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*") do (
    if exist "%%d" echo Deleted Chrome folder: %%d >> "%logfile%"
)
DEL /S /Q /F "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
FOR /D %%p IN ("%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*") DO RMDIR /S /Q "%%p" 2>nul

:: Firefox
echo Cleaning Firefox cache... >> "%logfile%"
for %%f in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*.*") do (
    if exist "%%f" echo Deleted Firefox file: %%f >> "%logfile%"
)
for /d %%d in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*") do (
    if exist "%%d" echo Deleted Firefox folder: %%d >> "%logfile%"
)
DEL /S /Q /F "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*.*" 2>nul
FOR /D %%p IN ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*") DO RMDIR /S /Q "%%p" 2>nul

:: Edge
echo Cleaning Edge cache... >> "%logfile%"
for %%f in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*") do (
    if exist "%%f" echo Deleted Edge file: %%f >> "%logfile%"
)
for /d %%d in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*") do (
    if exist "%%d" echo Deleted Edge folder: %%d >> "%logfile%"
)
DEL /S /Q /F "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul
FOR /D %%p IN ("%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*") DO RMDIR /S /Q "%%p" 2>nul

echo.
echo ------------------------------------------------------- >> "%logfile%"
if "%cleanup_mode%"=="deep" (
    echo           Deep Cleanup completed !!! >> "%logfile%"
) else (
    echo         Standard Cleanup completed !!! >> "%logfile%"
)
echo ------------------------------------------------------- >> "%logfile%"
echo. >> "%logfile%"

echo.
echo -------------------------------------------------------
if "%cleanup_mode%"=="deep" (
    echo           Deep Cleanup completed !!!
) else (
    echo         Standard Cleanup completed !!!
)
echo -------------------------------------------------------
echo.
echo Cleaned locations:
echo - User Temp files
echo - Local Temp files  
echo - Windows Temp files
echo - Prefetch files
echo - Recent files
if "%cleanup_mode%"=="deep" (
    echo - Recycle Bin (all drives)
)
echo - Browser caches (Chrome, Firefox, Edge)
echo.
echo Cleanup mode: %cleanup_mode%
echo Log file created: %logfile%
echo.
PAUSE