# TTL Hop Limit Manager - PowerShell Version
# Requires Administrator privileges

# Set console properties
if ($Host.UI.RawUI) {
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 30)
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "Yellow"
    Clear-Host
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Administrator {
    if (-not (Test-Administrator)) {
        Write-Host "==========================================================" -ForegroundColor Yellow
        Write-Host "                MEMERLUKAN HAK ADMINISTRATOR" -ForegroundColor Yellow
        Write-Host "==========================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Skrip ini perlu dijalankan dengan hak administrator" -ForegroundColor White
        Write-Host "  untuk mengubah pengaturan jaringan dan menampilkan" -ForegroundColor White
        Write-Host "  status TTL saat ini dengan benar." -ForegroundColor White
        Write-Host ""
        Write-Host "  Mencoba meminta elevasi otomatis..." -ForegroundColor White
        Write-Host "  Jika dialog UAC muncul, silakan klik 'Yes'." -ForegroundColor White
        Write-Host ""
        Write-Host "==========================================================" -ForegroundColor Yellow
        
        Start-Sleep -Seconds 2
        
        # Restart script with administrator privileges
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
        Start-Process PowerShell -Verb RunAs -ArgumentList $arguments
        exit
    }
    
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "        BERHASIL MENDAPATKAN HAK ADMINISTRATOR" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Skrip berjalan dengan hak administrator" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Get-CurrentTTL {
    $currentTTLIPv4 = "N/A"
    $currentTTLIPv6 = "N/A"
    
    try {
        # Get IPv4 TTL
        $ipv4Output = netsh int ipv4 show global | Where-Object { $_ -match "Default Hop Limit" }
        if ($ipv4Output) {
            $currentTTLIPv4 = ($ipv4Output -split ":")[1].Trim()
        }
        if ([string]::IsNullOrEmpty($currentTTLIPv4)) {
            $currentTTLIPv4 = "Tidak ditemukan"
        }
        
        # Get IPv6 TTL
        $ipv6Output = netsh int ipv6 show global | Where-Object { $_ -match "Default Hop Limit" }
        if ($ipv6Output) {
            $currentTTLIPv6 = ($ipv6Output -split ":")[1].Trim()
        }
        if ([string]::IsNullOrEmpty($currentTTLIPv6)) {
            $currentTTLIPv6 = "Tidak ditemukan"
        }
    }
    catch {
        $currentTTLIPv4 = "Error"
        $currentTTLIPv6 = "Error"
    }
    
    return @{
        IPv4 = $currentTTLIPv4
        IPv6 = $currentTTLIPv6
    }
}

function Show-Menu {
    $ttlInfo = Get-CurrentTTL
    
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "                PENGATURAN TTL HOP LIMIT" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  TTL Hop Limit Saat Ini:" -ForegroundColor White
    Write-Host "    IPv4 : $($ttlInfo.IPv4)" -ForegroundColor Cyan
    Write-Host "    IPv6 : $($ttlInfo.IPv6)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "----------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  Pilih salah satu opsi di bawah ini:" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Set TTL Hop Limit ke 65 (Bypass Tethering)" -ForegroundColor Green
    Write-Host "    [2] Set TTL Hop Limit ke Default Windows (128)" -ForegroundColor Yellow
    Write-Host "    [3] Batal / Keluar" -ForegroundColor Red
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
}

function Set-TTLTo65 {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "         MENGATUR TTL HOP LIMIT KE 65..." -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        netsh int ipv4 set glob defaultcurhoplimit=65
        netsh int ipv6 set glob defaultcurhoplimit=65
        Write-Host ""
        Write-Host "TTL Hop Limit berhasil diatur ke 65 (Bypass Tethering)." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Gagal mengatur TTL ke 65." -ForegroundColor Red
        Write-Host "Detail: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Kembali ke menu utama..." -ForegroundColor White
    Start-Sleep -Seconds 3
}

function Set-TTLToDefault {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "         MENGATUR TTL HOP LIMIT KE DEFAULT (128)..." -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        netsh int ipv4 set glob defaultcurhoplimit=128
        netsh int ipv6 set glob defaultcurhoplimit=128
        Write-Host ""
        Write-Host "TTL Hop Limit berhasil diatur ke 128 (Default Windows)." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Gagal mengatur TTL ke 128." -ForegroundColor Red
        Write-Host "Detail: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Kembali ke menu utama..." -ForegroundColor White
    Start-Sleep -Seconds 3
}

function Exit-Script {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "                   KELUAR DARI SKRIP" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Terima kasih telah menggunakan skrip ini, konsol akan ditutup dalam 3 detik." -ForegroundColor White
    Start-Sleep -Seconds 3
    exit
}

# Main execution
Request-Administrator

# Main menu loop
do {
    Show-Menu
    
    do {
        $choice = Read-Host "Tekan tombol angka untuk memilih opsi (1/2/3)"
    } while ($choice -notmatch '^[123]$')
    
    switch ($choice) {
        '1' { Set-TTLTo65 }
        '2' { Set-TTLToDefault }
        '3' { Exit-Script }
    }
} while ($true)
