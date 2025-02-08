$locarray = @("1000","2000","4000","5000","6000","7000")
foreach ($loc in $locarray) {

    Write-Host $loc " Start"

    $infile = "IN0"+$loc+".TXT"
    $lookup = "loc"+$loc+".csv"
    $outfile = "merged"+$loc+".csv"

    $invdata = import-csv $infile -Header "Location","Item","Quantity"
    $lookup = import-csv $lookup -Header "RGIS","MAIN"
    $tm = [System.Collections.ArrayList]@()
    $ticker = 0

    for ($i=0; $i -lt $invdata.Count; $i++) {
        $ticker++
        if ($ticker -gt 99) {
            Write-Host $i
            $ticker = 0
        }
        Write-host "." -NoNewline
        $newloc = ($lookup | Where-Object -FilterScript { $PSItem -match $invdata[$i].Location}).MAIN
        if ($newloc.length -gt 2) {
            $invdata[$i].Location = $newloc
            $tm += $invdata[$i]
        }
    } 

    $final = $tm | Select-Object Item, Location
    $final | export-csv $outfile 
    Write-Host $loc " Done"

}