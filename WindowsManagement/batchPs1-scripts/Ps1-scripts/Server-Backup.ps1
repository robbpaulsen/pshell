Install-WindowsFeature -Name Windows-Server-Backup -IncludeallSubfeature

$User = "Domain01\User01"
$PWord = ConvertTo-SecureString -String "P@sSwOrd" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$pol = New-WBPolicy
Add-WBSystemState -Policy $pol

$vol = GetWBVolume -AllVolumes
Add-WBVolume -Policy $pol -Volume $vol

$target = New-WBBackupTarget -NetworkPath \\host\backup -Credential $cred
Add-WBBackupTarget -Policy $pol -Target $target

Set-WBSchedule -Policy $pol -Schedule 01:00
Set-WBPolicy -Policy $pol

Start-WBBackup -Policy $pol