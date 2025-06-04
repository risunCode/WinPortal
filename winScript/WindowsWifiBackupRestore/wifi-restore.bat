@ECHO OFF
REM This will loop through all *.xml files in the current folder and import the profiles 
FORFILES /M *.xml /C "cmd /c netsh wlan add profile @path"