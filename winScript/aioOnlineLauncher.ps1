# Windows Script Launcher - PowerShell Edition
# Version 1.0 - Converted for remote execution
# Usage: irm <url-to-this-script> | iex

param(
    [string]$Action = "menu"
)

# Set console properties
$Host.UI.RawUI.WindowTitle = "Windows Script Launcher v1.0 - PowerShell Edition"
if ($Host.UI.RawUI.BufferSize) {
    try {
        $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(92, 3000)
        $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(92, 30)
    } catch {
        # Ignore sizing errors in different PowerShell hosts
    }
}

function Show-Header {
    Clear-Host
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host "                                 WINDOWS SCRIPT LAUNCHER" -ForegroundColor Yellow
    Write-Host "                                    PowerShell Edition" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-MainMenu {
    Show-Header
    Write-Host "   Selamat datang di Windows Script Launcher!" -ForegroundColor Green
    Write-Host "   Pilih tools yang ingin Anda jalankan:" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [1] Cache Cleaner          - Bersihkan file temporary dan cache sistem" -ForegroundColor White
    Write-Host "   [2] Power Manager          - Kelola shutdown, restart, dan power options" -ForegroundColor White
    Write-Host "   [3] System Information     - Tampilkan informasi sistem lengkap" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [4] Network Tools          - Tools jaringan dan konektivitas" -ForegroundColor White
    Write-Host "   [5] Disk Cleanup           - Pembersihan disk otomatis" -ForegroundColor White
    Write-Host "   [6] Keluar                 - Tutup aplikasi" -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-CacheCleaner {
    Show-Header
    Write-Host "                               MENJALANKAN CACHE CLEANER" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Memulai pembersihan cache dan file temporary..." -ForegroundColor Green
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    try {
        # Clear Windows temporary files
        Write-Host "  [1/6] Membersihkan Windows Temp..." -ForegroundColor Yellow
        Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        # Clear Windows prefetch
        Write-Host "  [2/6] Membersihkan Prefetch..." -ForegroundColor Yellow
        Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        
        # Clear browser caches
        Write-Host "  [3/6] Membersihkan Browser Cache..." -ForegroundColor Yellow
        $browserPaths = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache*",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache*",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2"
        )
        foreach ($path in $browserPaths) {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
        
        # Clear recycle bin
        Write-Host "  [4/6] Mengosongkan Recycle Bin..." -ForegroundColor Yellow
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        
        # Clear DNS cache
        Write-Host "  [5/6] Membersihkan DNS Cache..." -ForegroundColor Yellow
        ipconfig /flushdns | Out-Null
        
        # Clear Windows Update cache
        Write-Host "  [6/6] Membersihkan Windows Update Cache..." -ForegroundColor Yellow
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        
        Write-Host ""
        Write-Host "  ✓ Cache Cleaner berhasil dijalankan!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠ Terjadi error saat membersihkan: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "  Tekan Enter untuk kembali ke menu utama..." -ForegroundColor Yellow
    Read-Host
}

function Invoke-PowerManager {
    Show-Header
    Write-Host "                               POWER MANAGER" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Pilih opsi power management:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Shutdown (Matikan komputer)" -ForegroundColor White
    Write-Host "  [2] Restart (Restart komputer)" -ForegroundColor White
    Write-Host "  [3] Sleep (Tidurkan komputer)" -ForegroundColor White
    Write-Host "  [4] Hibernate (Hibernasi)" -ForegroundColor White
    Write-Host "  [5] Log Off (Keluar dari user)" -ForegroundColor White
    Write-Host "  [6] Kembali ke menu utama" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    $choice = Read-Host "Pilih opsi (1-6)"
    
    switch ($choice) {
        "1" { 
            $confirm = Read-Host "Yakin ingin shutdown? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "Shutting down..." -ForegroundColor Red
                Stop-Computer -Force 
            }
        }
        "2" { 
            $confirm = Read-Host "Yakin ingin restart? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "Restarting..." -ForegroundColor Yellow
                Restart-Computer -Force 
            }
        }
        "3" { 
            Write-Host "Entering sleep mode..." -ForegroundColor Blue
            rundll32.exe powrprof.dll,SetSuspendState 0,1,0 
        }
        "4" { 
            Write-Host "Entering hibernate mode..." -ForegroundColor Blue
            rundll32.exe powrprof.dll,SetSuspendState Hibernate 
        }
        "5" { 
            $confirm = Read-Host "Yakin ingin log off? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "Logging off..." -ForegroundColor Yellow
                logoff 
            }
        }
        "6" { return }
        default { Write-Host "Pilihan tidak valid!" -ForegroundColor Red; Start-Sleep 2 }
    }
}

