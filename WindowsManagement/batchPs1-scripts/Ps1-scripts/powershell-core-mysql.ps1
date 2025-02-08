add-type -Assembly /opt/microsoft/powershell/6/MySql.Data.dll
$constr = "server=127.0.0.1;port=3306;user id=webuser;password=asdf1234;database=demo;defaultcommandtimeout=30;connectiontimeout=15"
$con = New-Object MySql.Data.MySqlClient.MySqlConnection
$con.ConnectionString = $constr
$con.Open()
$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.CommandText = "Select * from userlist"
$cmd.Connection = $con
$cmd.Prepare()
$datalist = @()
$data = $cmd.ExecuteReader()
While ($data.Read() -eq $true) { 
    $tmparray = New-Object -TypeName psobject
    For ($i=0;$i -lt $data.FieldCount;$i++) { 
        $fldtype = $data.GetFieldType($i)
        Switch ($fldtype.Name) {
            "Int32" { $rawdata =$data.GetInt32($i); break }
            "String" { $rawdata=$data.GetString($i); break }
            default {
                $fldtype.Name
            }
        }
        Add-Member -InputObject $tmparray -MemberType 'NoteProperty' -Name $data.GetName($i) -Value $rawdata
    } 
    $datalist += $tmparray   
}
$con.close()
