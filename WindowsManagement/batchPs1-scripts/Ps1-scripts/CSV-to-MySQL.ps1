# Startup
Set-Location -Path C:\Users\Caboz\Documents
#MySQL Connection
Import-Module MySQL
$dbpass = ConvertTo-SecureString -String 'password' -AsPlainText -Force
$dbuser = 'webuser'
$dbcred = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList $dbuser, $dbpass
Connect-MySqlServer -Credential $dbCred -ComputerName 'localhost' -Database 'test'


$includesfieldnames = $true
$createnewtable = $true
$createnewindex = $true
$fieldnameslist = "Name,Access,Login_DT,Group_NO"
$newtablename = "csvtest"
$csvfile = "datafile.csv"

$csvdata = Get-Content -Path $csvfile 

if ($createnewtable -eq $true) {
    $createtablesql = 'CREATE TABLE IF NOT EXISTS `'+$newtablename+'` ('
    if ($createnewindex -eq $true) {
       $createtablesql = $createtablesql + ' `idx` int(11) NOT NULL AUTO_INCREMENT,'
    }
    if ($includesfieldnames -eq $true) {
        $fieldnames = $csvdata[0].Split(',')
    } else {
        $fieldnames = $fieldnameslist.Split(',')
    }
    foreach ($field in $fieldnames) {
        $fieldtype = $field.Split('_')
        Switch ($fieldtype[1]) {
            "DT" { $createtablesql = $createtablesql + '`'+$field+'` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,' }
            "NO" { $createtablesql = $createtablesql + '`'+$field+'` int(11) NOT NULL,' }
            default { $createtablesql = $createtablesql + '`'+$field+'` char(50) NOT NULL,' }
        }
    }
    if ($createnewindex -eq $true) {
        $createtablesql = $createtablesql + 'PRIMARY KEY (`idx`)'
    }
    $createtablesql = $createtablesql + ') ENGINE=InnoDB DEFAULT CHARSET=latin1;'
    Invoke-MySqlQuery -Query $createtablesql
}
if ($includesfieldnames -eq $true) {$start=1} else {$start=0}
for ($i=$start;$i -le ($csvdata.Count-$start); $i++) {
    $insertsql = 'INSERT INTO `'+$newtablename+'` ('
    $fieldcount = $fieldnames.Count
    $commatrack = 1
    foreach ($field in $fieldnames) {
        $insertsql = $insertsql+$field
        $commatrack++
        if ($commatrack -le $fieldcount) {
            $insertsql = $insertsql+','
        }
    }
    $insertsql = $insertsql+') VALUES ('
    $commatrack = 1
    foreach ($itemrow in $csvdata[$i]) {
        $item = $itemrow.Split(',')
        foreach ($data in $item) {
            $insertsql = $insertsql+'"'+$data+'"'
            $commatrack++
            if ($commatrack -le $fieldcount) {
                $insertsql = $insertsql+','
            }
        }
    }
    $insertsql = $insertsql+')'
    Write-Host $insertsql
    Invoke-MySqlQuery -Query $insertsql
}


