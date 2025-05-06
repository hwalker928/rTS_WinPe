# Download the HTML file from a URL
$url = "https://crystalmark.info/redirect.php?product=CrystalDiskMark"

$tempFolder = "mods/installs/temp/cdm/"
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
$document.IHTMLDocument2_write($htmlContent)
$document.IHTMLDocument2_close()

# Get the anchor tag with ID 'download-now-link'
$link = $document.getElementById("download-now-link")

# Check if the element exists and has an href
if ($link -ne $null -and $link.href -ne $null) {
    Write-Output "Found CDM download link: $($link.href)"
} else {
    Write-Output "No link with ID 'download-now-link' found."
}

# Download the file using the link
$downloadUrl = $link.href

$downloadFileName = "cdm.zip"
$downloadFilePath = $tempFolder + $downloadFileName

Invoke-WebRequest -UserAgent "Wget" -Uri $downloadUrl -OutFile $downloadFilePath

# Extract the downloaded ZIP file
$extractFolder = "mods/installs/temp/cdm/extracted/"

# Create the extraction folder if it doesn't exist
if (-Not (Test-Path $extractFolder)) {
    New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null
}

Expand-Archive -Path $downloadFilePath -DestinationPath $extractFolder -Force

# Delete the DiskMarkA64.exe file if it exists
$diskInfoFilePath = $extractFolder + "DiskMarkA64.exe"
if (Test-Path $diskInfoFilePath) {
    Remove-Item -Path $diskInfoFilePath -Force
}

# Move the extracted files to the final destination
$finalDestination = "mods\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Tools\CrystalDiskMark\"
Copy-Item -Path $extractFolder* -Destination $finalDestination -Recurse -Force