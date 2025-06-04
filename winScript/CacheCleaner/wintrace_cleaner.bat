@echo off
setlocal enabledelayedexpansion

:: Set window size (width=80, height=50)
:: DISABLED. mode con: cols=80 lines=50

:: ==================================================
:: EXCLUDE LIST - Files/Folders to NOT delete
:: ==================================================
set "exclude_files=wintrace_cleaner.bat;cleaner.bat;system_cleaner.bat;cleanup.bat"
set "exclude_extensions=.bat"
set "exclude_folders=Scripts;Tools;Backup;Important"
:: set "exclude_extensions=.bat;.cmd;.exe;.msi;.reg"

:: Get current script name and location for self-protection
set "current_script=%~nx0"
set "current_path=%~dp0"

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
echo PROTECTED FILES: %exclude_files%
echo PROTECTED EXTENSIONS: %exclude_extensions%
echo PROTECTED FOLDERS: %exclude_folders%
echo CURRENT SCRIPT: %current_script% (PROTECTED)
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
echo PROTECTED FILES: %exclude_files% >> "%logfile%"
echo PROTECTED EXTENSIONS: %exclude_extensions% >> "%logfile%"
echo PROTECTED FOLDERS: %exclude_folders% >> "%logfile%"
echo CURRENT SCRIPT: %current_script% (PROTECTED) >> "%logfile%"
echo. >> "%logfile%"

:: ==================================================
:: SAFE DELETE FUNCTION
:: ==================================================
:SafeDelete
setlocal
set "target_path=%~1"
set "file_name=%~nx1"
set "should_delete=1"

:: Check if it's the current script
if /i "%file_name%"=="%current_script%" (
    echo PROTECTED: Skipping current script %file_name% >> "%logfile%"
    set "should_delete=0"
    goto :SafeDeleteEnd
)

:: Check exclude files
for %%e in (%exclude_files%) do (
    if /i "%file_name%"=="%%e" (
        echo PROTECTED: Skipping excluded file %file_name% >> "%logfile%"
        set "should_delete=0"
        goto :SafeDeleteEnd
    )
)

:: Check exclude extensions
for %%e in (%exclude_extensions%) do (
    if /i "%~x1"=="%%e" (
        echo PROTECTED: Skipping file with excluded extension %file_name% >> "%logfile%"
        set "should_delete=0"
        goto :SafeDeleteEnd
    )
)

:: Check exclude folders (for folder names in path)
for %%e in (%exclude_folders%) do (
    echo %target_path% | findstr /i "%%e" >nul
    if !errorlevel! equ 0 (
        echo PROTECTED: Skipping file in excluded folder %file_name% >> "%logfile%"
        set "should_delete=0"
        goto :SafeDeleteEnd
    )
)

:SafeDeleteEnd
endlocal & set "should_delete=%should_delete%"
goto :eof

:: ==================================================
:: SAFE FOLDER DELETE FUNCTION
:: ==================================================
:SafeDeleteFolder
setlocal
set "folder_path=%~1"
set "folder_name=%~nx1"
set "should_delete=1"

:: Check exclude folders
for %%e in (%exclude_folders%) do (
    if /i "%folder_name%"=="%%e" (
        echo PROTECTED: Skipping excluded folder %folder_name% >> "%logfile%"
        set "should_delete=0"
        goto :SafeDeleteFolderEnd
    )
)

:SafeDeleteFolderEnd
endlocal & set "should_delete=%should_delete%"
goto :eof

ECHO.
ECHO Deleting User temp files...
echo Cleaning User temp files... >> "%logfile%"
if exist "%TEMP%" (
    for /f "delims=" %%f in ('dir /b "%TEMP%\*.*" 2^>nul') do (
        call :SafeDelete "%TEMP%\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %TEMP%\%%f >> "%logfile%"
            del /q /f "%TEMP%\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%TEMP%\*" 2^>nul') do (
        call :SafeDeleteFolder "%TEMP%\%%d"
        if !should_delete! equ 1 (
            echo Deleted folder: %TEMP%\%%d >> "%logfile%"
            rmdir /s /q "%TEMP%\%%d" 2>nul
        )
    )
)

echo Cleaning TMP files... >> "%logfile%"
if exist "%TMP%" (
    for /f "delims=" %%f in ('dir /b "%TMP%\*.*" 2^>nul') do (
        call :SafeDelete "%TMP%\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %TMP%\%%f >> "%logfile%"
            del /q /f "%TMP%\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%TMP%\*" 2^>nul') do (
        call :SafeDeleteFolder "%TMP%\%%d"
        if !should_delete! equ 1 (
            echo Deleted folder: %TMP%\%%d >> "%logfile%"
            rmdir /s /q "%TMP%\%%d" 2>nul
        )
    )
)

ECHO Deleting Local temp files...
echo Cleaning Local temp files... >> "%logfile%"
if exist "%USERPROFILE%\Local Settings\Temp" (
    for /f "delims=" %%f in ('dir /b "%USERPROFILE%\Local Settings\Temp\*.*" 2^>nul') do (
        call :SafeDelete "%USERPROFILE%\Local Settings\Temp\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %USERPROFILE%\Local Settings\Temp\%%f >> "%logfile%"
            del /q /f "%USERPROFILE%\Local Settings\Temp\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%USERPROFILE%\Local Settings\Temp\*" 2^>nul') do (
        call :SafeDeleteFolder "%USERPROFILE%\Local Settings\Temp\%%d"
        if !should_delete! equ 1 (
            echo Deleted folder: %USERPROFILE%\Local Settings\Temp\%%d >> "%logfile%"
            rmdir /s /q "%USERPROFILE%\Local Settings\Temp\%%d" 2>nul
        )
    )
)

