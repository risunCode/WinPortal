# Windows Script Launcher - PowerShell Edition
# Version 1.2 - Enhanced with simplified speed test
# Usage: irm <url-to-this-script> | iex

param(
    [string]$Action = "menu"
)

# Set console properties
$Host.UI.RawUI.WindowTitle = "Windows Script Launcher v1.2 - PowerShell Edition"
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
    Write-Host "   Script Last update: 2 June 2025 at 14pm" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [1] System Cleaner         - Bersihkan file temporary dan cache sistem" -ForegroundColor White
    Write-Host "   [2] Recycle Bin Manager    - Kelola dan kosongkan recycle bin" -ForegroundColor White
    Write-Host "   [3] Power Manager          - Kelola shutdown, restart, dan power options" -ForegroundColor White
    Write-Host "   [4] System Information     - Tampilkan informasi sistem lengkap" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [5] Network Tools          - Tools jaringan dan konektivitas" -ForegroundColor White
    Write-Host "   [6] Disk Cleanup           - Pembersihan disk otomatis" -ForegroundColor White
    Write-Host "   [7] Keluar                 - Tutup aplikasi" -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-SystemCleaner {
    Show-Header
    Write-Host "                               SYSTEM CLEANER" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ⚠️  PERINGATAN: Ini akan menghapus file temporary dan cache sistem!" -ForegroundColor Red
    Write-Host "  File yang akan dihapus:" -ForegroundColor Yellow
    Write-Host "    • Windows Temp files" -ForegroundColor White
    Write-Host "    • Prefetch files" -ForegroundColor White
    Write-Host "    • Browser cache (Chrome, Edge, Firefox)" -ForegroundColor White
    Write-Host "    • DNS cache" -ForegroundColor White
    Write-Host "    • Windows Update cache" -ForegroundColor White
    Write-Host ""
    Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    $confirm = Read-Host "Yakin ingin melanjutkan pembersihan sistem? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "  Pembersihan dibatalkan." -ForegroundColor Yellow
        Start-Sleep 2
        return
    }
    
    Write-Host ""
    Write-Host "  Memulai pembersihan sistem..." -ForegroundColor Green
    Write-Host ""
    
    try {
        # Clear Windows temporary files
        Write-Host "  [1/5] Membersihkan Windows Temp..." -ForegroundColor Yellow
        $tempDeleted = 0
        Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
                $tempDeleted++
            } catch {}
        }
        Write-Host "    ✓ $tempDeleted file(s) dihapus dari Windows Temp" -ForegroundColor Green
        
        # Clear Windows prefetch
        Write-Host "  [2/5] Membersihkan Prefetch..." -ForegroundColor Yellow
        $prefetchCount = (Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue).Count
        Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "    ✓ $prefetchCount prefetch file(s) dihapus" -ForegroundColor Green
        
        # Clear browser caches
        Write-Host "  [3/5] Membersihkan Browser Cache..." -ForegroundColor Yellow
        $browserPaths = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache*",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache*",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2"
        )
        $browserCleaned = 0
        foreach ($path in $browserPaths) {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
                    $browserCleaned++
                } catch {}
            }
        }
        Write-Host "    ✓ $browserCleaned browser cache file(s) dihapus" -ForegroundColor Green
        
        # Clear DNS cache
        Write-Host "  [4/5] Membersihkan DNS Cache..." -ForegroundColor Yellow
        ipconfig /flushdns | Out-Null
        Write-Host "    ✓ DNS cache berhasil dibersihkan" -ForegroundColor Green
        
        # Clear Windows Update cache
        Write-Host "  [5/5] Membersihkan Windows Update Cache..." -ForegroundColor Yellow
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        $wuCacheCount = (Get-ChildItem -Path "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue).Count
        Get-ChildItem -Path "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Host "    ✓ $wuCacheCount Windows Update cache file(s) dihapus" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "  🎉 System Cleaner berhasil dijalankan!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠ Terjadi error saat membersihkan: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "  Tekan Enter untuk kembali ke menu utama..." -ForegroundColor Yellow
    Read-Host
}

