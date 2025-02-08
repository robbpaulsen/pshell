#MySQL Connection
Import-Module MySQL
$dbpass = ConvertTo-SecureString -String 'abcd1234' -AsPlainText -Force
$dbuser = 'admin'
$dbcred = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList $dbuser, $dbpass
Connect-MySqlServer -Credential $dbCred -ComputerName 'localhost' -Database 'MyData'