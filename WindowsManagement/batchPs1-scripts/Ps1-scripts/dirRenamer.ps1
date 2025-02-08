#region Test ...

#region Clean ...

#region Script

$path = Read-Host 'Enter new directory namei: '
Test-Path $path
If(Test-Path $path){
    Remove-Item $path
}
Test-Path

#endregion

#region Prereqs

[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

#endregion

#region basic form

#region insert text box