function Show-SystemInfo {
    Show-Header
    Write-Host "                                INFORMASI SISTEM" -ForegroundColor Yellow
    Write-Host ""
    
    # Basic system info
    $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    $bios = Get-WmiObject -Class Win32_BIOS
    
    Write-Host "  Computer Name    : $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "  Username         : $env:USERNAME" -ForegroundColor White
    Write-Host "  OS Name          : $($os.Caption)" -ForegroundColor White
    Write-Host "  OS Version       : $($os.Version)" -ForegroundColor White
    Write-Host "  Architecture     : $($os.OSArchitecture)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "  Hardware Information:" -ForegroundColor Cyan
    Write-Host "    Manufacturer     : $($computer.Manufacturer)" -ForegroundColor White
    Write-Host "    Model            : $($computer.Model)" -ForegroundColor White
    Write-Host "    Total RAM        : $([math]::Round($computer.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor White
    Write-Host "    Processor        : $($computer.SystemFamily)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "  Memory Information:" -ForegroundColor Cyan
    $totalRAM = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    $availRAM = [math]::Round($os.FreePhysicalMemory / 1MB / 1024, 2)
    $usedRAM = [math]::Round($totalRAM - $availRAM, 2)
    Write-Host "    Total RAM        : $totalRAM GB" -ForegroundColor White
    Write-Host "    Used RAM         : $usedRAM GB" -ForegroundColor White
    Write-Host "    Available RAM    : $availRAM GB" -ForegroundColor White
    Write-Host ""
    
    Write-Host "  Storage Information:" -ForegroundColor Cyan
    Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
        $totalGB = [math]::Round($_.Size / 1GB, 2)
        $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
        $usedGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
        $usedPercent = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1)
        Write-Host "    Drive $($_.DeviceID) - Total: $totalGB GB, Used: $usedGB GB ($usedPercent%), Free: $freeGB GB" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  Current Time     : $(Get-Date)" -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Tekan Enter untuk kembali ke menu utama..." -ForegroundColor Yellow
    Read-Host
}

