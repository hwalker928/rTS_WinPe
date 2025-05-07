# rTS_WinPE build script
# PipeItToDevNull

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running as Administrator. Restarting with elevated privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WorkingDirectory "$PWD"
    exit
}

# Ensure the script is running in the correct directory
Set-Location -Path "$PSScriptRoot"

Write-Host "Current directory: $PWD" -ForegroundColor Green

# Check if the required directories exist, else exit
if (-not (Test-Path -Path ".\mods")) {
    Write-Host "Directory ./mods does not exist. Please ensure the script was started in the correct directory." -ForegroundColor Red
    exit
}

# Delete the tmp directory if it exists
if (Test-Path -Path ".\tmp") {
    Write-Host "Deleting existing ./tmp directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force -Path ".\tmp"
}

Write-Host "Sourcing our clean environment to ./tmp..." -ForegroundColor Green
& .\sourceWim.bat

if (Test-Path -Path ".\tmp\mount") {
    Write-Host "Cleaning up existing mount directory..." -ForegroundColor Yellow
    dism /unmount-image /mountdir:tmp\mount /discard
    Remove-Item -Recurse -Force .\tmp\mount
}

Write-Host "Mounting WIM..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path tmp\mount | Out-Null
dism /mount-image /imagefile:tmp\media\sources\boot.wim /index:1 /mountdir:tmp\mount

Write-Host "Adding packages..." -ForegroundColor Green
$packagePath = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs'
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-WMI.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-NetFX.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-Scripting.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-PowerShell.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-SecureBootCmdlets.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-SecureStartup.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-StorageWMI.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-DismCmdlets.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-EnhancedStorage.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-FMAPI.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-WiFi-Package.cab"
dism /add-package /image:tmp\mount /packagepath:"$packagePath\WinPE-PlatformID.cab"

Write-Host "Grab MUIs from this valid host..." -ForegroundColor Green
Copy-Item -Force -Path "C:\Windows\System32\en-US\manage-bde.exe.mui" -Destination ".\tmp\mount\Windows\System32\en-US\"

Write-Host "Setting scratch..." -ForegroundColor Green
dism /set-scratchspace:512 /image:tmp\mount

& .\modInstalls.ps1

Write-Host "Putting our files in place..." -ForegroundColor Green
$sourceFiles = ".\mods\*"
$destDir = ".\tmp\mount\"
Copy-Item -Force -Recurse -Path $sourceFiles -Destination $destDir

Write-Host "Unmounting our WIM..." -ForegroundColor Green
dism /unmount-image /mountdir:tmp\mount /commit

Write-Host "Making an ISO..." -ForegroundColor Green
& .\makeISO.bat

Write-Host "Cleanup..." -ForegroundColor Green
Remove-Item -Recurse -Force .\tmp

Pause