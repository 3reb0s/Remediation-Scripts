# OneStart and DBar Removal Script adopted from DaMrKush https://www.reddit.com/r/crowdstrike/comments/1id39cp/onestartai_remover/?rdt=49859 


$process_names = @("DBar", "OneStart")

# Valid Paths (Old and New)
$valid_paths = @(
    "C:\Users\*\AppData\Roaming\OneStart\*",
    "C:\Users\*\AppData\Local\OneStart.ai\*"
)

# Kill matching processes with valid paths
foreach ($proc in $process_names) {
    $OL_processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $proc }

    if ($OL_processes.Count -eq 0) {
        Write-Output "No $proc processes were found."
    } else {
        Write-Output "The following processes contained '$proc'. File paths will be checked."
        foreach ($process in $OL_processes) {
        try {
            $path = $process.Path
            if ($valid_paths | Where-Object { $path -like $_ }) {
             Stop-Process $process -Force
            Write-Output "$proc process ($path) has been stopped."
        } else {
             Write-Output "$proc process path '$path' doesn't match expected paths and was not stopped."
    }
} catch {
    Write-Output "Could not evaluate or stop process"
            }
        }
    }
}

Start-Sleep -Seconds 2

# Directories to delete (Old and New)
$file_paths = @(
    "\AppData\Roaming\OneStart\",
    "\AppData\Local\OneStart.ai\"
)

# Remove folders under each user
foreach ($folder in Get-ChildItem C:\Users -Directory) {
    foreach ($fpath in $file_paths) {
        $path = Join-Path -Path $folder.FullName -ChildPath $fpath
        Write-Output "Checking path: $path"
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $path)) {
                Write-Output "$path has been deleted."
            } else {
                Write-Output "$path could not be deleted."
            }
        } else {
            Write-Output "$path does not exist."
        }
    }
}


$reg_paths = @("\software\OneStart.ai", "\software\OneStart")

# Remove registry keys under each user
foreach ($registry_hive in Get-ChildItem registry::hkey_users) {
    foreach ($regpath in $reg_paths) {
        $path = $registry_hive.PSPath + $regpath
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-Output "$path has been removed."
        }
    }
}

# Registry property cleanup
$reg_properties = @("OneStartBar", "OneStartBarUpdate", "OneStartUpdate", "DBar", "DBarUpdate")

foreach ($registry_hive in Get-ChildItem registry::hkey_users) {
    $run_path = $registry_hive.PSPath + "\software\microsoft\windows\currentversion\run"
    if (Test-Path $run_path) {
        $reg_key = Get-Item $run_path
        foreach ($property in $reg_properties) {
            $prop_value = $reg_key.GetValueNames() | Where-Object { $_ -like $property }
            foreach ($prop in $prop_value) {
                Remove-ItemProperty -Path $run_path -Name $prop -ErrorAction SilentlyContinue
                Write-Output "$run_path\$prop registry property value has been removed."
            }
        }
    }
}

# Scheduled tasks to clean up (Old and New)
$schtasknames = @("OneStart Chromium", "OneStart Updater", "DBar Updater")

$removed_count = 0
foreach ($task in $schtasknames) {
    $clear_tasks = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($clear_tasks) {
        $removed_count++
        Unregister-ScheduledTask -TaskName $task -Confirm:$false
        Write-Output "Scheduled task '$task' has been removed."
    }
}

if ($removed_count -eq 0) {
    Write-Output "No related scheduled tasks were found."
}
