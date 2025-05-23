#requires -RunAsAdministrator

# --- Pengaturan Awal Konsol ---
$Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Yellow # Kuning Cerah
$Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Black
$Host.UI.RawUI.WindowTitle = "Pengaturan TTL Hop Limit"

# Mengatur ukuran jendela konsol (sesuaikan jika perlu)
try {
    $WindowSize = $Host.UI.RawUI.WindowSize
    $WindowSize.Width = 80
    $WindowSize.Height = 30
    $Host.UI.RawUI.WindowSize = $WindowSize

    # Pastikan buffer size cukup
    $BufferSize = $Host.UI.RawUI.BufferSize
    if ($BufferSize.Width -lt $WindowSize.Width) { $BufferSize.Width = $WindowSize.Width }
    if ($BufferSize.Height -lt $WindowSize.Height) { $BufferSize.Height = $WindowSize.Height + 50 } # Beri sedikit ruang buffer
    $Host.UI.RawUI.BufferSize = $BufferSize
}
catch {
    Write-Warning "Tidak dapat mengatur ukuran jendela konsol: $($_.Exception.Message)"
}

Clear-Host
Write-Host "=========================================================="
Write-Host "       BERHASIL MENDAPATKAN HAK ADMINISTRATOR"
Write-Host "=========================================================="
Write-Host ""
Write-Host "Skrip berjalan dengan hak administrator."
Start-Sleep -Seconds 2

# --- Fungsi-Fungsi ---

function Get-CurrentTTLs {
    $output = [PSCustomObject]@{
        IPv4TTL = "N/A"
        IPv6TTL = "N/A"
    }
    try {
        $ipv4Settings = Get-NetIPGlobalSetting -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipv4Settings) {
            $output.IPv4TTL = $ipv4Settings.DefaultHopLimit
        } else {
            # Write-Warning "Get-NetIPGlobalSetting untuk IPv4 tidak mengembalikan data."
        }

        $ipv6Settings = Get-NetIPGlobalSetting -AddressFamily IPv6 -ErrorAction SilentlyContinue
        if ($ipv6Settings) {
            $output.IPv6TTL = $ipv6Settings.DefaultHopLimit
        } else {
            # Write-Warning "Get-NetIPGlobalSetting untuk IPv6 tidak mengembalikan data."
        }
    }
    catch {
        Write-Warning "Terjadi kesalahan saat mengambil TTL: $($_.Exception.Message)"
    }
    return $output
}

function Set-HopLimit {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Limit,
        [string]$MessageSuffix = ""
    )
    try {
        Set-NetIPGlobalSetting -AddressFamily IPv4 -DefaultHopLimit $Limit -ErrorAction Stop
        Set-NetIPGlobalSetting -AddressFamily IPv6 -DefaultHopLimit $Limit -ErrorAction Stop
        Write-Host "TTL Hop Limit berhasil diatur ke $Limit$MessageSuffix." # Pesan tanpa warna spesifik, akan jadi kuning
        return $true
    }
    catch {
        Write-Error "Gagal mengatur TTL Hop Limit: $($_.Exception.Message)"
        return $false
    }
}

function Show-Menu {
    param(
        [PSCustomObject]$CurrentTTLs
    )
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "               PENGATURAN TTL HOP LIMIT"
    Write-Host "=========================================================="
    Write-Host ""
    Write-Host " TTL Hop Limit Saat Ini:"
    Write-Host "   IPv4 : $($CurrentTTLs.IPv4TTL)"
    Write-Host "   IPv6 : $($CurrentTTLs.IPv6TTL)"
    Write-Host ""
    Write-Host "----------------------------------------------------------"
    Write-Host " Pilih salah satu opsi di bawah ini:"
    Write-Host ""
    Write-Host "   [1] Set TTL Hop Limit ke 65 (Bypass Tethering)"
    Write-Host "   [2] Set TTL Hop Limit ke Default Windows (128)"
    Write-Host "   [3] Batal / Keluar"
    Write-Host ""
    Write-Host "=========================================================="
    Write-Host "Tekan tombol angka untuk memilih opsi: " -NoNewline

    # Menunggu input tombol tanpa perlu Enter
    $options = [System.Management.Automation.Host.ReadKeyOptions]::NoEcho -bor [System.Management.Automation.Host.ReadKeyOptions]::IncludeKeyDown
    $keyInfo = $Host.UI.ReadKey($options)
    return $keyInfo.Character
}

# --- Loop Utama Skrip ---
do {
    $ttls = Get-CurrentTTLs
    $choice = Show-Menu -CurrentTTLs $ttls

    switch ($choice) {
        '1' {
            Clear-Host
            Write-Host "=========================================================="
            Write-Host "        MENGATUR TTL HOP LIMIT KE 65..."
            Write-Host "=========================================================="
            Write-Host ""
            Set-HopLimit -Limit 65 -MessageSuffix " (Bypass Tethering)"
            Write-Host ""
            Write-Host "Kembali ke menu utama..."
            Start-Sleep -Seconds 3
        }
        '2' {
            Clear-Host
            Write-Host "=========================================================="
            Write-Host "        MENGATUR TTL HOP LIMIT KE DEFAULT (128)..."
            Write-Host "=========================================================="
            Write-Host ""
            Set-HopLimit -Limit 128 -MessageSuffix " (Default Windows)"
            Write-Host ""
            Write-Host "Kembali ke menu utama..."
            Start-Sleep -Seconds 3
        }
        '3' {
            Clear-Host
            Write-Host "=========================================================="
            Write-Host "                  KELUAR DARI SKRIP"
            Write-Host "=========================================================="
            Write-Host ""
            Write-Host "Terima kasih telah menggunakan skrip ini, konsol akan ditutup dalam 3 detik."
            Start-Sleep -Seconds 3
            # Menghentikan loop dan keluar dari skrip
            return 
        }
        default {
            Write-Host # Baris baru setelah input yang tidak valid
            Write-Host "Input tidak dikenal ('$($choice)'), kembali ke menu secara otomatis." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true) # Loop akan berjalan terus sampai opsi '3' dipilih

