Write-Host "Loading Lotto File"
$lotto_file = Get-Content  ".\mmil.htm"
$start_find = 'face="helvetica">-</font'
$numlist = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
$megalist = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

Write-Host "Processing Lotto File"
for  ($i=0;$i -lt $lotto_file.Count;$i++) {
    if ($lotto_file[$i].Contains($start_find)) {
        Write-Host "." -NoNewline
        $i=$i-2
        for ($z=1;$z -lt 6;$z++) {
            $q = $lotto_file[$i].IndexOf('</font') -2 
            $num = $lotto_file[$i].Substring($q,2)
            if ($num.Substring(0,1) -eq '>') {
                $num = $num.Substring(1,1)
            }
            $numlist[$num]++
            $i=$i+4
        }
        $q = $lotto_file[$i].IndexOf('</font') -6
        $num = $lotto_file[$i].Substring($q,2)
        if ($num.Substring(0,1) -eq '>') {
            $num = $num.Substring(1,1)
        }
        $megalist[$num]++
     }    
}
Write-Host
Add-Type -AssemblyName System.Collections
$num1 = New-Object system.Data.DataTable
[void]$num1.Columns.Add('Ball')
[void]$num1.Columns.Add('Count')

for ($i=1;$i -le 70;$i++) {
    $newRow = $num1.NewRow()
    $newRow.Ball = $i
    $newRow.Count = $numlist[$i]
    $num1.Rows.Add($newRow)
}
$num1 | Export-Csv -Path numlist.csv

$mega1 = New-Object system.Data.DataTable
[void]$mega1.Columns.Add('Ball')
[void]$mega1.Columns.Add('Count')

for ($i=1;$i -le 25;$i++) {
    $newRow = $mega1.NewRow()
    $newRow.Ball = $i
    $newRow.Count = $megalist[$i]
    $mega1.Rows.Add($newRow)
}
$mega1 | Export-Csv -Path megalist.csv

Write-Host "Most Picked Numbers"
$pick = $num1 | Sort-Object -Property "Count" | Select-Object -Last 5
Write-Host $pick[0].Ball "-" $pick[1].Ball "-"$pick[2].Ball "-"$pick[3].Ball "-"$pick[4].Ball  -NoNewline
$pick = $mega1 | Sort-Object -Property "Count" 
Write-Host " MB" $pick[24].Ball
Write-Host "Least Picked Numbers"
$pick = $num1 | Sort-Object -Property "Count" | Select-Object -First 5
Write-Host $pick[0].Ball "-" $pick[1].Ball "-"$pick[2].Ball "-"$pick[3].Ball "-"$pick[4].Ball  -NoNewline
$pick = $mega1 | Sort-Object -Property "Count"  
Write-Host " MB" $pick[0].Ball
