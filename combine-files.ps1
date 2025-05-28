#region Configuration
$OutputPath = "CombinedFile.txt"  # The name of the output file
$CurrentDirectory = Get-Location # The current directory where the script is executed
$SkipBinaryFiles = $true         # Set to $true to skip binary files
$BinaryFileExtensions = @(".exe", ".dll", ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".zip", ".rar", ".7z", ".pdf", ".mp3", ".mp4", ".avi", ".psd", ".class", ".jar", ".ico") # Extensions to consider as binary
$ExcludeDirectories = @("node_modules", "obj", "bin", "Migrations") # Directories to exclude
$ExcludeFiles = @("package-log.json", "Combine-Files.ps1", $OutputPath) # Files to exclude (including the script itself and the output)
$MaxDepth = -1 # Set -1 to go through entire structure, or set to a number for example - 3, to search only 3 subfolder levels


#endregion Configuration

#region Helper Functions

# Function to build the directory tree structure
function Build-DirectoryTree {
    param (
        [string]$Path,
        [int]$Depth = 0,
        [string]$Indent = ""
    )

    # Check max depth
    if ($MaxDepth -gt 0 -and $Depth -gt $MaxDepth) {
        return
    }

    # Check if directory is in exclude list
    if ($ExcludeDirectories -contains ([System.IO.Path]::GetFileName($Path))) {
        return
    }

    $Directories = Get-ChildItem -Path $Path -Directory | Where-Object { -not ($ExcludeDirectories -contains $_.Name) }

    for ($i = 0; $i -lt $Directories.Count; $i++) {
        $Directory = $Directories[$i]
        $IsLast = ($i -eq ($Directories.Count - 1))

        $LinePrefix = $Indent
        if ($IsLast) {
            $LinePrefix += "`-- "
            $NextIndent = $Indent + "    "
        } else {
            $LinePrefix += "|-- "
            $NextIndent = $Indent + "|   "
        }

        Write-Host "$LinePrefix$($Directory.Name)"

        # Append the tree structure line to the output file
        "$LinePrefix$($Directory.Name)" | Out-File -FilePath $OutputPath -Append -Encoding UTF8

        # Recursively call the function for subdirectories
        Build-DirectoryTree -Path $Directory.FullName -Depth ($Depth + 1) -Indent $NextIndent
    }
}

# Function to check if a file is likely a binary file
function Is-BinaryFile {
    param (
        [string]$FilePath
    )

    $Extension = [System.IO.Path]::GetExtension($FilePath)

    if ($BinaryFileExtensions -contains $Extension) {
        return $true
    }

    # Check for null bytes.  If present, probably a binary.  This is a simplified check.
    try {
        $Bytes = Get-Content -Path $FilePath -Encoding Byte -ReadCount 4096 -TotalCount 4096
        if ($Bytes -contains 0) {
            return $true
        } else {
            return $false
        }

    }
    catch {
        # If we can't read the file (e.g., permissions issues), assume it's not a text file.
        return $true
    }
}

#endregion Helper Functions

#region Main Script

# Clear the output file if it exists
if (Test-Path -Path $OutputPath) {
    Remove-Item -Path $OutputPath
}

# Write a header to the output file
"Directory Structure:" | Out-File -FilePath $OutputPath -Encoding UTF8
"--------------------" | Out-File -FilePath $OutputPath -Append -Encoding UTF8

# Build and write the directory tree structure
Build-DirectoryTree -Path $CurrentDirectory.Path

# Write a separator before the file contents start
"--------------------" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
"File Contents:"      | Out-File -FilePath $OutputPath -Append -Encoding UTF8
"--------------------" | Out-File -FilePath $OutputPath -Append -Encoding UTF8

# Get all files in the current directory and subdirectories
$Files = Get-ChildItem -Path $CurrentDirectory.Path -File -Recurse

# Create an array to store the filtered files
$FilteredFiles = @()

# Iterate through each file
foreach ($File in $Files) {
    # Check if the file name is in the exclude list
    if ($ExcludeFiles -contains $File.Name) {
        Write-Host "Excluding file by name: $($File.FullName)"
        continue # Skip to the next file
    }

    # Check if the file is located in an excluded directory
    $IsInExcludedDir = $false
    # Ensure the file's directory is a subdirectory of the current execution path and not the root itself.
    # This check is case-insensitive for paths, standard on Windows.
    if ($File.DirectoryName.StartsWith($CurrentDirectory.Path, [System.StringComparison]::OrdinalIgnoreCase) -and $File.DirectoryName.Length -gt $CurrentDirectory.Path.Length) {
        # Get the part of the file's directory path that is relative to the current execution path.
        # e.g., if $CurrentDirectory.Path is 'C:\\Project' and $File.DirectoryName is 'C:\\Project\\src\\bin',
        # $RelativeFileDirPath will be '\\src\\bin'.
        $RelativeFileDirPath = $File.DirectoryName.Substring($CurrentDirectory.Path.Length)
        
        # Normalize by removing any leading path separators (e.g., '\\src\\bin' becomes 'src\\bin').
        $NormalizedRelativePath = $RelativeFileDirPath.TrimStart([System.IO.Path]::DirectorySeparatorChar)
        
        # Split the normalized relative path into its directory components (e.g., 'src', 'bin').
        # Empty components (e.g., from '\\\\' in path) are filtered out.
        $PathComponents = $NormalizedRelativePath.Split([System.IO.Path]::DirectorySeparatorChar) | Where-Object { $_.Length -gt 0 }

        # Check if any of these path components match a name in the $ExcludeDirectories list (case-insensitive).
        foreach ($ExcludedDirNameFromList in $ExcludeDirectories) { # e.g., "bin"
            # Perform a case-insensitive check for the excluded directory name within the path components
            $PathContainsExcludedDir = $PathComponents | Where-Object { $_.Equals($ExcludedDirNameFromList, [System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
            if ($null -ne $PathContainsExcludedDir) {
                Write-Host "Excluding file: $($File.FullName) (Reason: Its path contains an excluded directory component matching '$ExcludedDirNameFromList')"
                $IsInExcludedDir = $true
                break # Found an excluded component; no need to check further for this file.
            }
        }
    }

    if ($IsInExcludedDir) {
        continue # Skip to the next file
    }

    # If the file passes all exclusion checks, add it to the filtered files array
    $FilteredFiles += $File
}


# Iterate through each file
foreach ($File in $FilteredFiles) {

    if ($SkipBinaryFiles -and (Is-BinaryFile -FilePath $File.FullName)) {
        Write-Host "Skipping binary file: $($File.FullName)"
        "Skipping binary file: $($File.FullName)" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
        continue # Skip to the next file
    }

    Write-Host "Processing file: $($File.FullName)"

    # Write the file path to the output file
    "--------------------" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
    "File: $($File.FullName)" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
    "--------------------" | Out-File -FilePath $OutputPath -Append -Encoding UTF8

    try {
        # Read the file content and append it to the output file
        Get-Content -Path $File.FullName -Encoding UTF8 -ErrorAction Stop | Out-File -FilePath $OutputPath -Append -Encoding UTF8

        #Add a blank line
        "" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
    }
    catch {
        Write-Warning "Error reading file $($File.FullName): $($_.Exception.Message)"
        "Error reading file $($File.FullName): $($_.Exception.Message)" | Out-File -FilePath $OutputPath -Append -Encoding UTF8
    }
}

Write-Host "Script completed.  Combined file created at: $($OutputPath)"

#endregion Main Script