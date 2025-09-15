Write-Host "Mengunduh dan menjalankan launcher..."
$batUrl = "https://raw.githubusercontent.com/risunCode/WinPortal/main/winScript/WinScriptLauncher.bat"
$batPath = "$env:TEMP\WinScriptLauncher.bat"

Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing
Start-Process -FilePath $batPath -Wait
Write-Host "Launcher selesai dijalankan."