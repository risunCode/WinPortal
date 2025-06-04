# Windows Script Launcher - Clean Edition
# Author: risunCode
# Versi: 2025-06-04 Clean

$Host.UI.RawUI.WindowTitle = "Windows Script Launcher - Clean Edition"
try {
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 3000)
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 35)
} catch {}

function Get-WelcomeMessage {
    $username = $env:USERNAME
    $computerName = $env:COMPUTERNAME
    $currentDate = Get-Date -Format "dddd, dd MMMM yyyy"
    $currentTime = Get-Date -Format "HH:mm:ss"
    
    # Greeting based on time
    $hour = (Get-Date).Hour
    $greeting = switch ($hour) {
        {$_ -ge 5 -and $_ -lt 12} { "Selamat Pagi" }
        {$_ -ge 12 -and $_ -lt 15} { "Selamat Siang" }
        {$_ -ge 15 -and $_ -lt 18} { "Selamat Sore" }
        default { "Selamat Malam" }
    }
    
    return @{
        Username = $username
        ComputerName = $computerName
        Date = $currentDate
        Time = $currentTime
        Greeting = $greeting
    }
}

function Show-Header {
    Clear-Host
    $welcome = Get-WelcomeMessage
    
    Write-Host "═════════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                              🚀 WINDOWS SCRIPT LAUNCHER 🚀" -ForegroundColor Yellow
    Write-Host "                                 PowerShell Clean Edition" -ForegroundColor Yellow
    Write-Host "═════════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Welcome message with system info
    Write-Host "  💻 " -NoNewline -ForegroundColor Blue
    Write-Host "$($welcome.Greeting), " -NoNewline -ForegroundColor Green
    Write-Host "$($welcome.Username)" -NoNewline -ForegroundColor Yellow
    Write-Host "!" -ForegroundColor Green
    Write-Host "  🏠 Computer: " -NoNewline -ForegroundColor Blue
    Write-Host "$($welcome.ComputerName)" -ForegroundColor Cyan
    Write-Host "  📅 " -NoNewline -ForegroundColor Blue  
    Write-Host "$($welcome.Date)" -ForegroundColor White
    Write-Host "  🕐 " -NoNewline -ForegroundColor Blue
    Write-Host "$($welcome.Time)" -ForegroundColor White
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Host ""
}

function Invoke-CacheCleaner {
    param (
        [Parameter(Mandatory=$true)][string]$ToolName,
        [Parameter(Mandatory=$true)][string]$DownloadUrl,
        [Parameter(Mandatory=$true)][string]$DisplayName
    )

    Write-Host ""
    Write-Host "🔧 Memulai $DisplayName..." -ForegroundColor Magenta
    Write-Host "─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    # Gunakan folder Downloads user untuk Cache Cleaner
    $downloadsPath = [Environment]::GetFolderPath("UserProfile") + "\Documents"
    $toolPath = Join-Path -Path $downloadsPath -ChildPath $ToolName

    if (-Not (Test-Path $toolPath)) {
        Write-Host "📥 Mengunduh $DisplayName ke folder Documents..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $toolPath -UseBasicParsing
            Write-Host "✅ Download berhasil disimpan di: $toolPath" -ForegroundColor Green
        } catch {
            Write-Host "❌ Gagal mengunduh $DisplayName dari $DownloadUrl" -ForegroundColor Red
            Write-Host "🔍 Periksa koneksi internet Anda" -ForegroundColor Yellow
            return
        }
    } else {
        Write-Host "📁 File $DisplayName sudah tersedia di Documents..." -ForegroundColor Yellow
        Write-Host "📍 Lokasi: $toolPath" -ForegroundColor DarkGray
    }

    try {
        Write-Host "▶️  Menjalankan $DisplayName..." -ForegroundColor Green
        Start-Process "cmd.exe" -ArgumentList "/c `"$toolPath`"" -Wait
        Write-Host "✅ $DisplayName selesai dijalankan!" -ForegroundColor Green
        Write-Host "💾 File disimpan permanen di folder Downloads untuk penggunaan selanjutnya" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Gagal menjalankan $DisplayName." -ForegroundColor Red
        Write-Host "🔧 Coba jalankan sebagai Administrator" -ForegroundColor Yellow
    }
}

function Invoke-BatchTool {
    param (
        [Parameter(Mandatory=$true)][string]$ToolName,
        [Parameter(Mandatory=$true)][string]$DownloadUrl,
        [Parameter(Mandatory=$true)][string]$DisplayName
    )

    Write-Host ""
    Write-Host "🔧 Memulai $DisplayName..." -ForegroundColor Magenta
    Write-Host "─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    $tempPath = Join-Path -Path $env:TEMP -ChildPath $ToolName

    if (-Not (Test-Path $tempPath)) {
        Write-Host "📥 Mengunduh $DisplayName..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempPath -UseBasicParsing
            Write-Host "✅ Download berhasil!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Gagal mengunduh $DisplayName dari $DownloadUrl" -ForegroundColor Red
            Write-Host "🔍 Periksa koneksi internet Anda" -ForegroundColor Yellow
            return
        }
    } else {
        Write-Host "📁 File $DisplayName sudah tersedia di cache..." -ForegroundColor Yellow
    }

    try {
        Write-Host "▶️  Menjalankan $DisplayName..." -ForegroundColor Green
        Start-Process "cmd.exe" -ArgumentList "/c `"$tempPath`"" -Wait
        Write-Host "✅ $DisplayName selesai dijalankan!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Gagal menjalankan $DisplayName." -ForegroundColor Red
        Write-Host "🔧 Coba jalankan sebagai Administrator" -ForegroundColor Yellow
    } finally {
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
            Write-Host "🧹 File cache dibersihkan." -ForegroundColor DarkGray
        }
    }
}

