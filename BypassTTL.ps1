function Show-Menu {
    param(
        [PSCustomObject]$CurrentTTLs
    )
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host "               PENGATURAN TTL HOP LIMIT" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " TTL Hop Limit Saat Ini:" -ForegroundColor Yellow
    Write-Host "   IPv4 : $($CurrentTTLs.IPv4TTL)" -ForegroundColor Yellow
    Write-Host "   IPv6 : $($CurrentTTLs.IPv6TTL)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " Pilih salah satu opsi di bawah ini:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   [1] Set TTL Hop Limit ke 65" -ForegroundColor Yellow
    Write-Host "   [2] Set TTL Hop Limit ke Default Windows (128)" -ForegroundColor Yellow
    Write-Host "   [3] Batal / Keluar" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host "Tekan tombol angka untuk memilih opsi: " -NoNewline -ForegroundColor Yellow

    # Menunggu input tombol tanpa perlu Enter - PERBAIKAN DI SINI
    $options = [System.Management.Automation.Host.ReadKeyOptions]::NoEcho -bor [System.Management.Automation.Host.ReadKeyOptions]::IncludeKeyDown
    $keyInfo = $Host.UI.ReadKey($options)
    return $keyInfo.Character
}
