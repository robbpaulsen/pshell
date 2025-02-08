$EventId = 1000,1006,1015,1116

$Alert = Get-WinEvent -MaxEvents 1  -FilterHashTable @{Logname = "Microsoft-Windows-Windows Defender/Operational" ; ID = $EventId}
$Message = $Alert.Message
$EventID = $Alart.Id
$MachineName = $Alert.MachineName
$Source = $Alert.ProviderName

$EmailFrom = "FROM_MAIL.utility@gmail.com"
$EmailTo = "TO_MAIL@gmail.com"
$Subject ="Alert From $MachineName"
$Body = "EventID: $EventID`nSource: $Source`nMachineName: $MachineName `nMessage: $Message"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo,$Subject ,$Body)
$SMTPServer = "smtp.gmail.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer , 587 )
$SMTPClient.EnableSSL = $true
$SMTPClient.Port = 587
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("FROM_MAIL@gmail.com", "PASSWORD")
$SMTPClient.Send($SMTPMessage)
