@echo off
:checkPrivileges
NET FILE >nul 2>&1
if '%errorlevel%'=='0' (
    goto gotPrivileges
) else (
    cls
    echo ==========================================================
    echo                MEMERLUKAN HAK ADMINISTRATOR
    echo ==========================================================
    echo.
    echo  Skrip ini perlu dijalankan dengan hak administrator
    echo  untuk mengubah pengaturan jaringan dan menampilkan
    echo  status TTL saat ini dengan benar.
    echo.
    echo  Mencoba meminta elevasi otomatis...
    echo  Jika dialog UAC muncul, silakan klik "Yes".
    echo.
    echo ==========================================================
    timeout /t 4 /nobreak >nul
    goto getPrivileges
)

:getPrivileges
set "vbsfile=%temp%\getadmin.vbs"
(
    echo Set UAC = CreateObject^("Shell.Application"^)
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %*", "", "runas", 1
) > "%vbsfile%"
cscript //nologo "%vbsfile%"
del /q "%vbsfile%"
exit /b

:gotPrivileges
cls
echo ==========================================================
echo        BERHASIL MENDAPATKAN HAK ADMINISTRATOR
echo ==========================================================
echo.
echo Skrip berjalan dengan hak administrator
timeout /t 2 /nobreak >nul

set "PS_SCRIPT_PATH=E:\Windows\winScript\windowsTTL\WindowsTimeToLive_changer.ps1"
title TTL PS Script Launcher

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_PATH%"
REM powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%PS_SCRIPT_PATH%"
REM powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT_PATH%"

pause