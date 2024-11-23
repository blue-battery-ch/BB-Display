# Check if both filename and ESP32 IP address were provided
if ($args.Length -lt 2) {
    Write-Host "Usage: script.ps1 <filename> <esp32_ip>"
    exit 1
}

$File = $args[0]
$ESP32_IP = $args[1]

# Check if the file exists
if (!(Test-Path $File)) {
    Write-Host "File not found: $File"
    exit 1
}

# Determine file size
$FileSize = (Get-Item $File).Length

# Fixed total chunks
$TotalChunks = 100
$ChunkSize = [math]::Ceiling($FileSize / $TotalChunks)

$ServerURL = "http://$ESP32_IP/upload"

Write-Host "Uploading file: $File to ESP32 at $ESP32_IP"
Write-Host "File size: $FileSize bytes"
Write-Host "Total chunks: $TotalChunks"
Write-Host "Calculated chunk size: $ChunkSize bytes"

for ($i = 0; $i -lt $TotalChunks; $i++) {
    $StartByte = $i * $ChunkSize
    $EndByte = $StartByte + $ChunkSize - 1

    # Adjust chunk size for the last chunk
    if ($EndByte -ge $FileSize) {
        $ChunkSizeLast = $FileSize - $StartByte
        $Header = "chunk-number:$i;total-chunks:$TotalChunks;"
        $ChunkData = Get-Content -Path $File -Encoding Byte -ReadCount $ChunkSizeLast -TotalCount $ChunkSizeLast -Skip $StartByte
    } else {
        $Header = "chunk-number:$i;total-chunks:$TotalChunks;"
        $ChunkData = Get-Content -Path $File -Encoding Byte -ReadCount $ChunkSize -TotalCount $ChunkSize -Skip $StartByte
    }

    # Upload chunk
    try {
        $Response = Invoke-RestMethod -Uri $ServerURL -Method Post -Headers @{ "X-Chunk-Info" = $Header } -Body ([System.Text.Encoding]::UTF8.GetBytes($ChunkData))
        Write-Host "Chunk $i uploaded."
    } catch {
        Write-Host "Chunk $i upload failed."
        exit 1
    }
}

Write-Host "File upload to $ESP32_IP completed successfully."