function Invoke-RecycleBinManager {
    Show-Header
    Write-Host "                              RECYCLE BIN MANAGER" -ForegroundColor Yellow
    Write-Host "=====================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check recycle bin status
    try {
        $recycleBin = Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -Recurse -ErrorAction SilentlyContinue
        $itemCount = $recycleBin.Count
        $totalSize = ($recycleBin | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($totalSize / 1GB, 2)
        $sizeMB = [math]::Round($totalSize / 1MB, 2)
        
        Write-Host "  Status Recycle Bin:" -ForegroundColor Cyan
        Write-Host "    📁 Jumlah item: $itemCount" -ForegroundColor White
        if ($sizeGB -gt 0) {
            Write-Host "    💾 Ukuran total: $sizeGB GB ($sizeMB MB)" -ForegroundColor White
        } else {
            Write-Host "    💾 Ukuran total: $sizeMB MB" -ForegroundColor White
        }
        Write-Host ""
        
        if ($itemCount -eq 0) {
            Write-Host "  ✅ Recycle Bin sudah kosong!" -ForegroundColor Green
        } else {
            Write-Host "  Pilih aksi:" -ForegroundColor White
            Write-Host "    [1] Kosongkan Recycle Bin" -ForegroundColor White
            Write-Host "    [2] Lihat isi Recycle Bin" -ForegroundColor White
            Write-Host "    [3] Kembali ke menu utama" -ForegroundColor White
            Write-Host ""
            
            $choice = Read-Host "Pilih opsi (1-3)"
            
            switch ($choice) {
                "1" {
                    Write-Host ""
                    Write-Host "  ⚠️  PERINGATAN: Ini akan menghapus SEMUA file di Recycle Bin!" -ForegroundColor Red
                    Write-Host "  File yang dihapus TIDAK DAPAT dipulihkan!" -ForegroundColor Red
                    Write-Host ""
                    $confirm = Read-Host "Yakin ingin mengosongkan Recycle Bin? (y/n)"
                    
                    if ($confirm -eq "y") {
                        Write-Host "  Mengosongkan Recycle Bin..." -ForegroundColor Yellow
                        try {
                            Clear-RecycleBin -Force -ErrorAction Stop
                            Write-Host "  🎉 Recycle Bin berhasil dikosongkan!" -ForegroundColor Green
                            Write-Host "  💾 Berhasil menghemat $sizeMB MB ruang disk" -ForegroundColor Green
                        }
                        catch {
                            Write-Host "  ⚠ Error: $($_.Exception.Message)" -ForegroundColor Red
                        }
                    } else {
                        Write-Host "  Pengosongan Recycle Bin dibatalkan." -ForegroundColor Yellow
                    }
                }
                "2" {
                    Write-Host ""
                    Write-Host "  Isi Recycle Bin (10 item teratas):" -ForegroundColor Cyan
                    $recycleBin | Select-Object -First 10 | ForEach-Object {
                        $size = [math]::Round($_.Length / 1MB, 2)
                        Write-Host "    📄 $($_.Name) - $size MB" -ForegroundColor White
                    }
                    if ($itemCount -gt 10) {
                        Write-Host "    ... dan $($itemCount - 10) item lainnya" -ForegroundColor Gray
                    }
                }
                "3" { return }
                default { 
                    Write-Host "  Pilihan tidak valid!" -ForegroundColor Red
                    Start-Sleep 2
                }
            }
        }
    }
    catch {
        Write-Host "  ⚠ Error mengakses Recycle Bin: $($_.Exception.Message)" -ForegroundColor Red
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
            Write-Host ""
            Write-Host "  ⚠️  PERINGATAN: Komputer akan dimatikan!" -ForegroundColor Red
            $confirm = Read-Host "Yakin ingin shutdown? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "  Shutting down dalam 5 detik..." -ForegroundColor Red
                Start-Sleep 2
                Stop-Computer -Force 
            } else {
                Write-Host "  Shutdown dibatalkan." -ForegroundColor Yellow
            }
        }
        "2" { 
            Write-Host ""
            Write-Host "  ⚠️  PERINGATAN: Komputer akan direstart!" -ForegroundColor Red
            $confirm = Read-Host "Yakin ingin restart? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "  Restarting dalam 5 detik..." -ForegroundColor Yellow
                Start-Sleep 2
                Restart-Computer -Force 
            } else {
                Write-Host "  Restart dibatalkan." -ForegroundColor Yellow
            }
        }
        "3" { 
            Write-Host "  Entering sleep mode..." -ForegroundColor Blue
            rundll32.exe powrprof.dll,SetSuspendState 0,1,0 
        }
        "4" { 
            Write-Host "  Entering hibernate mode..." -ForegroundColor Blue
            rundll32.exe powrprof.dll,SetSuspendState Hibernate 
        }
        "5" { 
            Write-Host ""
            Write-Host "  ⚠️  PERINGATAN: Anda akan logout dari user saat ini!" -ForegroundColor Red
            $confirm = Read-Host "Yakin ingin log off? (y/n)"
            if ($confirm -eq "y") { 
                Write-Host "  Logging off..." -ForegroundColor Yellow
                logoff 
            } else {
                Write-Host "  Log off dibatalkan." -ForegroundColor Yellow
            }
        }
        "6" { return }
        default { Write-Host "  Pilihan tidak valid!" -ForegroundColor Red; Start-Sleep 2 }
    }
    
    if ($choice -ne "6") {
        Write-Host ""
        Write-Host "  Tekan Enter untuk kembali..." -ForegroundColor Yellow
        Read-Host
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
    Write-Host "  [4] Speed Test (Auto)" -ForegroundColor White
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
            Write-Host "Auto Speed Test..." -ForegroundColor Yellow
            Write-Host ""
            
            # Check for wget first, fallback to curl or webclient
            $useWget = $false
            $useCurl = $false
            
            try {
                wget --version | Out-Null
                $useWget = $true
                Write-Host "  📡 Using wget for speed test..." -ForegroundColor Yellow
            }
            catch {
                try {
                    curl --version | Out-Null
                    $useCurl = $true
                    Write-Host "  📡 Using curl for speed test..." -ForegroundColor Yellow
                }
                catch {
                    Write-Host "  📡 Initialize WebClient for speed test..." -ForegroundColor Yellow
                    Write-Host "  📡 Speedtest begin, please wait!" -ForegroundColor Yellow
                }
            }
            
            $testUrl = "https://proof.ovh.net/files/100Mb.dat"
            $testFile = "$env:TEMP\speedtest.tmp"
            
            try {
                # Remove existing file
                if (Test-Path $testFile) { Remove-Item $testFile -Force }
                
                $start = Get-Date
                
                if ($useWget) {
                    # Use wget
                    wget -q -O $testFile $testUrl
                }
                elseif ($useCurl) {
                    # Use curl
                    curl -s -o $testFile $testUrl
                }
                else {
                    # Use WebClient
                    $webClient = New-Object System.Net.WebClient
                    $webClient.DownloadFile($testUrl, $testFile)
                    $webClient.Dispose()
                }
                
                $end = Get-Date
                
                # Calculate speed
                $fileSize = (Get-Item $testFile).Length
                $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
                $duration = ($end - $start).TotalSeconds
                $speedMBps = [math]::Round(($fileSizeMB / $duration), 2)
                $speedMbps = [math]::Round(($speedMBps * 8), 2)
                
                Write-Host ""
                Write-Host "  NOTE: THIS SPEEDTEST MAY BE NOT ACCURATE" -ForegroundColor Green
                Write-Host "  ✅ Complete! Average Speed: $speedMBps MB/s ($speedMbps Mbps)" -ForegroundColor Green
                Write-Host "  📊 Duration: $([math]::Round($duration, 2))s | Size: $fileSizeMB MB" -ForegroundColor White
                
                # Rating
                if ($speedMbps -gt 100) { Write-Host "  🚀 Sangat Cepat!" -ForegroundColor Green }
                elseif ($speedMbps -gt 50) { Write-Host "  ⚡ Cepat" -ForegroundColor Yellow }
                elseif ($speedMbps -gt 25) { Write-Host "  📶 Sedang" -ForegroundColor Yellow }
                else { Write-Host "  🐌 Lambat" -ForegroundColor Red }
                
                Remove-Item $testFile -Force
                
            }
            catch {
                Write-Host "  ❌ Speed test failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "  💡 Check your internet connection" -ForegroundColor Yellow
                Remove-Item $testFile -Force -ErrorAction SilentlyContinue
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
    Write-Host "  ⚠️  PERINGATAN: Ini akan menjalankan disk cleanup otomatis!" -ForegroundColor Red
    Write-Host "  File temporary dan cache akan dihapus secara permanen." -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Yakin ingin melanjutkan disk cleanup? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "  Disk cleanup dibatalkan." -ForegroundColor Yellow
        Start-Sleep 2
        return
    }
    
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
        
        $totalCleaned = 0
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                $fileCount = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue).Count
                Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                $totalCleaned += $fileCount
            }
        }
        Write-Host "    ✓ $totalCleaned file(s) dihapus dari lokasi temp" -ForegroundColor Green
        
        # Analyze disk space
        Write-Host "  [3/3] Menganalisis ruang disk..." -ForegroundColor Yellow
        Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
            $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
            $totalGB = [math]::Round($_.Size / 1GB, 2)
            $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
            Write-Host "    Drive $($_.DeviceID) - Free: $freeGB GB ($freePercent% of $totalGB GB)" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "  🎉 Disk cleanup berhasil!" -ForegroundColor Green
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
        $choice = Read-Host "Pilih opsi (1-7)"
        
        switch ($choice) {
            "1" { Invoke-SystemCleaner }
            "2" { Invoke-RecycleBinManager }
            "3" { Invoke-PowerManager }
            "4" { Show-SystemInfo }
            "5" { Invoke-NetworkTools }
            "6" { Invoke-DiskCleanup }
            "7" { 
                Clear-Host
                Write-Host "=====================================================================================" -ForegroundColor Cyan
                Write-Host "                                   KELUAR APLIKASI" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  Terima kasih telah menggunakan Windows Script Launcher!" -ForegroundColor Green
                Write-Host ""
                Write-Host "  PowerShell Edition v1.2 - Enhanced with simplified speed test" -ForegroundColor White
                Write-Host ""
                Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Aplikasi akan ditutup dalam 3 detik..." -ForegroundColor Yellow
                Start-Sleep 3
                exit 
            }
            default { 
                Write-Host "Pilihan tidak valid! Silakan pilih 1-7." -ForegroundColor Red
                Start-Sleep 2
            }
        }
    } while ($true)
}

# Allow direct function calls via parameters
switch ($Action.ToLower()) {
    "system" { Invoke-SystemCleaner }
    "recycle" { Invoke-RecycleBinManager }
    "power" { Invoke-PowerManager }
    "sysinfo" { Show-SystemInfo }
    "network" { Invoke-NetworkTools }
    "disk" { Invoke-DiskCleanup }
    default { 
        if ($Action -ne "menu") {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Available actions: menu, system, recycle, power, sysinfo, network, disk" -ForegroundColor Yellow
        }
    }
}
