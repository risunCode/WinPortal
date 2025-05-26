# PowerShell Script untuk Mengatur TTL Hop Limit
# Converted from Batch to PowerShell

# Set console properties
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 30)
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Yellow"
Clear-Host

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminPrivileges {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "                MEMERLUKAN HAK ADMINISTRATOR" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Script ini perlu dijalankan dengan hak administrator" -ForegroundColor White
    Write-Host "  untuk mengubah pengaturan jaringan dan menampilkan" -ForegroundColor White
    Write-Host "  status TTL saat ini dengan benar." -ForegroundColor White
    Write-Host ""
    Write-Host "  Mencoba meminta elevasi otomatis..." -ForegroundColor White
    Write-Host "  Jika dialog UAC muncul, silakan klik 'Yes'." -ForegroundColor White
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Yellow
    
    Start-Sleep -Seconds 1
    
    # Start PowerShell as Administrator
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.ScriptName)`""
    Start-Process PowerShell -Verb RunAs -ArgumentList $arguments
    exit
}

function Get-CurrentTTL {
    $currentTTL_IPv4 = "N/A"
    $currentTTL_IPv6 = "N/A"
    
    try {
        # Get Current IPv4 TTL
        $ipv4Output = netsh int ipv4 show global | Select-String "Default Hop Limit"
        if ($ipv4Output) {
            $ttlMatch = $ipv4Output -match ":\s*(\d+)"
            if ($matches) {
                $currentTTL_IPv4 = $matches[1]
            }
        }
        
        # Get Current IPv6 TTL
        $ipv6Output = netsh int ipv6 show global | Select-String "Default Hop Limit"
        if ($ipv6Output) {
            $ttlMatch = $ipv6Output -match ":\s*(\d+)"
            if ($matches) {
                $currentTTL_IPv6 = $matches[1]
            }
        }
    }
    catch {
        $currentTTL_IPv4 = "Tidak ditemukan"
        $currentTTL_IPv6 = "Tidak ditemukan"
    }
    
    if ($currentTTL_IPv4 -eq "N/A") { $currentTTL_IPv4 = "Tidak ditemukan" }
    if ($currentTTL_IPv6 -eq "N/A") { $currentTTL_IPv6 = "Tidak ditemukan" }
    
    return @{
        IPv4 = $currentTTL_IPv4
        IPv6 = $currentTTL_IPv6
    }
}

function Show-Menu {
    Clear-Host
    $ttlInfo = Get-CurrentTTL
    
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "                PENGATURAN TTL HOP LIMIT" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  NOTE: saat windows di reboot, Settingan TTL akan otomatis menjadi default" -ForegroundColor Cyan
    Write-Host "  TTL Hop Limit Saat Ini:" -ForegroundColor White
    Write-Host "    IPv4 : $($ttlInfo.IPv4)" -ForegroundColor Green
    Write-Host "    IPv6 : $($ttlInfo.IPv6)" -ForegroundColor Green
    Write-Host ""
    Write-Host "----------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Pilih salah satu opsi di bawah ini:" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Set TTL Hop Limit ke 65 (Bypass Tethering)" -ForegroundColor White
    Write-Host "    [2] Set TTL Hop Limit ke Default Windows (128)" -ForegroundColor White
    Write-Host "    [3] Batal / Keluar" -ForegroundColor White
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
        Write-Host "Error: Gagal mengatur TTL. $_" -ForegroundColor Red
    }
    
    Write-Host "Kembali ke menu utama..." -ForegroundColor Cyan
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
        Write-Host "Error: Gagal mengatur TTL. $_" -ForegroundColor Red
    }
    
    Write-Host "Kembali ke menu utama..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
}

function Exit-Script {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "                   KELUAR DARI SCRIPT" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Terima kasih telah menggunakan script ini, konsol akan ditutup dalam 3 detik." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    exit
}

# Main execution
if (-not (Test-AdminPrivileges)) {
    Request-AdminPrivileges
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "        BERHASIL MENDAPATKAN HAK ADMINISTRATOR" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Script berjalan dengan hak administrator" -ForegroundColor Green
Start-Sleep -Seconds 1

# Main menu loop
do {
    Show-Menu
    
    do {
        $choice = Read-Host "Tekan tombol angka untuk memilih opsi (1-3)"
    } while ($choice -notmatch '^[1-3]$')
    
    switch ($choice) {
        "1" { Set-TTLTo65 }
        "2" { Set-TTLToDefault }
        "3" { Exit-Script }
    }
} while ($true)