function Invoke-NetworkTools {
    Show-Header
    Write-Host "                                NETWORK TOOLS" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Ping Test" -ForegroundColor White
    Write-Host "  [2] DNS Flush" -ForegroundColor White
    Write-Host "  [3] Network Configuration" -ForegroundColor White
    Write-Host "  [4] Speed Test (Basic)" -ForegroundColor White
    Write-Host "  [5] Kembali ke menu utama" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Pilih opsi (1-5)"
    
    switch ($choice) {
        "1" {
            $target = Read-Host "Masukkan alamat untuk ping (default: google.com)"
            if ([string]::IsNullOrEmpty($target)) { $target = "google.com" }
            Write-Host "Pinging $target..." -ForegroundColor Yellow
            Test-Connection -ComputerName $target -Count 4
        }
        "2" {
            Write-Host "Flushing DNS cache..." -ForegroundColor Yellow
            ipconfig /flushdns
            Write-Host "DNS cache cleared!" -ForegroundColor Green
        }
        "3" {
            Write-Host "Network Configuration:" -ForegroundColor Yellow
            ipconfig /all
        }
        "4" {
            Write-Host "Basic Speed Test (downloading test file)..." -ForegroundColor Yellow
            try {
                $start = Get-Date
                Invoke-WebRequest -Uri "http://speedtest.ftp.otenet.gr/files/test1Mb.db" -OutFile "$env:TEMP\speedtest.tmp" -ErrorAction Stop
                $end = Get-Date
                $duration = ($end - $start).TotalSeconds
                $speed = [math]::Round((1 / $duration), 2)
                Write-Host "Download speed: approximately $speed Mbps" -ForegroundColor Green
                Remove-Item "$env:TEMP\speedtest.tmp" -ErrorAction SilentlyContinue
            }
            catch {
                Write-Host "Speed test failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "5" { return }
        default { Write-Host "Pilihan tidak valid!" -ForegroundColor Red; Start-Sleep 2 }
    }
    
    Write-Host ""
    Write-Host "Tekan Enter untuk kembali..." -ForegroundColor Yellow
    Read-Host
}

function Invoke-DiskCleanup {
    Show-Header
    Write-Host "                                DISK CLEANUP" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Menjalankan pembersihan disk otomatis..." -ForegroundColor Green
    Write-Host ""
    
    try {
        # Run Windows built-in disk cleanup
        Write-Host "  [1/3] Menjalankan Disk Cleanup..." -ForegroundColor Yellow
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden
        
        # Clear additional temp locations
        Write-Host "  [2/3] Membersihkan lokasi temp tambahan..." -ForegroundColor Yellow
        $tempPaths = @(
            "$env:LOCALAPPDATA\Temp",
            "$env:SystemRoot\Temp",
            "$env:TEMP"
        )
        
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        
        # Analyze disk space
        Write-Host "  [3/3] Menganalisis ruang disk..." -ForegroundColor Yellow
        Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
            $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
            $totalGB = [math]::Round($_.Size / 1GB, 2)
            $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
            Write-Host "    Drive $($_.DeviceID) - Free: $freeGB GB ($freePercent% of $totalGB GB)" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "  ✓ Disk cleanup berhasil!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠ Error during disk cleanup: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "  Tekan Enter untuk kembali ke menu utama..." -ForegroundColor Yellow
    Read-Host
}

# Main execution logic
if ($Action -eq "menu") {
    do {
        Show-MainMenu
        $choice = Read-Host "Pilih opsi (1-6)"
        
        switch ($choice) {
            "1" { Invoke-CacheCleaner }
            "2" { Invoke-PowerManager }
            "3" { Show-SystemInfo }
            "4" { Invoke-NetworkTools }
            "5" { Invoke-DiskCleanup }
            "6" { 
                Clear-Host
                Write-Host "=====================================================================================" -ForegroundColor Cyan
                Write-Host "                                   KELUAR APLIKASI" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  Terima kasih telah menggunakan Windows Script Launcher!" -ForegroundColor Green
                Write-Host ""
                Write-Host "  PowerShell Edition - Converted for remote execution" -ForegroundColor White
                Write-Host ""
                Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Aplikasi akan ditutup dalam 3 detik..." -ForegroundColor Yellow
                Start-Sleep 3
                exit 
            }
            default { 
                Write-Host "Pilihan tidak valid! Silakan pilih 1-6." -ForegroundColor Red
                Start-Sleep 2
            }
        }
    } while ($true)
}

# Allow direct function calls via parameters
switch ($Action.ToLower()) {
    "cache" { Invoke-CacheCleaner }
    "power" { Invoke-PowerManager }
    "sysinfo" { Show-SystemInfo }
    "network" { Invoke-NetworkTools }
    "disk" { Invoke-DiskCleanup }
    default { 
        if ($Action -ne "menu") {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Available actions: menu, cache, power, sysinfo, network, disk" -ForegroundColor Yellow
        }
    }
}