#Requires -Version 5.1

$ScriptHeader = @"
  _____            _    _                 _____ _                            
 |  __ \          | |  | |               / ____| |                           
 | |  | | ___  ___| | _| |_ ___  _ __   | |    | | ___  __ _ _ __   ___ _ __ 
 | |  | |/ _ \/ __| |/ / __/ _ \| '_ \  | |    | |/ _ \/ _` | '_ \ / _ \ '__|
 | |__| |  __/\__ \   <| || (_) | |_) | | |____| |  __/ (_| | | | |  __/ |   
 |_____/ \___||___/_|\_\\__\___/| .__/   \_____|_|\___|\__,_|_| |_|\___|_|   
                                | |                                          
                                |_|                                          
"@

Write-Host $ScriptHeader

Write-Host "[INFO] Desktop Cleaning Task has started" -ForegroundColor Gray
$DesktopLocation = [Environment]::GetFolderPath("Desktop")
$ConfigurationFilePath = [System.IO.Path]::Combine("$PSScriptRoot/conf","Clean-Desktop.json")

try {
    $ConfigurationDatas = Get-Content -Path $ConfigurationFilePath -Raw
    $Settings = ConvertFrom-Json -InputObject $ConfigurationDatas
    Write-Host "[INFO] Load JSON configuration file" -ForegroundColor Yellow
}
catch {
    "An error has occured, {0}" -f $_.Exception.Message
    break
}

Write-Host "[JSON] Exclusions : $($Settings.Filter.Exclude)" -ForegroundColor Gray
Write-Host "[JSON] Date Format : $($Settings.General.DateFormat)" -ForegroundColor Gray
Write-Host "[JSON] Threshold : $($Settings.General.Threshold) day(s)" -ForegroundColor Gray

if ($Settings.Debug.WhatIf) {
    Write-Host "[JSON] Debug Mode : $($Settings.Debug.WhatIf)" -ForegroundColor White -BackgroundColor DarkBlue
    # Set $PSDefaultParameterValues
    $PSDefaultParameterValues.Add('New-Item:WhatIf', $true)
    $PSDefaultParameterValues.Add('Move-Item:WhatIf', $true)
    $PSDefaultParameterValues.Add('Remove-Item:WhatIf', $true)
}

$Timestamp = Get-Date -f $Settings.General.DateFormat

# Replace environment variables in $Settings.General.BackupLocation if needed
$BackupLocation = $Settings.General.BackupLocation
[regex]::Matches($BackupLocation,"[%]\w*[%]").Value | % { $BackupLocation = $BackupLocation.Replace($_,[Environment]::GetEnvironmentVariable($_.Trim("%"))) }

# Combine $BackupLocation path with timestamped subfolder for full backup folder path
$BackupFolderPath = [System.IO.Path]::Combine($BackupLocation,$Timestamp)
Write-Host "[INFO] Backup location is $BackupFolderPath" -ForegroundColor Yellow

# Retrieve files in the scope then sort them by deepest path
Write-Host "[INFO] Retrieve files in scope" -ForegroundColor Yellow
$Files = Get-ChildItem -Path $DesktopLocation -Exclude $Settings.Filter.Exclude -Recurse | ? { !$_.PSIsContainer -and ([DateTime]::Now - $_.LastWriteTime).TotalDays -gt $Settings.General.Threshold} | Sort { [System.IO.Path]::GetDirectoryName($_.Fullname).Split("\").count } 

foreach ($File in $Files) {
	Write-Host "[INFO] Found $($File.FullName), $([int]([DateTime]::Now - $File.LastWriteTime).TotalDays) day(s) old" -ForegroundColor Cyan
}

# If there is files in scope
if ($Files.Count -ge 1) {

    # Check backup location, and create it if missing
    if (![System.IO.Directory]::Exists($BackupFolderPath)) {
        try {
            Write-Host "[INFO] Create Backup folder $BackupFolderPath" -ForegroundColor Yellow
            New-Item -Path $BackupFolderPath -Type Directory -Force | Out-Null
        }
        catch {
            "An error has occured, {0}" -f $_.Exception.Message
            break 
        }
    }

    # Creating folder at backup location if needed, then move file.
    foreach ($File in $Files) {
        $BackupFolderPath = $File.Directory.FullName.Replace($DesktopLocation,[System.IO.Path]::Combine($BackupLocation,$Timestamp))
        
        try {
            if (![System.IO.Directory]::Exists($BackupFolderPath)) {
                Write-Host "[INFO] Create $BackupFolderPath" -ForegroundColor Cyan
                New-Item -Path $BackupFolderPath -Type Directory -Force | Out-Null
            }
            Write-Host "[INFO] Archive file $($File.FullName)" -ForegroundColor Cyan
            Move-Item -Path $File.FullName -Destination $BackupFolderPath | Out-Null
        }
        catch {
            # If error : display a message.
            Write-Host "[ERR] Error when moving $($File.FullName), $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Finally, remove empty folders.

    # Retrieve folders in the scope then sort them by shortest path
    $Folders = Get-ChildItem -Path $DesktopLocation -Recurse -Directory | Sort { [System.IO.Path]::GetDirectoryName($_.Fullname).Split("\").count } -Descending

    foreach ($Folder in $Folders.FullName) {
        $FolderSize = (Get-ChildItem $Folder -Recurse | Measure-Object -Property Length -Sum).Sum

        if ( $FolderSize -eq 0 -or $null -eq $FolderSize) {
            Write-Host "[INFO] Remove empty folder $Folder" -ForegroundColor Cyan
            Remove-Item -Path $Folder
        }
    }
}
else {
    Write-Host "[INFO] No file found in scope" -ForegroundColor Cyan
}
Write-Host "[INFO] Desktop Cleaning Task has finished" -ForegroundColor Gray

# Clean $PSDefaultParameterValues
if ($Settings.Debug.WhatIf) {
    $PSDefaultParameterValues.Remove('New-Item:WhatIf')
    $PSDefaultParameterValues.Remove('Move-Item:WhatIf')
    $PSDefaultParameterValues.Remove('Remove-Item:WhatIf')
}

Read-Host

