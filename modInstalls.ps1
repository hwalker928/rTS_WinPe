Write-Host "Installing programs..." -ForegroundColor Green

# Remove temporary folders if they exist
if (Test-Path "mods/installs/temp/") {
    Write-Host "Cleaning up old temporary folders..." -ForegroundColor Green
    Remove-Item -Path "mods/installs/temp/" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Creating temporary folders..." -ForegroundColor Green
$tempFolder = "mods/installs/temp/"
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null

Write-Host "Installing 7-Zip... (1/9)" -ForegroundColor Green
& .\mods\installs\7zip.ps1

Write-Host "Installing CrystalDiskInfo... (2/9)" -ForegroundColor Green
& .\mods\installs\cdi.ps1

Write-Host "Installing CrystalDiskMark... (3/9)" -ForegroundColor Green
& .\mods\installs\cdm.ps1

# exit here for now since the rest of the installs are not working yet
Write-Host "Exiting for debug purposes..." -ForegroundColor Yellow
exit 1

Write-Host "Installing GenericLogViewer... (4/9)" -ForegroundColor Green
& .\mods\installs\glv.bat

Write-Host "Installing Speccy... (5/9)" -ForegroundColor Green
& .\mods\installs\speccy.bat

Write-Host "Installing HWiNFO... (6/9)" -ForegroundColor Green
& .\mods\installs\hwinfo.bat

Write-Host "Installing Notepad++... (7/9)" -ForegroundColor Green
& .\mods\installs\npp.bat

Write-Host "Installing Prime95... (8/9)" -ForegroundColor Green
& .\mods\installs\p95.bat

Write-Host "Installing WinXShell... (9/9)" -ForegroundColor Green
& .\mods\installs\wxs.bat

Write-Host "Cleaning up..." -ForegroundColor Green
Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Installation complete!" -ForegroundColor Green