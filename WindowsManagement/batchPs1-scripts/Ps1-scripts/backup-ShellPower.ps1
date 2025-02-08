Param(
    [parameter(Mandatory = $true)]
    [ValidateNotNullEmpty()]
    [string]$sourceFolder
)

# Get the name  of the Zip File
$ZipFileName = $sourceFolder + "\Backup\Backup_$(Get-Date -f dd-MM-YY).zip"

try
{
    # Create the backup directory if it doesent exists.
    $exists = Test-Path ($sourceFolder + "\Backup")
    if (-not $exists)
    {
        md ($sourceFolder + "\Backup")
    }
}