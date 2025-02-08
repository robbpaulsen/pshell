$SourceDir="C:\Archivos de Programa\Microsoft SQL Server\MSSQL\DATA"
$BackUpLocation=Get-ChildItem -Path $BackUpLocationFilePath
$Destiny="C:\Users\Eugenio\BackUps"

robocopy $SourceDir $Destiny /e /w:5 /r:2 /COPY:DATSOU /DCOPY:DAT /MT