#Setup Variables
$emailto = "email@gmail.com"
$emailfrom = "email@gmail.com"
$SMTPServer = "smtp.gmail.com"
$SMTPssl = $True
$SMTPsslPort = "587"
$SMTPrequireLogin = $True
$SMTPlogin = "email-login@gmail.com"
$SMTPpass = "aywytpkgsdfpdcyg"


#Start Processing
$newline = "`r`n"
Do {
    $downcount = 0
    $down=$Null
    Write-Host (Get-Date)
    $hostlist = Get-Content ./hosts.txt | Where-Object {!($_ -match "#")}
    ForEach ($hostname in $hostlist) {
        if ($hostname.length -gt 0) {
            $hoststatus = Test-Connection -ComputerName $hostname -Count 1 -ea silentlycontinue
            if($hoststatus)  {  
                write-host "OK: "$hostname -BackgroundColor DarkGreen -ForegroundColor White
            } else  {
                write-host "DOWN: "$hostname -BackgroundColor DarkRed -ForegroundColor White
                $downcount = $downcount + 1
                [array]$down += $hostname
            }
        }
    }
    Write-Host "Down Hosts:"$downcount
    if ($downcount -ge 1 ) {    
        $Subject = "There are $downcount Host(s) down"
        $Body = "Down Hosts" + $newline + "-------------------------"
        Foreach ($item in $down) {
            $Body = $Body + $newline + $item
        }
        $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPsslPort)
        $SMTPClient.EnableSsl = $SMTPssl
        if ($SMTPrequireLogin) {
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPlogin,$SMTPpass)
        }
        $SMTPClient.Send($emailfrom,$emailto,$Subject,$Body)
        $downcount = 0
    }
    Write-host -NoNewline "Pausing "
    for ($s=0;$s -le 6; $s++) {
        Write-Host -NoNewline "."
        Start-Sleep 5
    }
    Write-Host ""
}
while ($true)