# Set output paths
$targetDir = "mods\installs\temp\7-Zip\"
$exeFile = Join-Path $targetDir "7zip_installer.exe"
$programDir = Join-Path $PSScriptRoot "mods\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Tools\7-Zip\"

# Ensure target directories exist
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
New-Item -ItemType Directory -Force -Path $programDir | Out-Null

# Get the latest 64-bit .exe URL from the 7-Zip website
try {
    $response = Invoke-WebRequest -Uri 'https://www.7-zip.org/download.html' -UseBasicParsing
    $match = [regex]::Match($response.Content, 'a\/(7z[\d]+-x64\.exe)')
    if ($match.Success) {
        $downloadUrl = "https://www.7-zip.org/a/" + $match.Groups[1].Value
    } else {
        Write-Error "Failed to find the latest 7-Zip download link."
        Pause
        exit 1
    }
} catch {
    Write-Error "Error accessing 7-Zip site: $_"
    Pause
    exit 1
}

# Download the installer
Write-Host "Downloading: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $exeFile

# Install silently to target folder
Start-Process -FilePath ".\$exeFile" -ArgumentList "/S /D=$targetDir" -Wait

# Delete the installer
Remove-Item -Path $exeFile -Force

# Copy installed files to program directory
try {
    Copy-Item -Path (Join-Path $targetDir "*") -Destination $programDir -Recurse -Force
} catch {
    Write-Error "Failed to copy files to $programDir"
    Pause
    exit 1
}

# Cleanup
Remove-Item -Path $exeFile -Force
Remove-Item -Path (Join-Path $targetDir "*") -Force -Recurse

Write-Host "Done! 7-Zip installed to $programDir"