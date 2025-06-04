@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE WiFi Manager - Backup & Restore Tool
COLOR 0E

REM Save original script path before elevation
SET "ORIGINAL_PATH=%~dp0"
SET "SCRIPT_PATH=%~f0"

REM Check Administrator Privileges
:checkPrivileges
NET FILE >nul 2>&1
if '%errorlevel%'=='0' (
    goto gotPrivileges
) else (
    cls
    ECHO ==========================================================
    ECHO                MEMERLUKAN HAK ADMINISTRATOR
    ECHO ==========================================================
    ECHO.
    ECHO  Skrip ini perlu dijalankan dengan hak administrator
    ECHO  untuk mengubah pengaturan jaringan dan menampilkan
    ECHO  password WiFi dengan benar.
    ECHO.
    ECHO  Mencoba meminta elevasi otomatis...
    ECHO  Jika dialog UAC muncul, silakan klik "Yes".
    ECHO.
    ECHO ==========================================================
    goto getPrivileges
)

:getPrivileges
set "vbsfile=%temp%\getadmin.vbs"
(
    echo Set UAC = CreateObject^("Shell.Application"^)
    echo UAC.ShellExecute "cmd.exe", "/c ""cd /d %ORIGINAL_PATH% && %SCRIPT_PATH%"" %*", "", "runas", 1
) > "%vbsfile%"
cscript //nologo "%vbsfile%"
del /q "%vbsfile%"
exit /b

:gotPrivileges
REM Change to original script directory
CD /D "%ORIGINAL_PATH%"
cls
ECHO ==========================================================
ECHO        BERHASIL MENDAPATKAN HAK ADMINISTRATOR
ECHO ==========================================================
ECHO.
ECHO Skrip berjalan dengan hak administrator
ECHO Working Directory: %CD%
TIMEOUT /T 2 >NUL

REM Set backup folder (relative to script location)
SET BACKUP_FOLDER=SavedWifiBackups

:MAIN_MENU
CLS
ECHO ===============================================
ECHO          WiFi Manager - Backup ^& Restore
ECHO ===============================================
ECHO.

REM Get current WiFi profiles count
FOR /F "tokens=*" %%A IN ('netsh wlan show profiles ^| find "All User Profile" ^| find /c /v ""') DO SET CURRENT_PROFILES=%%A

REM Check backup count
SET BACKUP_COUNT=0
IF EXIST "%BACKUP_FOLDER%" (
    FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO SET /A BACKUP_COUNT+=1
)

ECHO Current WiFi Networks: %CURRENT_PROFILES%
ECHO Saved WiFi Backups: %BACKUP_COUNT%
IF EXIST "%BACKUP_FOLDER%" (
    ECHO Backup Folder: %BACKUP_FOLDER%\ [EXISTS]
) ELSE (
    ECHO Backup Folder: %BACKUP_FOLDER%\ [NOT CREATED]
)
ECHO.
ECHO ===============================================
ECHO [1] Backup WiFi Profiles
ECHO [2] Restore All WiFi Profiles  
ECHO [3] View Saved Profiles
ECHO [4] Remove All Current Profiles
ECHO [5] Delete All Backups
ECHO [Q] Quit
ECHO ===============================================
ECHO.
CHOICE /C 12345Q /N /M "Select option: "

IF ERRORLEVEL 6 GOTO EXIT
IF ERRORLEVEL 5 GOTO DELETE_BACKUPS
IF ERRORLEVEL 4 GOTO REMOVE_ALL_PROFILES
IF ERRORLEVEL 3 GOTO VIEW_PROFILES_MENU
IF ERRORLEVEL 2 GOTO RESTORE_PROFILES
IF ERRORLEVEL 1 GOTO BACKUP_PROFILES

:BACKUP_PROFILES
CLS
ECHO ===============================================
ECHO           Backing up WiFi Profiles...
ECHO ===============================================
ECHO.

IF NOT EXIST "%BACKUP_FOLDER%" (
    MKDIR "%BACKUP_FOLDER%"
    ECHO Created backup folder: %BACKUP_FOLDER%\
    ECHO.
)

PUSHD "%BACKUP_FOLDER%"
netsh wlan export profile key=clear
POPD

