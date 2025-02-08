$vmlist = @(("Server1","q","noencr"), `
	    ("Server2","q","noencr"))
#  Format is Servername , noq or q ,  encr or noencr    
$vcenter        = "vcenter.domain.com"
$backupto       = "E:\Backup\"
$complvl        = "5"
$SMTPServer     = "smtp.yourhost.com"
$EmailFrom      = "emailfrom@hostname.com" 
$EmailTo        = "sendto@hostname.com"
$EmailSubject   = "VM Backups"
$key            = "MyEncryptionKey"   # Your Unique Encryption Passkey
$deletebackup   = "In1Week"     # Possible Values: Never, Tonight, TomorrowNight, In3days, In1Week, 
                                #In2Weeks, In1Month, In3Months, In6Months, In1Year
$EMailSSL       = $false        # Use ssl for email, set email port
$EMailPort      = 25            # Standard port is 25, SSL port typically 587
$EMailAuth      = $false        # Email Server Requires login
$emaillogin     = "user@hostname.com"
$emailpassword  = "login password"

#Do not Change Code Below

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin VeeamPSSnapin
$EmailText = @()
foreach ($vmdata in $vmlist) {
    $VM = Find-VBRViEntity -Name $vmdata[0] -Server $vcenter
    $Quiesce=$true
    if ($vm[1] -eq "q") { $Quiesce=$false}
    If ($vmdata[2] -eq "encr") {
        $SecureKey = Get-VBREncryptionKey -Description $vmdata[0]
        if ($SecureKey.length -eq 0) {
            $keyss = ConvertTo-SecureString -String $key -AsPlainText -Force
            $SecureKey =  Add-VBREncryptionKey -Password $keyss -Description $vmdata[0]
        }
        $backup = Start-VBRZip -Entity $VM -Folder $backupto -Compression $complvl -DisableQuiesce:(!$Quiesce) `
                                 -AutoDelete $deletebackup -EncryptionKey $SecureKey
    } Else  {
        $backup = Start-VBRZip -Entity $VM -Folder $backupto -Compression $complvl `
                                 -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $deletebackup
    }
    $status = $backup.GetTaskSessions().logger.getlog().updatedrecords
    $failcheck =  $status | where-object {$_.status -eq "EWarning" -or $_.Status -eq "EFailed"}
    if ($failcheck -ne $null)  {
        $EmailText = $EmailText + ($backup | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={$failcheck.Title}})
    } Else {
        $EmailText = $EmailText + ($backup | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={($status | sort creationtime -Descending | select -first 1).Title}})
    }
}
$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$Message.Subject = $EmailSubject
$Message.IsBodyHTML = $True
$message.Body = $EmailText | ConvertTo-Html -head $style | Out-String
$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer, $EMailPort)
if ($EMailSSL -eq $true) {
    $SMTP.EnableSSL = $true
}
if ($EMailAuth -eq $true) {
    $SMTP.Credentials = New-Object System.Net.NetworkCredential ($emaillogin, $emailpassword)
}
$SMTP.Send($Message)