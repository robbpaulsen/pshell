Stop-Service SQLServer(COMPAQ)

$BackUpLocationFilePath="C:\Users\USER\Documents\PDFs"
#Archivos de Programa\Microsoft SQL Server\MSSQL\DATA"
$BackUpLocation=Get-ChildItem -Path $BackUpLocationFilePath

$StorageLocation="C:\Users\USER\BackUps"
$BackUpName="PDFs_Backup$(Get-Date -Format "yyyy-MM-dd")"

foreach($Location in $BackUpLocation){
    Write-Output "Respaldando $(Location)"
    if(-not (Test-Path "$StorageLocation\$BackUpName")){
        New-Item -Path "$StorageLocation\$BackUpName" -ItemType Directory
    }
    Get-ChildItem -Path $Location | Copy-Item -Destination "$StorageLocation\$BackUpName" -Container -Recurse
}