echo Cleaning LocalAppData temp files... >> "%logfile%"
if exist "%LOCALAPPDATA%\Temp" (
    for /f "delims=" %%f in ('dir /b "%LOCALAPPDATA%\Temp\*.*" 2^>nul') do (
        call :SafeDelete "%LOCALAPPDATA%\Temp\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %LOCALAPPDATA%\Temp\%%f >> "%logfile%"
            del /q /f "%LOCALAPPDATA%\Temp\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%LOCALAPPDATA%\Temp\*" 2^>nul') do (
        call :SafeDeleteFolder "%LOCALAPPDATA%\Temp\%%d"
        if !should_delete! equ 1 (
            echo Deleted folder: %LOCALAPPDATA%\Temp\%%d >> "%logfile%"
            rmdir /s /q "%LOCALAPPDATA%\Temp\%%d" 2>nul
        )
    )
)

ECHO Deleting Windows temp files...
echo Cleaning Windows temp files... >> "%logfile%"
if exist "%WINDIR%\temp" (
    for /f "delims=" %%f in ('dir /b "%WINDIR%\temp\*.*" 2^>nul') do (
        call :SafeDelete "%WINDIR%\temp\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %WINDIR%\temp\%%f >> "%logfile%"
            del /q /f "%WINDIR%\temp\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%WINDIR%\Temp\*" 2^>nul') do (
        call :SafeDeleteFolder "%WINDIR%\Temp\%%d"
        if !should_delete! equ 1 (
            echo Deleted folder: %WINDIR%\Temp\%%d >> "%logfile%"
            rmdir /s /q "%WINDIR%\Temp\%%d" 2>nul
        )
    )
)

ECHO Cleaning Prefetch files...
echo Cleaning Prefetch files... >> "%logfile%"
if exist "%WINDIR%\Prefetch" (
    for /f "delims=" %%f in ('dir /b "%WINDIR%\Prefetch\*.*" 2^>nul') do (
        call :SafeDelete "%WINDIR%\Prefetch\%%f"
        if !should_delete! equ 1 (
            echo Deleted file: %WINDIR%\Prefetch\%%f >> "%logfile%"
            del /q /f "%WINDIR%\Prefetch\%%f" 2>nul
        )
    )
)

ECHO Cleaning Recent files...
echo Cleaning Recent files... >> "%logfile%"
for /f "delims=" %%f in ('dir /b "%USERPROFILE%\Recent\*.*" 2^>nul') do (
    call :SafeDelete "%USERPROFILE%\Recent\%%f"
    if !should_delete! equ 1 (
        echo Deleted file: %USERPROFILE%\Recent\%%f >> "%logfile%"
        del /q /f "%USERPROFILE%\Recent\%%f" 2>nul
    )
)

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

:: Chrome (Safe cleaning - only cache, not important files)
echo Cleaning Chrome cache... >> "%logfile%"
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    for /f "delims=" %%f in ('dir /b "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2^>nul') do (
        call :SafeDelete "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%f"
        if !should_delete! equ 1 (
            echo Deleted Chrome file: %LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%f >> "%logfile%"
            del /q /f "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" 2^>nul') do (
        call :SafeDeleteFolder "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%d"
        if !should_delete! equ 1 (
            echo Deleted Chrome folder: %LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%d >> "%logfile%"
            rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\%%d" 2>nul
        )
    )
)

:: Firefox (Safe cleaning - only cache)
echo Cleaning Firefox cache... >> "%logfile%"
for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
    if exist "%%p\cache2" (
        for /f "delims=" %%f in ('dir /b "%%p\cache2\*.*" 2^>nul') do (
            call :SafeDelete "%%p\cache2\%%f"
            if !should_delete! equ 1 (
                echo Deleted Firefox file: %%p\cache2\%%f >> "%logfile%"
                del /q /f "%%p\cache2\%%f" 2>nul
            )
        )
        for /f "delims=" %%d in ('dir /b /ad "%%p\cache2\*" 2^>nul') do (
            call :SafeDeleteFolder "%%p\cache2\%%d"
            if !should_delete! equ 1 (
                echo Deleted Firefox folder: %%p\cache2\%%d >> "%logfile%"
                rmdir /s /q "%%p\cache2\%%d" 2>nul
            )
        )
    )
)

:: Edge (Safe cleaning - only cache)
echo Cleaning Edge cache... >> "%logfile%"
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    for /f "delims=" %%f in ('dir /b "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" 2^>nul') do (
        call :SafeDelete "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%f"
        if !should_delete! equ 1 (
            echo Deleted Edge file: %LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%f >> "%logfile%"
            del /q /f "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%f" 2>nul
        )
    )
    for /f "delims=" %%d in ('dir /b /ad "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" 2^>nul') do (
        call :SafeDeleteFolder "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%d"
        if !should_delete! equ 1 (
            echo Deleted Edge folder: %LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%d >> "%logfile%"
            rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\%%d" 2>nul
        )
    )
)

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
echo PROTECTION SUMMARY:
echo - Current script protected: %current_script%
echo - Protected files: %exclude_files%
echo - Protected extensions: %exclude_extensions%
echo - Protected folders: %exclude_folders%
echo.
echo Cleanup mode: %cleanup_mode%
echo Log file created: %logfile%
echo.
PAUSE
