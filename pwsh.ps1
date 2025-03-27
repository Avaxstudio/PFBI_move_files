# Get user input
$sourceDir = Read-Host "Enter the source directory"
$fileExt = Read-Host "Enter the file extension (without dot)"
$destDir = Read-Host "Enter the destination directory"

# Validate source directory
if (!(Test-Path $sourceDir -PathType Container)) {
    Write-Host "Error: Source directory does not exist!" -ForegroundColor Red
    exit
}

# Validate file extension
if ([string]::IsNullOrWhiteSpace($fileExt)) {
    Write-Host "Error: No file extension provided!" -ForegroundColor Red
    exit
}

# Ensure file extension starts with a dot (e.g., ".txt")
$fileExt = ".$fileExt"

# Find all matching files
$files = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object { $_.Extension -ieq $fileExt }

# If no files found, exit
if ($files.Count -eq 0) {
    Write-Host "No '.$fileExt' files found in '$sourceDir'." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($files.Count) file(s) with extension '$fileExt'. Moving files..."

# Ensure the destination directory exists
if (!(Test-Path $destDir -PathType Container)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Move files while preserving directory structure
foreach ($file in $files) {
    # Get relative path correctly
    $relPath = $file.FullName.Substring($sourceDir.Length).TrimStart("\", "/")

    # Construct full destination path
    $destPath = Join-Path -Path $destDir -ChildPath $relPath

    # Ensure target directories exist
    $targetDir = Split-Path -Path $destPath -Parent
    if (!(Test-Path $targetDir -PathType Container)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Check if file exists at destination
    if (Test-Path $destPath) {
        Write-Host "Skipping: File already exists -> $destPath" -ForegroundColor Yellow
    } else {
        # Move file and force overwrite if needed
        Move-Item -Path $file.FullName -Destination $destPath -Force
        Write-Host "Moved: $($file.FullName) → $destPath"
    }
}

Write-Host "All '.$fileExt' files moved to '$destDir', preserving the directory structure."
