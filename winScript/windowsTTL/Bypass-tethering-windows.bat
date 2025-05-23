@echo off
setlocal EnableDelayedExpansion

mode con: cols=80 lines=30
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
echo                PENGATURAN TTL HOP LIMIT
echo ==========================================================
echo.
echo  TTL Hop Limit Saat Ini:
echo    IPv4 : !currentTTL_IPv4!
echo    IPv6 : !currentTTL_IPv6!
echo.
echo ----------------------------------------------------------
echo  Pilih salah satu opsi di bawah ini:
echo.
echo    [1] Set TTL Hop Limit ke 65 (Bypass Tethering)
echo    [2] Set TTL Hop Limit ke Default Windows (128)
echo    [3] Batal / Keluar
echo.
echo ==========================================================

REM /N untuk menyembunyikan daftar pilihan default [1,2,3]?
CHOICE /C 123 /N /M "Tekan tombol angka untuk memilih opsi: "

REM Periksa errorlevel dari yang tertinggi ke terendah
if errorlevel 3 goto exitScript
if errorlevel 2 goto runDefault
if errorlevel 1 goto runWin65

REM Jika ada kondisi tak terduga (seharusnya tidak terjadi dengan CHOICE /C)
echo Input tidak dikenal, kembali ke menu secara otomatis.
timeout /t 2 /nobreak >nul
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
timeout /t 3 /nobreak >nul
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
timeout /t 3 /nobreak >nul
goto menu

:exitScript
cls
echo ==========================================================
echo                   KELUAR DARI SKRIP
echo ==========================================================
echo.
echo Terima kasih telah menggunakan skrip ini, konsol akan ditutup dalam 3 detik.
timeout /t 3 /nobreak >nul
exit /b