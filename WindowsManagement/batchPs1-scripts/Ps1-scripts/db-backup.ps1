# MySQL Database Backup Script for Windows and Linux

$databasename = 'MyDatabase'
$today = Get-Date -UFormat "%Y-%m-%d"
$backuppath = 'C:\Users\omar\Documents/backups'
#if ($IsLinux -eq $true) {
#    $backuppath = '/home/omar/Documents/backups'
#} else {
#    $backuppath = 'C:\Users\omar\Documents/backups'
#}

$backupfilename = $backuppath + $databasename + '-' + $today + '.sql'
$compressfilename = $backuppath + $databasename + '-' + $today + '.zip'
$errorlog = $backuppath + 'error.log'

mysqldump -u 'backup' -pBackup123 --log-error=$errorlog --result-file=$backupfilename --databases $databasename
Compress-Archive -Path $backupfilename -DestinationPath $compressfilename
Remove-Item -Path $backupfilename

Set-Location -Path $backuppath
$fileselect = $databasename + '*.zip'
$filelist = Get-ChildItem $fileselect | sort-object -Property name -Descending
$location = 0
foreach ($file in $filelist) {
    $location++
    if ($location -gt 7) {
        Remove-Item -Path $File.name
    }
}
# 
# $errorfile = Get-ChildItem  -Path $errorlog
# if ($errorfile[0].Length -eq 0) { 
#     $EmailText = 'Backup Successful'
# } else {
#     $EmailText = Get-Content -Path $errorlog
# }
# 
# 
# $SMTPServer     = "smtp host"
# $EmailFrom      = "from email" 
# $EmailTo        = "to email"
# $EmailSubject   = "DB Backup"
# $EMailSSL       = $false        # Use ssl for email, set email port
# $EMailPort      = 25            # Standard port is 25, SSL port typically 587
# $EMailAuth      = $false        # Email Server Requires login
# $emaillogin     = "login email"
# $emailpassword  = "login password"
# $Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
# $Message.Subject = $EmailSubject
# $Message.IsBodyHTML = $false
# $message.Body = $EmailText 
# $SMTP = New-Object Net.Mail.SmtpClient($SMTPServer, $EMailPort)
# if ($EMailSSL -eq $true) {
#     $SMTP.EnableSSL = $true
# }
# if ($EMailAuth -eq $true) {
#     $SMTP.Credentials = New-Object System.Net.NetworkCredential ($emaillogin, $emailpassword)
# }
# $SMTP.Send($Message)
# 
# git add .
# git commit -m 'add backup file'
# git push