Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "BB-Display Firmware Uploader"
$form.Size = New-Object System.Drawing.Size(400, 240)
$form.StartPosition = "CenterScreen"

# Create File Label
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = "Select File:"
$fileLabel.Location = New-Object System.Drawing.Point(10, 20)
$fileLabel.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($fileLabel)

# Create File TextBox
$fileTextBox = New-Object System.Windows.Forms.TextBox
$fileTextBox.Location = New-Object System.Drawing.Point(100, 20)
$fileTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($fileTextBox)

# Create File Browse Button
$fileButton = New-Object System.Windows.Forms.Button
$fileButton.Text = "Browse"
$fileButton.Location = New-Object System.Drawing.Point(310, 20)
$fileButton.Size = New-Object System.Drawing.Size(60, 25)
$fileButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileTextBox.Text = $fileDialog.FileName
    }
})
$form.Controls.Add($fileButton)

# Create IP Address Label
$ipLabel = New-Object System.Windows.Forms.Label
$ipLabel.Text = "BB-Display IP Address:"
$ipLabel.Location = New-Object System.Drawing.Point(10, 60)
$ipLabel.Size = New-Object System.Drawing.Size(140, 20)
$form.Controls.Add($ipLabel)

# Create IP Address TextBox
$ipTextBox = New-Object System.Windows.Forms.TextBox
$ipTextBox.Location = New-Object System.Drawing.Point(150, 60)
$ipTextBox.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($ipTextBox)

# Create Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 100)
$progressBar.Size = New-Object System.Drawing.Size(360, 25)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# Create Upload Button
$uploadButton = New-Object System.Windows.Forms.Button
$uploadButton.Text = "Upload"
$uploadButton.Location = New-Object System.Drawing.Point(150, 140)
$uploadButton.Size = New-Object System.Drawing.Size(80, 30)
$uploadButton.Add_Click({
    $File = $fileTextBox.Text
    $ESP32_IP = $ipTextBox.Text

    # Validate inputs
    if (-not (Test-Path $File)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    if ($ESP32_IP -notmatch "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$") {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid IP address.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Start upload
    $FileSize = (Get-Item $File).Length
    $TotalChunks = 100
    $ChunkSize = [math]::Ceiling($FileSize / $TotalChunks)
    $ServerURL = "http://$ESP32_IP/upload"

    Write-Host "Uploading firmware: $File to BB-Display at $ESP32_IP"
    Write-Host "File size: $FileSize bytes"
    Write-Host "Total chunks: $TotalChunks"
    Write-Host "Calculated chunk size: $ChunkSize bytes"

    $progressBar.Value = 0
    $fileStream = [System.IO.File]::OpenRead($File)
    try {
        for ($i = 0; $i -lt $TotalChunks; $i++) {
            $StartByte = $i * $ChunkSize

            # Adjust chunk size for the last chunk
            $bufferSize = if ($i -eq $TotalChunks - 1) { $FileSize - $StartByte } else { $ChunkSize }

            # Seek and read the chunk
            $fileStream.Seek($StartByte, [System.IO.SeekOrigin]::Begin) | Out-Null
            $buffer = New-Object byte[] $bufferSize
            $bytesRead = $fileStream.Read($buffer, 0, $bufferSize)

            if ($bytesRead -eq 0) {
                Write-Host "No data read for chunk $i."
                break
            }

            # Send the chunk via HTTP
            $Header = "chunk-number:$i;total-chunks:$TotalChunks;"
            try {
                $Response = Invoke-RestMethod -Uri $ServerURL -Method Post -Headers @{ "X-Chunk-Info" = $Header } -Body $buffer
                Write-Host "Chunk $i uploaded successfully."
            } catch {
                Write-Host "Chunk $i upload failed: $_"
                [System.Windows.Forms.MessageBox]::Show("Chunk $i upload failed.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                break
            }

            # Update progress bar
            $progressBar.Value = [math]::Floor((($i + 1) / $TotalChunks) * 100)
        }

        [System.Windows.Forms.MessageBox]::Show("Firmware upload to $ESP32_IP completed successfully.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $progressBar.Value = 100
    } finally {
        $fileStream.Close()
    }
})
$form.Controls.Add($uploadButton)

# Show the Form
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()
