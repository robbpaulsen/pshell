$DestinationDrvrs = 'C:\Users\omar\Desktop\Scratch\drivers'
$DestinationCSV =  "C:\Users\omar\Desktop\Scratch\drivers\backup_drivers_list.csv"
$BackupDrv = Export-WindowsDriver -Online -Destination 
$Selections = 'Select-Object ClassName, ProviderName, Date, Version'

$BackupDrv $DestinationDrvrs | $Selections | Export-Csv $DestinationCSV -NoTypeInformation -Encoding UTF8