function Show-Menu {
    Show-Header
    Write-Host "  🎯 Pilih tools yang ingin dijalankan:" -ForegroundColor White
    Write-Host ""
    Write-Host "   🧽 [1] Cache Cleaner" -ForegroundColor Yellow
    Write-Host "       └─ Membersihkan file temporary dan cache sistem" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   ⏰ [2] Shutdown Timer" -ForegroundColor Yellow  
    Write-Host "       └─ Mengatur jadwal shutdown otomatis" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   🌐 [3] Bypass Tethering Throttling" -ForegroundColor Yellow
    Write-Host "       └─ Mengoptimalkan koneksi hotspot mobile" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   📶 [4] Wi-Fi Backup/Restore Manager" -ForegroundColor Yellow
    Write-Host "       └─ Backup dan restore profil Wi-Fi" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   🚪 [0] Keluar" -ForegroundColor Red
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
}

function Show-ExitMessage {
    Write-Host ""
    Write-Host "═════════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "                                    👋 Terima Kasih!" -ForegroundColor Green
    Write-Host "                              Sampai jumpa di lain waktu!" -ForegroundColor Yellow
    Write-Host "═════════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Start-Sleep -Seconds 2
}

do {
    Show-Menu
    $choice = Read-Host -Prompt "   💡 Masukkan pilihan (0-4)"

    switch ($choice) {
        "1" {
            Invoke-CacheCleaner -ToolName "wintrace_cleaner.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/CacheCleaner/wintrace_cleaner.bat" -DisplayName "Cache Cleaner"
        }
        "2" {
            Invoke-BatchTool -ToolName "NewShutdown.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/PowerManager/NewShutdown.bat" -DisplayName "Advanced Power menu with Timer and Logging"
        }
        "3" {
            Invoke-BatchTool -ToolName "BypassTethering-Throttling.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/WindowsTTLChanger/BypassTethering-Throttling.bat" -DisplayName "Bypass Tethering Throttling"
        }
        "4" {
            Invoke-BatchTool -ToolName "WinWifiManager.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/WindowsWifiBackupRestore/WinWifiManager.bat" -DisplayName "Wi-Fi Manager Backup and Restore"
        }
        "0" {
            Show-ExitMessage
        }
        default {
            Write-Host ""
            Write-Host "❌ Pilihan tidak valid!" -ForegroundColor Red
            Write-Host "💡 Silakan pilih angka dari 0 sampai 4." -ForegroundColor Yellow
        }
    }

    if ($choice -ne "0") {
        Write-Host ""
        Write-Host "─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
        Write-Host "🔙 Tekan [ENTER] untuk kembali ke menu utama..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
    }

} while ($choice -ne "0")
