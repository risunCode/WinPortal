@echo off
setlocal EnableDelayedExpansion

mode con: cols=80 lines=35
color 0E

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
goto menu

:getCurrentTTL
    set "currentTTL_IPv4=N/A"
    set "currentTTL_IPv6=N/A"

    REM --- Get Current IPv4 TTL ---
    for /f "tokens=1,* delims=:" %%a in ('netsh int ipv4 show global ^| findstr /C:"Default Hop Limit"') do (
        set "ttl_val_ipv4=%%b"
        for /f "tokens=* delims= " %%x in ("!ttl_val_ipv4!") do set "currentTTL_IPv4=%%x"
    )
    if "!currentTTL_IPv4!"=="" set "currentTTL_IPv4=Tidak ditemukan"

    REM --- Get Current IPv6 TTL ---
    for /f "tokens=1,* delims=:" %%c in ('netsh int ipv6 show global ^| findstr /C:"Default Hop Limit"') do (
        set "ttl_val_ipv6=%%d"
        for /f "tokens=* delims= " %%y in ("!ttl_val_ipv6!") do set "currentTTL_IPv6=%%y"
    )
    if "!currentTTL_IPv6!"=="" set "currentTTL_IPv6=Tidak ditemukan"
goto :eof

:menu
cls
call :getCurrentTTL
echo ==========================================================
echo                Windows TTL Editor ~ Unlock Tethering Throttle!
echo ==========================================================
echo.
echo  NOTE: saat windows di reboot, Settingan TTL akan otomatis menjadi default
echo  TTL Hop Limit Saat Ini:
echo    IPv4 : !currentTTL_IPv4!
echo    IPv6 : !currentTTL_IPv6!
echo.
echo ----------------------------------------------------------
echo  Pilih salah satu opsi di bawah ini:
echo.
echo    [1] Set TTL Hop Limit ke 65 (Bypass Tethering)
echo    [2] Set TTL Hop Limit ke Default Windows (128)
echo    [3] Set TTL Hop Limit ke Angka Custom
echo    [4] Batal / Keluar
echo.
echo ==========================================================

REM /N untuk menyembunyikan daftar pilihan default [1,2,3,4]?
CHOICE /C 1234 /N /M "Tekan tombol angka untuk memilih opsi: "

REM Periksa errorlevel dari yang tertinggi ke terendah
if errorlevel 4 goto exitScript
if errorlevel 3 goto runCustom
if errorlevel 2 goto runDefault
if errorlevel 1 goto runWin65

REM Jika ada kondisi tak terduga (seharusnya tidak terjadi dengan CHOICE /C)
echo Input tidak dikenal, kembali ke menu secara otomatis.
timeout /t 1 /nobreak >nul
goto menu

:runWin65
cls
echo ==========================================================
echo         MENGATUR TTL HOP LIMIT KE 65...
echo ==========================================================
echo.
netsh int ipv4 set glob defaultcurhoplimit=65
netsh int ipv6 set glob defaultcurhoplimit=65
echo.
echo TTL Hop Limit berhasil diatur ke 65 (Bypass Tethering).
echo Kembali ke menu utama...
timeout /t 2 /nobreak >nul
goto menu

:runDefault
cls
echo ==========================================================
echo         MENGATUR TTL HOP LIMIT KE DEFAULT (128)...
echo ==========================================================
echo.
netsh int ipv4 set glob defaultcurhoplimit=128
netsh int ipv6 set glob defaultcurhoplimit=128
echo.
echo TTL Hop Limit berhasil diatur ke 128 (Default Windows).
echo Kembali ke menu utama...
timeout /t 2 /nobreak >nul
goto menu

:runCustom
cls
echo ==========================================================
echo            SET TTL HOP LIMIT CUSTOM
echo ==========================================================
echo.
echo  Masukkan nilai TTL yang diinginkan (1-255):
echo.
echo  Contoh nilai umum:
echo    - 64  : Linux/Android default
echo    - 65  : Bypass tethering
echo    - 128 : Windows default
echo    - 255 : Maximum value
echo.
echo ----------------------------------------------------------

:inputCustomTTL
set /p customTTL="Masukkan nilai TTL (1-255) atau ketik 'back' untuk kembali: "

REM Check if user wants to go back
if /i "%customTTL%"=="back" goto menu
if /i "%customTTL%"=="b" goto menu

REM Check if input is empty
if "%customTTL%"=="" (
    echo.
    echo Error: Nilai tidak boleh kosong!
    echo.
    goto inputCustomTTL
)

REM Check if input is numeric
for /f "delims=0123456789" %%i in ("%customTTL%") do (
    echo.
    echo Error: Masukkan hanya angka!
    echo.
    goto inputCustomTTL
)

REM Check if input is within valid range (1-255)
if %customTTL% LSS 1 (
    echo.
    echo Error: Nilai TTL harus minimal 1!
    echo.
    goto inputCustomTTL
)

if %customTTL% GTR 255 (
    echo.
    echo Error: Nilai TTL maksimal 255!
    echo.
    goto inputCustomTTL
)

REM Confirm the custom value
echo.
echo ----------------------------------------------------------
echo  Anda akan mengatur TTL Hop Limit ke: %customTTL%
echo ----------------------------------------------------------
echo.
CHOICE /C YN /N /M "Lanjutkan? (Y/N): "

if errorlevel 2 goto inputCustomTTL
if errorlevel 1 goto applyCustomTTL

:applyCustomTTL
cls
echo ==========================================================
echo         MENGATUR TTL HOP LIMIT KE %customTTL%...
echo ==========================================================
echo.
echo Mengatur TTL IPv4 ke %customTTL%...
netsh int ipv4 set glob defaultcurhoplimit=%customTTL%
echo.
echo Mengatur TTL IPv6 ke %customTTL%...
netsh int ipv6 set glob defaultcurhoplimit=%customTTL%
echo.
echo TTL Hop Limit berhasil diatur ke %customTTL%.
echo Kembali ke menu utama...
timeout /t 3 /nobreak >nul
goto menu

:exitScript
cls
echo ==========================================================
echo                   KELUAR DARI SKRIP
echo ==========================================================
echo.
echo Terima kasih telah menggunakan skrip ini, konsol akan ditutup dalam 3 detik.
timeout /t 2 /nobreak >nul
exit /b