# Shutdown Manager - PowerShell Version
# Can be run online with: irm your-link-here | iex
# by: github/risunCode

# Set console window properties
try {
    $host.UI.RawUI.WindowTitle = "Shutdown Manager oleh risunCode"
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(70, 12)
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(70, 12)
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Yellow"
    Clear-Host
} catch {
    # Ignore if can't resize (some terminals don't support it)
}

# Log file setup
$logFile = "$env:USERPROFILE\Desktop\Shutdown-$env:USERNAME.txt"

function Write-Header {
    param([string]$Title = "SHUTDOWN MANAGER")
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "                          $Title" -ForegroundColor Yellow
    Write-Host "                         by: github/risunCode" -ForegroundColor Green  
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Countdown {
    param(
        [string]$Message,
        [string]$Action,
        [int]$Seconds = 4
    )
    
    for ($i = $Seconds; $i -ge 1; $i--) {
        Clear-Host
        Write-Host "===================================================================" -ForegroundColor Cyan
        Write-Host "Pilihan User : $Action" -ForegroundColor Yellow
        Write-Host "===================================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "$Message" -ForegroundColor White
        Write-Host ""
        Write-Host "Countdown : $i detik" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}

function Write-Log {
    param([string]$Action)
    $datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$Action pada tanggal $datetime" -Encoding UTF8
}

function Get-UserChoice {
    param(
        [string]$Prompt,
        [string[]]$ValidChoices,
        [int]$TimeoutSeconds = 0
    )
    
    do {
        if ($TimeoutSeconds -gt 0) {
            Write-Host "$Prompt (Timeout: $TimeoutSeconds detik, default: N)" -ForegroundColor Yellow
            $choice = Read-Host
            if ([string]::IsNullOrEmpty($choice)) {
                return 'N'
            }
        } else {
            $choice = Read-Host $Prompt
        }
        $choice = $choice.ToUpper()
    } while ($choice -notin $ValidChoices)
    
    return $choice
}

# Main execution starts here
Write-Header
Write-Host "Apakah Anda yakin ingin melanjutkan? (Y/N)" -ForegroundColor White
$confirm = Get-UserChoice -Prompt "Pilihan" -ValidChoices @('Y', 'N') -TimeoutSeconds 20

if ($confirm -eq 'N') {
    Write-Header "OPERASI DIBATALKAN"
    Write-Host "Operasi dibatalkan. Menunggu 3 detik sebelum menutup..." -ForegroundColor Yellow
    Show-Countdown -Message "Operasi dibatalkan" -Action "Operasi Dibatalkan" -Seconds 3
    exit
}

# Main menu
do {
    Write-Header
    Write-Host "Pilih opsi yang diinginkan:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Shutdown Paksa (shutdown /s /f /t 0)" -ForegroundColor White
    Write-Host "2. Shutdown Normal (shutdown /s)" -ForegroundColor White  
    Write-Host "3. Boot ke Menu UEFI (shutdown /r /fw /t 0)" -ForegroundColor White
    Write-Host "4. Sleep Mode (standby)" -ForegroundColor White
    Write-Host "5. Hibernate" -ForegroundColor White
    Write-Host "6. Reboot System (restart normal)" -ForegroundColor White
    Write-Host "7. Soft Reboot (restart dengan opsi /soft)" -ForegroundColor White
    Write-Host "8. Custom Command (cmd kustom)" -ForegroundColor White
    Write-Host "9. Kembali (batalkan operasi)" -ForegroundColor White
    Write-Host ""
    
    $choice = Get-UserChoice -Prompt "Pilih nomor (1-9)" -ValidChoices @('1','2','3','4','5','6','7','8','9')
    
    switch ($choice) {
        '1' {
            Show-Countdown -Message "Komputer akan dimatikan secara paksa dalam 6 detik..." -Action "Shutdown Paksa, Pastikan semua app sudah close!"
            Write-Log "Shutdown paksa"
            shutdown /s /f /t 0
            exit
        }
        
        '2' {
            Show-Countdown -Message "Komputer akan dimatikan secara normal dalam 6 detik..." -Action "Shutdown Normal, Pastikan semua app sudah close!"
            Write-Log "Shutdown normal"
            shutdown /s /t 0
            exit
        }
        
        '3' {
            Show-Countdown -Message "Boot ke menu UEFI dalam 6 detik..." -Action "Boot ke Menu UEFI"
            Write-Log "Boot ke UEFI"
            shutdown /r /fw /t 0
            exit
        }
        
        '4' {
            Show-Countdown -Message "Komputer akan masuk mode Sleep dalam 6 detik..." -Action "Sleep Mode (Standby)"
            Write-Log "Sleep mode"
            try {
                # Disable hibernate first, then sleep
                powercfg -hibernate off 2>$null
                Add-Type -TypeDefinition @"
                    using System;
                    using System.Runtime.InteropServices;
                    public class PowerManager {
                        [DllImport("powrprof.dll", SetLastError = true)]
                        public static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);
                    }
"@
                [PowerManager]::SetSuspendState($false, $true, $false)
            } catch {
                # Fallback method
                rundll32.exe powrprof.dll,SetSuspendState 0,1,0
            }
            exit
        }
        
        '5' {
            Show-Countdown -Message "Komputer akan masuk mode Hibernate dalam 6 detik..." -Action "Hibernate Mode"
            Write-Log "Hibernate mode"
            try {
                powercfg -hibernate on 2>$null
                shutdown /h
            } catch {
                # Fallback method
                rundll32.exe powrprof.dll,SetSuspendState Hibernate
            }
            exit
        }
        
        '6' {
            Show-Countdown -Message "Komputer akan di-restart dalam 6 detik..." -Action "Reboot System"
            Write-Log "Reboot system"
            shutdown /r /t 0
            exit
        }
        
        '7' {
            Show-Countdown -Message "Komputer akan di-soft reboot dalam 6 detik..." -Action "Soft Reboot"
            Write-Log "Soft reboot"
            shutdown /r /soft /t 0
            exit
        }
        
        '8' {
            Write-Header "CUSTOM COMMAND EXECUTION"
            Write-Host "Masukkan command shutdown kustom yang ingin dijalankan:" -ForegroundColor White
            Write-Host "(contoh: /r /o /t 0 untuk restart ke advanced options)" -ForegroundColor Gray
            Write-Host ""
            
            $customCmd = Read-Host "Command: shutdown "
            
            Write-Header "KONFIRMASI CUSTOM COMMAND"
            Write-Host "Command yang akan dijalankan: shutdown $customCmd" -ForegroundColor Yellow
            Write-Host ""
            
            $confirmCustom = Get-UserChoice -Prompt "Apakah Anda yakin ingin menjalankan command ini? (Y/N)" -ValidChoices @('Y', 'N')
            
            if ($confirmCustom -eq 'Y') {
                Write-Log "Command kustom: shutdown $customCmd"
                try {
                    Start-Process "shutdown" -ArgumentList $customCmd.Split(' ') -NoNewWindow -Wait
                } catch {
                    Write-Host "Error executing command: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 3
                }
                exit
            }
        }
        
        '9' {
            Write-Header "OPERASI DIBATALKAN"
            Show-Countdown -Message "Operasi dibatalkan. Menunggu 3 detik sebelum menutup..." -Action "Operasi Dibatalkan" -Seconds 3
            exit
        }
    }
} while ($true)

# This should never be reached, but just in case
Write-Host "Script completed." -ForegroundColor Green