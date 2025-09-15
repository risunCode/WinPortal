# risunCode at 25/07/25.

# Fallback untuk memastikan ukuran font dan window tetap konsisten
try {
    # Simpan ukuran font saat ini
    $currentFont = $Host.UI.RawUI.Font
    
    # Jika font terlalu kecil, atur ke ukuran yang lebih besar
    if ($currentFont.Size -lt 16) {
        $newFont = $Host.UI.RawUI.Font
        $newFont.Size = 16
        $Host.UI.RawUI.Font = $newFont
    }
} catch {
    # Abaikan error jika tidak bisa mengatur font
    # Beberapa versi PowerShell tidak mendukung pengaturan font
}
   
function Stop-WindowsUpdateService {
    Write-Host "Mencoba menghentikan layanan Windows Update..." -ForegroundColor Yellow
    try {
        # Hentikan layanan Windows Update (wuauserv)
        Stop-Service -Name "wuauserv" -Force -ErrorAction Stop
        Write-Host "Layanan Windows Update berhasil dihentikan." -ForegroundColor Green
    }
    catch {
        Write-Host "Gagal menghentikan layanan Windows Update. Mungkin sudah berhenti atau ada masalah izin." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    Write-Host ""
}

# --- MAIN SCRIPT ---

# Pastikan script dijalankan sebagai Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script ini harus dijalankan sebagai Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Bersihkan layar untuk tampilan yang lebih baik
Clear-Host

# Tampilkan header dengan warna yang lebih baik
Write-Host ""
Write-Host "Stops Windows Updates | Apps Updates" -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "---------------------------------------------------------------------------------------------------------------------" -ForegroundColor White
Write-Host "[1] | Pause Windows Update until 2050 (Default)" -ForegroundColor Cyan
Write-Host "[2] | Pause Windows Update until a Custom Year" -ForegroundColor Cyan
Write-Host "[3] | Warning! (Pause windows update first!)" -ForegroundColor Cyan
Write-Host "[0] | Back to menu / Exit" -ForegroundColor Cyan
Write-Host "=====================================================================================================================" -ForegroundColor White

$op = Read-Host "Ketik pilihan Anda"

switch ($op) {
    "1" {
        Stop-WindowsUpdateService # Hentikan layanan dulu
        Write-Host "Pausing Windows Updates until 2050..." -ForegroundColor Yellow

        $registryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
        $expiryDate = Get-Date -Year 2050 -Month 1 -Day 1 -Hour 10 -Minute 38 -Second 56
        $expiryTime = $expiryDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

        try {
            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
            }
            Set-ItemProperty -Path $registryPath -Name "PauseUpdatesExpiryTime" -Value $expiryTime -Force
            Set-ItemProperty -Path $registryPath -Name "PauseFeatureUpdatesEndTime" -Value $expiryTime -Force
            Set-ItemProperty -Path $registryPath -Name "PauseQualityUpdatesEndTime" -Value $expiryTime -Force # Sesuaikan tahun untuk Quality Updates juga
            Write-Host "Windows Updates berhasil ditunda hingga 2050!" -ForegroundColor Green
        }
        catch {
            Write-Host "Gagal menunda Windows Updates. Pastikan Anda menjalankan sebagai Administrator." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
        Start-Sleep -Seconds 2
    }
    "2" {
        $customYear = Read-Host "Masukkan tahun (YYYY) untuk menunda update"
        if ($customYear -as [int] -and ([int]$customYear -ge (Get-Date).Year)) { # Validasi tahun harus berupa angka dan di masa depan
            Stop-WindowsUpdateService # Hentikan layanan dulu
            Write-Host "Pausing Windows Updates until $customYear..." -ForegroundColor Yellow

            $registryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
            $expiryDate = Get-Date -Year ([int]$customYear) -Month 1 -Day 1 -Hour 10 -Minute 38 -Second 56
            $expiryTime = $expiryDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

            try {
                if (-not (Test-Path $registryPath)) {
                    New-Item -Path $registryPath -Force | Out-Null
                }
                Set-ItemProperty -Path $registryPath -Name "PauseUpdatesExpiryTime" -Value $expiryTime -Force
                Set-ItemProperty -Path $registryPath -Name "PauseFeatureUpdatesEndTime" -Value $expiryTime -Force
                Set-ItemProperty -Path $registryPath -Name "PauseQualityUpdatesEndTime" -Value $expiryTime -Force
                Write-Host "Windows Updates berhasil ditunda hingga $customYear!" -ForegroundColor Green
            }
            catch {
                Write-Host "Gagal menunda Windows Updates. Pastikan Anda menjalankan sebagai Administrator." -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        } else {
            Write-Host "Input tahun tidak valid. Harap masukkan angka tahun di masa depan (misal: 2040)." -ForegroundColor Red
        }
        Start-Sleep -Seconds 2
    }
    "0" {
        Write-Host "Kembali ke menu utama..." -ForegroundColor White
        Start-Sleep -Seconds 1
    }
    Default {
        Write-Host "Pilihan tidak valid. Kembali ke menu utama..." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

# Akhiri script dengan bersih
Write-Host ""
Write-Host "Tekan tombol apa saja untuk kembali ke menu utama..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host