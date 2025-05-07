# Download the HTML file from a URL
$url = "https://crystalmark.info/redirect.php?product=CrystalDiskInfo"

$tempFolder = "mods/installs/temp/cdi/"
$htmlFilePath = $tempFolder + "downloadpage.html"

# Create the temporary folder if it doesn't exist
if (-Not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
}

# Download the HTML file
Invoke-WebRequest -Uri $url -OutFile $htmlFilePath

# Check if the file was downloaded successfully
if (-Not (Test-Path $htmlFilePath)) {
    Write-Error "Failed to download the HTML file."
    exit
}

# Load the HTML content
$htmlContent = Get-Content $htmlFilePath -Raw

# Create an HTML document object
$document = New-Object -ComObject "HTMLFile"
$document.write([System.Text.Encoding]::Unicode.GetBytes($htmlContent))

# Get the anchor tag with ID 'download-now-link'
$link = $document.getElementById("download-now-link")

# Check if the element exists and has an href
if ($link -ne $null -and $link.href -ne $null) {
    Write-Output "Found CDI download link: $($link.href)"
} else {
    Write-Output "No link with ID 'download-now-link' found."
}

# Download the file using the link
$downloadUrl = $link.href

$downloadFileName = "cdi.zip"
$downloadFilePath = $tempFolder + $downloadFileName

Invoke-WebRequest -UserAgent "Wget" -Uri $downloadUrl -OutFile $downloadFilePath

# Extract the downloaded ZIP file
$extractFolder = "mods/installs/temp/cdi/extracted/"

# Create the extraction folder if it doesn't exist
if (-Not (Test-Path $extractFolder)) {
    New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null
}

Expand-Archive -Path $downloadFilePath -DestinationPath $extractFolder -Force

# Delete the DiskInfoA64.exe file if it exists
$diskInfoFilePath = $extractFolder + "DiskInfoA64.exe"
if (Test-Path $diskInfoFilePath) {
    Remove-Item -Path $diskInfoFilePath -Force
}

# Move the extracted files to the final destination
$finalDestination = "mods\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Tools\CrystalDiskInfo\"
Copy-Item -Path $extractFolder* -Destination $finalDestination -Recurse -Force