<# .DESCRIPTION Adds a Google Chrome extension to the forced install list. Can be used for forcing installation of any Google Chrome extension. Takes existing extensions into account which might be added by other means, such as GPO and MDM. #>
get-process -name *chrome* | stop-process -force

get-process -name *Google* | stop-process -force

$extensionId = "inomeogfingihgjfjlpeplalcfajhgai"
if(!($extensionId)){
    # Empty Extension
    $result = "No Extension ID"
}
else{
    Write-Information "ExtensionID = $extensionID"
    $regKey = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist"
    $regKeyInstall = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
    if(!(Test-Path $regKey)){
        New-Item $regKey -Force
        Write-Information "Created Reg Key $regKey"
    }
    # Remove Extension from Chrome
    $extensionsList = New-Object System.Collections.ArrayList
    $number = 0
    $noMore = 0
    do{
        $number++
        Write-Information "Pass : $number"
        try{
            $install = Get-ItemProperty $regKey -name $number -ErrorAction Stop
            $extensionObj = [PSCustomObject]@{
                Name = $number
                Value = $install.$number
            }
            $extensionsList.add($extensionObj) | Out-Null
            Write-Information "Extension List Item : $($extensionObj.name) / $($extensionObj.value)"
        }
        catch{
            $noMore = 1
        }
    }
    until($noMore -eq 1)
    $extensionCheck = $extensionsList | Where-Object {$_.Value -eq $extensionId}
    if($extensionCheck){
        $result = "Extension Already Blocked"
        Write-Information "Extension Already Blocked"
    }else{
        $newExtensionId = $extensionsList[-1].name + 1
        New-ItemProperty $regKey -PropertyType String -Name $newExtensionId -Value $extensionId
        $result = "Installed"
    }
    # Remove From Install List
    if (!(Test-Path $regKeyInstall)) {
        New-Item $regKeyInstall -Force
        Write-Information "Created Reg Key $regKeyInstall"
    }
    # Remove Extension from Chrome
    $extensionId = $extensionId, ";https://clients2.google.com/service/update2/crx" -join ""
    $extensionsInstallList = New-Object System.Collections.ArrayList
    $number = 0
    $noMore = 0
    do {
        $number++
        Write-Information "Pass : $number"
        try {
            $install = Get-ItemProperty $regKeyInstall -name $number -ErrorAction Stop
            $extensionObj = [PSCustomObject]@{
                Name  = $number
                Value = $install.$number
            }
            $extensionsInstallList.add($extensionObj) | Out-Null
            Write-Information "Extension List Item : $($extensionObj.name) / $($extensionObj.value)"
        }
        catch {
            $noMore = 1
        }
    }
    until($noMore -eq 1)
    $extensionCheck = $extensionsInstallList | Where-Object { $_.Value -eq $extensionId }
    if ($extensionCheck) {
        $result = "Extension Installed - Removing"
        Remove-ItemProperty $regKeyInstall -Name $extensionCheck.name -Force
    }
}
$result


# Remove program files directories for CRD
$directoryPaths = @(
    "C:\Program Files (x86)\Google\Chrome Remote Desktop",
    "C:\Program Files (x86)\Google\Update",
    "C:\Program Files (x86)\Google\temp"
)

foreach ($directoryPath in $directoryPaths) {
    Remove-Item -Path $directoryPath -Recurse -Force -Confirm:$false
}
$directoryPath1 = "C:\Program Files (x86)\Google\Update"
$directoryPath2 = "C:\Program Files (x86)\Google\temp"
Remove-Item -Path $directoryPath0 -Recurse -Force -confirm:$false
Remove-Item -Path $directoryPath1 -Recurse -Force -confirm:$false
Remove-Item -Path $directoryPath2 -Recurse -Force -confirm:$false

#Parse local app data for each user and remove Remote Desktop 
$userProfiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($profile in $userProfiles) {
    $chromeRemoteDesktopPath = Join-Path $profile.LocalPath "AppData\Local\Google\Chrome Remote Desktop"
    $desktopSharingHubPath = Join-Path $profile.LocalPath "AppData\Local\Google\Chrome\User Data\DesktopSharingHub"

    Remove-Item -Path $chromeRemoteDesktopPath -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $desktopSharingHubPath -Recurse -Force -ErrorAction SilentlyContinue
}
