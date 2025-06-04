# Windows Script Launcher - Modular Edition
# Author: risunCode
# Versi: 2025-06-04

$Host.UI.RawUI.WindowTitle = "Windows Script Launcher - Modular Edition"
try {
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(92, 3000)
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(92, 30)
} catch {}

function Show-Header {
    Clear-Host
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host "                                 WINDOWS SCRIPT LAUNCHER" -ForegroundColor Yellow
    Write-Host "                                PowerShell Modular Edition" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-BatchTool {
    param (
        [Parameter(Mandatory=$true)][string]$ToolName,
        [Parameter(Mandatory=$true)][string]$DownloadUrl
    )

    $tempPath = Join-Path -Path $env:TEMP -ChildPath $ToolName

    if (-Not (Test-Path $tempPath)) {
        Write-Host "Downloading $ToolName..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempPath -UseBasicParsing
        } catch {
            Write-Host "❌ Gagal mengunduh $ToolName dari $DownloadUrl" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "File $ToolName sudah ada di TEMP, langsung dijalankan..." -ForegroundColor Yellow
    }

    try {
        Write-Host "▶ Menjalankan $ToolName..." -ForegroundColor Green
        Start-Process "cmd.exe" -ArgumentList "/c `"$tempPath`"" -Wait
    } catch {
        Write-Host "❌ Gagal menjalankan $ToolName." -ForegroundColor Red
    } finally {
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
            Write-Host "🧹 File $ToolName dihapus dari TEMP." -ForegroundColor DarkGray
        }
    }
}

function Show-Menu {
    Show-Header
    Write-Host "  Silakan pilih tools yang ingin dijalankan:" -ForegroundColor White
    Write-Host ""
    Write-Host "   [1] Cache Cleaner" -ForegroundColor Yellow
    Write-Host "   [2] Shutdown Timer" -ForegroundColor Yellow
    Write-Host "   [3] Bypass Tethering Throttling" -ForegroundColor Yellow
    Write-Host "   [4] Wi-Fi Backup/Restore Manager" -ForegroundColor Yellow
    Write-Host "   [0] Keluar" -ForegroundColor Gray
    Write-Host ""
}

do {
    Show-Menu
    $choice = Read-Host -Prompt "   Masukkan pilihan (0-4)"

    switch ($choice) {
        "1" {
            Invoke-BatchTool -ToolName "wintrace_cleaner.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/CacheCleaner/wintrace_cleaner.bat"
        }
        "2" {
            Invoke-BatchTool -ToolName "NewShutdown.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/PowerManager/NewShutdown.bat"
        }
        "3" {
            Invoke-BatchTool -ToolName "BypassTethering-Throttling.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/WindowsTTLChanger/BypassTethering-Throttling.bat"
        }
        "4" {
            Invoke-BatchTool -ToolName "WinWifiManager.bat" -DownloadUrl "https://github.com/risunCode/WinPortal/raw/main/winScript/WindowsWifiBackupRestore/WinWifiManager.bat"
        }
        "0" {
            Write-Host "`nKeluar dari launcher. Terima kasih." -ForegroundColor Cyan
        }
        default {
            Write-Host "Pilihan tidak valid. Silakan pilih angka dari 0 sampai 4." -ForegroundColor Red
        }
    }

    if ($choice -ne "0") {
        Write-Host "`nTekan [ENTER] untuk kembali ke menu utama..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
    }

} while ($choice -ne "0")
