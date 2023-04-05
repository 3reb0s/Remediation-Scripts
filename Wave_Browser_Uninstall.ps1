#< 
A script to uninstall Wave Browser. This was based on scripts by freeload101 and xephora. 

This is designed to be deployed and executed automatically by an EDR platform or other endpoint management platform and does not write to users


#> 

#End tasks for uninstall
taskkill /F /IM chrome.exe  
taskkill /F /IM outlook.exe  
taskkill /F /IM IEXPLORE.EXE 
taskkill /F /IM msedge.exe  
taskkill /F /IM firefox.exe  
taskkill /F /IM swupdatercrashhandler64.exe   
taskkill /F /IM swupdatercrashhandler64.ex  
taskkill /F /IM wavebrowser.exe  

# Get and disable shcedualed task: 
Get-ScheduledTask -TaskName *Wavesor* | Disable-ScheduledTask


#Remove File Locations:
(Get-ChildItem -Path "c:\Users\*\Wavesor Software*"  -Depth 200  -Force -Recurse).Fullname |
ForEach-Object {

Remove-Item "$_" -Force -Recurse  -ErrorAction SilentlyContinue 
Remove-Item "$_" -Force -Recurse  -ErrorAction SilentlyContinue 
}


#Get and Remove Registry Keys
#Two common Paths here: 
Remove-Item -Path 'Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\TREE\Wave*' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "C:\windows\system32\tasks\Wavesor*" -Recurse -Confirm:$false -ErrorAction SilentlyContinue

#Enumerate sids and remove keys 

$sid_list = Get-Item -Path "Registry::HKU\*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+"
foreach ($i in $sid_list) {
    if ($i -notlike "*_Classes*") {
        $keyexists = test-path -path "Registry::$i\Software\WaveBrowser"
        if ($keyexists -eq $True) {
            Remove-Item -Path "Registry::$i\Software\WaveBrowser" -Recurse -ErrorAction SilentlyContinue
            $keyexists = test-path -path "Registry::$i\Software\WaveBrowser"
            
        }
        $keyexists = test-path -path "Registry::$i\Software\Wavesor"
        if ($keyexists -eq $True) {
            Remove-Item -Path "Registry::$i\Software\Wavesor" -Recurse -ErrorAction SilentlyContinue
            $keyexists = test-path -path "Registry::$i\Software\Wavesor"
           
        }
        $keyexists = test-path -path "Registry::$i\Software\WebNavigatorBrowser"
        if ($keyexists -eq $True) {
            Remove-Item -Path "Registry::$i\Software\WebNavigatorBrowser" -Recurse -ErrorAction SilentlyContinue
            $keyexists = test-path -path "Registry::$i\Software\WebNavigatorBrowser"
            
        }
        $keyexists = test-path -path "Registry::$i\Software\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser"
        if ($keyexists -eq $True) {
            Remove-Item -Path "Registry::$i\Software\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser" -Recurse -ErrorAction SilentlyContinue
            $keyexists = test-path -path "Registry::$i\Software\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser"
            
        }
        $keyexists = test-path -path "Registry::$i\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser"
        if ($keyexists -eq $True) {
            Remove-Item -Path "Registry::$i\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser" -Recurse -ErrorAction SilentlyContinue
            $keyexists = test-path -path "Registry::$i\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WaveBrowser"
            
        }
        $keypath = "Registry::$i\Software\Microsoft\Windows\CurrentVersion\Run"
        $keyexists = (Get-Item $keypath).Property -contains "Wavesor SWUpdater"
        if ($keyexists -eq $True) {
            Remove-ItemProperty -Path "Registry::$i\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Wavesor SWUpdater" -ErrorAction SilentlyContinue
            $keyexists = (Get-Item $keypath).Property -contains "Wavesor SWUpdater"
            
        }
    }
}

$sid_list = Get-Item -Path "Registry::HKU\*" | Select-String -Pattern "S-\d-(?:\d+-){5,14}\d+"
foreach ($i in $sid_list) {
    if ($i -like "*_Classes*") {
        remove-item "Registry::$i\WaveBrwsHTM*" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.CredentialDialogUser" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.CredentialDialogUser.1.0" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.OnDemandCOMClassUser" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.OnDemandCOMClassUser.1.0" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.PolicyStatusUser" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.PolicyStatusUser.1.0" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.Update3COMClassUser" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.Update3COMClassUser.1.0" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.Update3WebUser" -Recurse -ErrorAction SilentlyContinue
        remove-item "Registry::$i\WavesorSWUpdater.Update3WebUser.1.0" -Recurse -ErrorAction SilentlyContinue
    }
}


#Second Round Cleanup. This is designed to clearn up any remenants left over from the uninstall. 
#Remove Base Folder

Get-ChildItem -Recurse -Filter "Wavesor*" -Directory -ErrorAction SilentlyContinue -Path "C:\" | Remove-Item -Recurse -Force

#Remove From Taskbar 
Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\" -filter *wave* -Recurse | Remove-Item -Recurse -Force 