SET EXPORTED_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO SET /A EXPORTED_COUNT+=1

ECHO.
ECHO Backup completed successfully!
ECHO Exported %EXPORTED_COUNT% WiFi profiles to %BACKUP_FOLDER%\
ECHO.
ECHO ===============================================
ECHO [1] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 1Q /N /M "Select option: "
IF ERRORLEVEL 2 GOTO EXIT
IF ERRORLEVEL 1 GOTO MAIN_MENU

:RESTORE_PROFILES
CLS
ECHO ===============================================
ECHO          Restoring WiFi Profiles...
ECHO ===============================================
ECHO.

IF NOT EXIST "%BACKUP_FOLDER%" (
    ECHO Error: Backup folder not found! Please backup first.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

SET XML_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO SET /A XML_COUNT+=1

IF %XML_COUNT%==0 (
    ECHO No WiFi backup files found in %BACKUP_FOLDER%\
    ECHO Please backup WiFi profiles first.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

ECHO Found %XML_COUNT% WiFi profiles to restore.
ECHO.
ECHO ===============================================
ECHO [Y] Continue with restore ALL profiles
ECHO [N] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C YNQ /N /M "Select option: "
IF ERRORLEVEL 3 GOTO EXIT
IF ERRORLEVEL 2 GOTO MAIN_MENU

ECHO.
ECHO Restoring profiles...
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO (
    ECHO Importing: %%~nF
    netsh wlan add profile "%%F" >NUL 2>&1
)

ECHO.
ECHO Restore completed successfully!
ECHO.
ECHO ===============================================
ECHO [1] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 1Q /N /M "Select option: "
IF ERRORLEVEL 2 GOTO EXIT
IF ERRORLEVEL 1 GOTO MAIN_MENU

:REMOVE_ALL_PROFILES
CLS
ECHO ===============================================
ECHO         Remove All Current WiFi Profiles
ECHO ===============================================
ECHO.

ECHO This will remove ALL WiFi profiles from your system!
ECHO Current WiFi Networks: %CURRENT_PROFILES%
ECHO.
ECHO ===============================================
ECHO [Y] Remove ALL profiles
ECHO [N] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C YNQ /N /M "Select option: "
IF ERRORLEVEL 3 GOTO EXIT
IF ERRORLEVEL 2 GOTO MAIN_MENU

ECHO.
ECHO Removing all WiFi profiles...
FOR /F "tokens=2 delims=:" %%A IN ('netsh wlan show profiles ^| findstr "All User Profile"') DO (
    SET "PROFILE_NAME=%%A"
    SET "PROFILE_NAME=!PROFILE_NAME:~1!"
    ECHO Removing: !PROFILE_NAME!
    netsh wlan delete profile name="!PROFILE_NAME!" >NUL 2>&1
)

ECHO.
ECHO All WiFi profiles removed successfully!
ECHO.
ECHO ===============================================
ECHO [1] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 1Q /N /M "Select option: "
IF ERRORLEVEL 2 GOTO EXIT
IF ERRORLEVEL 1 GOTO MAIN_MENU

:VIEW_PROFILES_MENU
CLS
ECHO ===============================================
ECHO            Saved WiFi Profiles
ECHO ===============================================
ECHO.

IF NOT EXIST "%BACKUP_FOLDER%" (
    ECHO No backup folder found.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

SET PROFILE_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO SET /A PROFILE_COUNT+=1

IF %PROFILE_COUNT%==0 (
    ECHO No saved WiFi profiles found.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

ECHO Total: %PROFILE_COUNT% saved profiles
ECHO.
ECHO ===============================================
ECHO [1] List All Profiles ^& View Password
ECHO [2] Search WiFi by Name
ECHO [3] Show All Passwords
ECHO [4] Selective Restore
ECHO [B] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 1234BQ /N /M "Select option: "

IF ERRORLEVEL 6 GOTO EXIT
IF ERRORLEVEL 5 GOTO MAIN_MENU
IF ERRORLEVEL 4 GOTO SELECTIVE_RESTORE
IF ERRORLEVEL 3 GOTO SHOW_ALL_PASSWORDS
IF ERRORLEVEL 2 GOTO SEARCH_WIFI
IF ERRORLEVEL 1 GOTO LIST_PROFILES

:LIST_PROFILES
CLS
ECHO ===============================================
ECHO          Select WiFi Profile to View
ECHO ===============================================
ECHO.

SET PROFILE_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO (
    SET /A PROFILE_COUNT+=1
    SET "PROFILE_!PROFILE_COUNT!=%%~nF"
    ECHO [!PROFILE_COUNT!] %%~nF
)

ECHO.
ECHO [0] Back to Profiles Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
SET /P SELECTION="Enter profile number (0-%PROFILE_COUNT% or Q): "

IF /I "%SELECTION%"=="Q" GOTO EXIT
IF "%SELECTION%"=="0" GOTO VIEW_PROFILES_MENU
IF %SELECTION% GTR %PROFILE_COUNT% (
    ECHO Invalid selection!
    PAUSE
    GOTO LIST_PROFILES
)
IF %SELECTION% LSS 1 (
    ECHO Invalid selection!
    PAUSE
    GOTO LIST_PROFILES
)

FOR /L %%i IN (1,1,%PROFILE_COUNT%) DO (
    IF %SELECTION%==%%i (
        SET "SELECTED_PROFILE=!PROFILE_%%i!"
        GOTO SHOW_PASSWORD
    )
)

:SHOW_PASSWORD
CLS
ECHO ===============================================
ECHO          WiFi Profile: %SELECTED_PROFILE%
ECHO ===============================================
ECHO.

SET "XML_FILE=%BACKUP_FOLDER%\%SELECTED_PROFILE%.xml"
SET "PASSWORD="

REM Fixed password extraction - handle multiple lines and special characters
FOR /F "usebackq delims=" %%A IN (`TYPE "%XML_FILE%" 2^>nul ^| findstr /C:"<keyMaterial>"`) DO (
    SET "LINE=%%A"
    REM Remove leading/trailing spaces and tabs
    FOR /F "tokens=*" %%B IN ("!LINE!") DO SET "CLEAN_LINE=%%B"
    REM Extract password: find <keyMaterial> and </keyMaterial>
    SET "TEMP_LINE=!CLEAN_LINE:*<keyMaterial>=!"
    FOR /F "tokens=1 delims=<" %%C IN ("!TEMP_LINE!") DO SET "PASSWORD=%%C"
    REM Remove any remaining spaces
    FOR /F "tokens=*" %%D IN ("!PASSWORD!") DO SET "PASSWORD=%%D"
)

IF DEFINED PASSWORD (
    IF "!PASSWORD!"=="" (
        ECHO WiFi Name: %SELECTED_PROFILE%
        ECHO Password: [No password / Open network]
    ) ELSE (
        ECHO WiFi Name: %SELECTED_PROFILE%
        ECHO Password: !PASSWORD!
    )
) ELSE (
    ECHO WiFi Name: %SELECTED_PROFILE%
    ECHO Password: [No password / Open network]
)

ECHO.
ECHO ===============================================
ECHO [1] View Another Profile
ECHO [2] Back to Profiles Menu
ECHO [3] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 123Q /N /M "Select option: "

IF ERRORLEVEL 4 GOTO EXIT
IF ERRORLEVEL 3 GOTO MAIN_MENU
IF ERRORLEVEL 2 GOTO VIEW_PROFILES_MENU
IF ERRORLEVEL 1 GOTO LIST_PROFILES

:SEARCH_WIFI
CLS
ECHO ===============================================
ECHO              Search WiFi Profile
ECHO ===============================================
ECHO.
SET /P SEARCH_TERM="Enter WiFi name to search (or Q to exit): "

IF /I "%SEARCH_TERM%"=="Q" GOTO EXIT
IF "%SEARCH_TERM%"=="" (
    ECHO Please enter a search term!
    PAUSE
    GOTO SEARCH_WIFI
)

ECHO.
ECHO Search results for: "%SEARCH_TERM%"
ECHO ===============================================
SET FOUND_COUNT=0

FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO (
    SET "FILENAME=%%~nF"
    ECHO !FILENAME! | FINDSTR /I /C:"%SEARCH_TERM%" >NUL
    IF !ERRORLEVEL!==0 (
        SET /A FOUND_COUNT+=1
        ECHO [!FOUND_COUNT!] %%~nF
        SET "FOUND_!FOUND_COUNT!=%%~nF"
    )
)

IF %FOUND_COUNT%==0 (
    ECHO No profiles found containing "%SEARCH_TERM%"
    ECHO.
    ECHO ===============================================
    ECHO [1] Search Again
    ECHO [2] Back to Profiles Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 12Q /N /M "Select option: "
    IF ERRORLEVEL 3 GOTO EXIT
    IF ERRORLEVEL 2 GOTO VIEW_PROFILES_MENU
    IF ERRORLEVEL 1 GOTO SEARCH_WIFI
) ELSE (
    ECHO.
    ECHO [0] Search Again
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    SET /P SELECTION="Enter profile number to view (0-%FOUND_COUNT% or Q): "
    
    IF /I "%SELECTION%"=="Q" GOTO EXIT
    IF "%SELECTION%"=="0" GOTO SEARCH_WIFI
    IF %SELECTION% GTR %FOUND_COUNT% (
        ECHO Invalid selection!
        PAUSE
        GOTO SEARCH_WIFI
    )
    IF %SELECTION% LSS 1 (
        ECHO Invalid selection!
        PAUSE
        GOTO SEARCH_WIFI
    )
    
    FOR /L %%i IN (1,1,%FOUND_COUNT%) DO (
        IF %SELECTION%==%%i (
            SET "SELECTED_PROFILE=!FOUND_%%i!"
            GOTO SHOW_PASSWORD
        )
    )
)

:SHOW_ALL_PASSWORDS
CLS
ECHO ===============================================
ECHO            All WiFi Passwords
ECHO ===============================================
ECHO.

SET DISPLAY_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO (
    SET /A DISPLAY_COUNT+=1
    SET "CURRENT_NAME=%%~nF"
    SET "PASSWORD="
    SET "XML_FILE=%%F"
    
    REM Fixed password extraction for show all passwords
    FOR /F "usebackq delims=" %%A IN (`TYPE "!XML_FILE!" 2^>nul ^| findstr /C:"<keyMaterial>"`) DO (
        SET "LINE=%%A"
        REM Remove leading/trailing spaces and tabs
        FOR /F "tokens=*" %%B IN ("!LINE!") DO SET "CLEAN_LINE=%%B"
        REM Extract password: find <keyMaterial> and </keyMaterial>
        SET "TEMP_LINE=!CLEAN_LINE:*<keyMaterial>=!"
        FOR /F "tokens=1 delims=<" %%C IN ("!TEMP_LINE!") DO SET "PASSWORD=%%C"
        REM Remove any remaining spaces
        FOR /F "tokens=*" %%D IN ("!PASSWORD!") DO SET "PASSWORD=%%D"
    )
    
    IF DEFINED PASSWORD (
        IF "!PASSWORD!"=="" (
            ECHO [!DISPLAY_COUNT!] !CURRENT_NAME! : [No password / Open]
        ) ELSE (
            ECHO [!DISPLAY_COUNT!] !CURRENT_NAME! : !PASSWORD!
        )
    ) ELSE (
        ECHO [!DISPLAY_COUNT!] !CURRENT_NAME! : [No password / Open]
    )
    
    REM Clear password for next iteration
    SET "PASSWORD="
)

ECHO.
ECHO ===============================================
ECHO Showing %DISPLAY_COUNT% WiFi profiles
ECHO.
ECHO ===============================================
ECHO [1] Back to Profiles Menu
ECHO [2] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 12Q /N /M "Select option: "
IF ERRORLEVEL 3 GOTO EXIT
IF ERRORLEVEL 2 GOTO MAIN_MENU
IF ERRORLEVEL 1 GOTO VIEW_PROFILES_MENU

:SELECTIVE_RESTORE
CLS
ECHO ===============================================
ECHO            Selective WiFi Restore
ECHO ===============================================
ECHO.

SET PROFILE_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO (
    SET /A PROFILE_COUNT+=1
    SET "PROFILE_!PROFILE_COUNT!=%%~nF"
    ECHO [!PROFILE_COUNT!] %%~nF
)

ECHO.
ECHO ===============================================
ECHO Enter profile numbers separated by commas
ECHO Example: 1,3,5,7 or 2,4,6
ECHO.
ECHO [0] Back to Profiles Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
SET /P SELECTION="Enter numbers (or Q to exit): "

IF /I "%SELECTION%"=="Q" GOTO EXIT
IF "%SELECTION%"=="0" GOTO VIEW_PROFILES_MENU
IF "%SELECTION%"=="" (
    ECHO Please enter at least one number!
    PAUSE
    GOTO SELECTIVE_RESTORE
)

ECHO.
ECHO Restoring selected profiles...
ECHO ===============================================

SET "NUMBERS=%SELECTION%"
SET "RESTORED_COUNT=0"

:PARSE_NUMBERS
FOR /F "tokens=1* delims=," %%A IN ("%NUMBERS%") DO (
    SET "CURRENT_NUM=%%A"
    SET "NUMBERS=%%B"
    
    SET "CURRENT_NUM=!CURRENT_NUM: =!"
    
    IF !CURRENT_NUM! GEQ 1 IF !CURRENT_NUM! LEQ %PROFILE_COUNT% (
        FOR /L %%i IN (1,1,%PROFILE_COUNT%) DO (
            IF !CURRENT_NUM!==%%i (
                SET "RESTORE_PROFILE=!PROFILE_%%i!"
                ECHO Restoring [!CURRENT_NUM!]: !RESTORE_PROFILE!
                netsh wlan add profile "%BACKUP_FOLDER%\!RESTORE_PROFILE!.xml" >NUL 2>&1
                SET /A RESTORED_COUNT+=1
            )
        )
    ) ELSE (
        ECHO Invalid number: !CURRENT_NUM! (skipped)
    )
)

IF DEFINED NUMBERS GOTO PARSE_NUMBERS

ECHO ===============================================
ECHO Selective restore completed!
ECHO Restored %RESTORED_COUNT% WiFi profiles.
ECHO.
ECHO ===============================================
ECHO [1] Back to Profiles Menu
ECHO [2] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 12Q /N /M "Select option: "
IF ERRORLEVEL 3 GOTO EXIT
IF ERRORLEVEL 2 GOTO MAIN_MENU
IF ERRORLEVEL 1 GOTO VIEW_PROFILES_MENU

:DELETE_BACKUPS
CLS
ECHO ===============================================
ECHO            Delete All Backups
ECHO ===============================================
ECHO.

IF NOT EXIST "%BACKUP_FOLDER%" (
    ECHO No backup folder found.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

SET DELETE_COUNT=0
FOR %%F IN ("%BACKUP_FOLDER%\*.xml") DO SET /A DELETE_COUNT+=1

IF %DELETE_COUNT%==0 (
    ECHO No backup files to delete.
    ECHO.
    ECHO ===============================================
    ECHO [1] Back to Main Menu
    ECHO [Q] Exit Script
    ECHO ===============================================
    ECHO.
    CHOICE /C 1Q /N /M "Select option: "
    IF ERRORLEVEL 2 GOTO EXIT
    IF ERRORLEVEL 1 GOTO MAIN_MENU
)

ECHO Found %DELETE_COUNT% backup files.
ECHO This will permanently delete all WiFi backup files!
ECHO.
ECHO ===============================================
ECHO [Y] Delete all backups
ECHO [N] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C YNQ /N /M "Select option: "
IF ERRORLEVEL 3 GOTO EXIT
IF ERRORLEVEL 2 GOTO MAIN_MENU

DEL /Q "%BACKUP_FOLDER%\*.xml" >NUL 2>&1
ECHO.
ECHO All backup files deleted successfully!
ECHO.
ECHO ===============================================
ECHO [1] Back to Main Menu
ECHO [Q] Exit Script
ECHO ===============================================
ECHO.
CHOICE /C 1Q /N /M "Select option: "
IF ERRORLEVEL 2 GOTO EXIT
IF ERRORLEVEL 1 GOTO MAIN_MENU

:EXIT
CLS
ECHO.
ECHO Thank you for using WiFi Manager!
TIMEOUT /T 2 >NUL
EXIT /B 0