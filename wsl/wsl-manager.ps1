#!/bin/env powershell
Set-StrictMode -Version latest;

# Function to list all WSL distros
function Get-Distros {
    # Force Console.OutputEncoding to Unicode to avoid conversion issues
    $consoleEncoding = [Console]::OutputEncoding;
    [Console]::OutputEncoding = [System.Text.Encoding]::Unicode;
    $result = wsl -l -v | ConvertFrom-String -PropertyNames SELECTED, NAME, STATE, VERSION | Select-Object -Skip 1;
    [Console]::OutputEncoding = $consoleEncoding;

    return $result;
}

# Function to print all WSL distros
function Print-Distros {
    Write-Host "Listing all WSL distros..." -ForegroundColor Cyan;
    $distros = @(Get-Distros);
    if ($distros.Length -le 0) {
        Write-Host "No WSL distros found." -ForegroundColor Yellow;
        return;
    }

    Write-Host "WSL Distros:" -ForegroundColor Green;
    $id = 1;
    $distros | ForEach-Object {
        Write-Host "$($id): Name=$($_.NAME), State=$($_.STATE), Version=$($_.VERSION)" -ForegroundColor Yellow;
        $id++;
    }
}

# Function to backup a WSL distro
function Backup-Distro {
    Write-Host "Backup a WSL distro..." -ForegroundColor Cyan;
    $distros = @(Get-Distros);
    $distroList = @($distros | ForEach-Object { $_.NAME });
    if ($distroList.Length -le 0) {
        Write-Error "No WSL distros found.";
        return;
    }

    # Prompt user to select a distro
    Write-Host "Select distro to backup:";
    $id = 0;
    $distroList | ForEach-Object { Write-Host "$($id+1): $($distroList[$id])" -ForegroundColor Yellow; $id++; }
    $selected = [int](Read-Host);
    if (($selected -gt $distroList.Length) -or ($selected -le 0)) {
        Write-Error "Invalid selection. Select a distro from 1 to $($distroList.Length)";
        return;
    }
    $distro = $distroList[$selected - 1];

    # Get backup directory
    Write-Host 'Enter backup directory:';
    $backupFolder = Read-Host;
    $backupFolder = $backupFolder.TrimEnd('\');

    # Create backup folder if it doesn't exist
    if (-not(Test-Path $backupFolder)) {
        New-Item -Path $backupFolder -ItemType 'directory' | Out-Null;
        if (-not($?)) {
            Write-Error "Failed to create backup folder `"$($backupFolder)`"";
            return;
        }
    }

    # Export WSL image to tar file
    $backupFile = Join-Path $backupFolder "$($distro).tar";
    Write-Host "Exporting WSL distro to `"$($backupFile)`" ...";
    wsl --terminate $distro;
    wsl --export $distro $backupFile;
    if (-not($? -and (Test-Path $backupFile -PathType Leaf))) {
        Write-Error "ERROR: Backup failed";
        return;
    }

    Write-Host "Backup completed successfully!" -ForegroundColor Green;
}

# Function to migrate a WSL distro
function Migrate-Distro {
    Write-Host "Migrating a WSL distro..." -ForegroundColor Cyan;

    # Get distros
    $distros = @(Get-Distros);
    $distroList = @($distros | ForEach-Object { $_.NAME });
    if ($distroList.Length -le 0) {
        Write-Error "No WSL distros found.";
        return;
    }

    # Prompt user to select a distro
    Write-Host "Select distro to migrate:";
    $id = 0;
    $distroList | ForEach-Object { Write-Host "$($id+1): $($distroList[$id])" -ForegroundColor Yellow; $id++; }
    $selected = [int](Read-Host);
    if (($selected -gt $distroList.Length) -or ($selected -le 0)) {
        Write-Error "Invalid selection. Select a distro from 1 to $($distroList.Length)";
        return;
    }
    $distro = $distroList[$selected - 1];

    # Get target directory
    Write-Host "Enter the target directory for migration:";
    $targetFolder = Read-Host;
    $targetFolder = $targetFolder.TrimEnd('\');

    # Create target folder if it doesn't exist
    if (-not(Test-Path $targetFolder)) {
        New-Item -Path $targetFolder -ItemType 'directory' | Out-Null;
        if (-not($?)) {
            Write-Error "Failed to create target folder `"$($targetFolder)`"";
            return;
        }
    }

    # Export and re-import the distro
    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "$($distro).tar";
    Write-Host "Exporting WSL distro to temporary file...";
    wsl --terminate $distro;
    wsl --export $distro $tempFile;
    if (-not($? -and (Test-Path $tempFile -PathType Leaf))) {
        Write-Error "Failed to export WSL distro.";
        return;
    }

    Write-Host "Importing WSL distro to new location...";
    wsl --unregister $distro;
    wsl --import $distro $targetFolder $tempFile;
    if (-not($?)) {
        Write-Error "Failed to import WSL distro.";
        return;
    }

    # Clean up temporary file
    Remove-Item $tempFile -Force;
    Write-Host "Migration completed successfully!" -ForegroundColor Green;
}

# Function to restore a WSL distro from backup
function Restore-Distro {
    Write-Host "Restore a WSL distro from backup..." -ForegroundColor Cyan;

    # Get backup file path
    Write-Host "Enter the path to the backup file (.tar):";
    $backupFile = Read-Host;
    if (-not(Test-Path $backupFile -PathType Leaf)) {
        Write-Error "Backup file not found or invalid.";
        return;
    }

    # Get new distro name
    Write-Host "Enter the name for the restored distro:";
    $newDistroName = Read-Host;
    if ([string]::IsNullOrWhiteSpace($newDistroName)) {
        Write-Error "Distro name cannot be empty.";
        return;
    }

    # Check if distro name already exists
    $existingDistros = @(Get-Distros | ForEach-Object { $_.NAME });
    if ($existingDistros -contains $newDistroName) {
        Write-Error "A distro with the name `"$($newDistroName)`" already exists.";
        return;
    }

    # Get target directory
    Write-Host "Enter the target directory for the restored distro:";
    $targetFolder = Read-Host;
    $targetFolder = $targetFolder.TrimEnd('\');

    # Create target folder if it doesn't exist
    if (-not(Test-Path $targetFolder)) {
        New-Item -Path $targetFolder -ItemType 'directory' | Out-Null;
        if (-not($?)) {
            Write-Error "Failed to create target folder `"$($targetFolder)`"";
            return;
        }
    }

    # Import the backup file
    Write-Host "Importing WSL distro from backup file...";
    wsl --import $newDistroName $targetFolder $backupFile;
    if (-not($?)) {
        Write-Error "Failed to import WSL distro.";
        return;
    }

    Write-Host "Restoration completed successfully!" -ForegroundColor Green;
}

# Main menu
function Show-Menu {
    while ($true) {
        Write-Host "`n=== WSL Manager ===" -ForegroundColor Cyan;
        Write-Host "1. List WSL distros";
        Write-Host "2. Backup a WSL distro";
        Write-Host "3. Restore a WSL distro";
        Write-Host "4. Migrate a WSL distro";
        Write-Host "5. Exit";

        $choice = Read-Host "Enter your choice (1-5)";
        switch ($choice) {
            1 { Print-Distros; }
            2 { Backup-Distro; }
            3 { Restore-Distro; }
            4 { Migrate-Distro; }
            5 { Write-Host "Exiting..."; return; }
            default { Write-Host "Invalid choice. Please select a valid option."; }
        }
    }
}

# Start the menu
Show-Menu;
exit 0;