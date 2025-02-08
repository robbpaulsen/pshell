$PartialName = Read-Host -Prompt "Ingresa un nombre parcial"
$vmlist = Get-VM | Where-Object name -Like *$PartialName*
foreach ($vm in $vmlist){
    $padded = ($vm.Name).PadRight(30)
    Write-Host $padded $vm.State
}