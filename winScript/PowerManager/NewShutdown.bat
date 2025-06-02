@echo off
mode con: cols=70 lines=12
title Shutdown Manager oleh risunCode
color 0E
cls

set "logfile=Shutdown-%username%.txt"

:main
cls
echo ===================================================================
echo                          SHUTDOWN MANAGER
echo                         by: github/risunCode
echo ===================================================================
echo.
echo Apakah Anda yakin ingin melanjutkan? (Y/N)
choice /c YN /n /d N /t 20
if errorlevel 2 goto :cancel

:menu
cls
echo ===================================================================
echo                          SHUTDOWN MANAGER
echo                         by: github/risunCode
echo ===================================================================
echo.
echo Pilih opsi yang diinginkan:
echo.
echo 1. Shutdown Paksa (shutdown /s /f /t 0)
echo 2. Shutdown Normal (shutdown /s)
echo 3. Boot ke Menu UEFI (shutdown /r /fw /t 0)
echo 4. Sleep Mode (standby)
echo 5. Hibernate
echo 6. Reboot System (restart normal)
echo 7. Soft Reboot (restart dengan opsi /soft)
echo 8. Custom Command (cmd kustom)
echo 9. Kembali (batalkan operasi)
echo.
choice /c 123456789 /n /m "Pilih nomor (1-9): "

set "datetime=%date% %time%"

if errorlevel 9 goto :cancel
if errorlevel 8 goto :custom
if errorlevel 7 goto :softreboot
if errorlevel 6 goto :reboot
if errorlevel 5 goto :hibernate
if errorlevel 4 goto :sleep
if errorlevel 3 goto :uefi
if errorlevel 2 goto :normal
if errorlevel 1 goto :force

:force
cls
echo Komputer akan dimatikan secara paksa dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Shutdown Paksa, Pastikan semua app sudah close!
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Shutdown paksa pada tanggal %datetime% >> "%logfile%"
shutdown /s /f /t 0
exit

:normal
cls
echo Komputer akan dimatikan secara normal dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Shutdown Normal, Pastikan semua app sudah close!
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Shutdown normal pada tanggal %datetime% >> "%logfile%"
shutdown /s /t 0
exit

:uefi
cls
echo Boot ke menu UEFI dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Boot ke Menu UEFI
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Boot ke UEFI pada tanggal %datetime% >> "%logfile%"
shutdown /r /fw /t 0
exit

:sleep
cls
echo Komputer akan masuk mode Sleep dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Sleep Mode (Standby)
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Sleep mode pada tanggal %datetime% >> "%logfile%"
powercfg -hibernate off >nul
rundll32.exe powrprof.dll,SetSuspendState 0,1,0
exit

:hibernate
cls
echo Komputer akan masuk mode Hibernate dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Hibernate Mode
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Hibernate mode pada tanggal %datetime% >> "%logfile%"
powercfg -hibernate on >nul
rundll32.exe powrprof.dll,SetSuspendState Hibernate
exit

:reboot
cls
echo Komputer akan di-restart dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Reboot System
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Reboot system pada tanggal %datetime% >> "%logfile%"
shutdown /r /t 0
exit

:softreboot
cls
echo Komputer akan di-soft reboot dalam 6 detik...
for /l %%i in (4,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Soft Reboot
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
echo Soft reboot pada tanggal %datetime% >> "%logfile%"
shutdown /r /soft /t 0
exit

:custom
cls
echo ===================================================================
echo                     CUSTOM COMMAND EXECUTION
echo ===================================================================
echo.
echo Masukkan command shutdown kustom yang ingin dijalankan:
echo (contoh: shutdown /r /o /t 0 untuk restart ke advanced options)
echo.
set /p cmd_custom="Command: shutdown "
cls
echo ===================================================================
echo Pilihan User : Custom Command
echo Command yang akan dijalankan: shutdown %cmd_custom%
echo ===================================================================
echo.
echo Apakah Anda yakin ingin menjalankan command ini? (Y/N)
choice /c YN /n
if errorlevel 2 goto :menu

echo Command kustom: shutdown %cmd_custom% pada tanggal %datetime% >> "%logfile%"
shutdown %cmd_custom%
exit

:cancel
cls
echo Operasi dibatalkan. Menunggu 3 detik sebelum menutup...
for /l %%i in (3,-1,1) do (
    cls
    echo ===================================================================
    echo Pilihan User : Operasi Dibatalkan
    echo ===================================================================
    echo.
    echo Countdown : %%i detik
    timeout /t 1 >nul
)
exit