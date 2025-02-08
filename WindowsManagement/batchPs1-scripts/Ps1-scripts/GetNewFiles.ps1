<#

GetNewFiles.ps1
@dwmetz, 19-july-2023
A simple script to find any new files on the file system for a specific filetype within x # of days

#>
Write-host " "
$script:filetype = Read-host -Prompt 'Enter the file type to look for (ex. txt, ps1, exe)'
$script:time = Read-host -Prompt 'How many days back do you want to look?'
$ErrorActionPreference = "SilentlyContinue"
Write-host " "
$NewFiles = Get-ChildItem -Path c:\ -Recurse  -Filter "*.$script:filetype" |
Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-$script:time) }
"Number of $script:filetype files found: $($NewFiles.Count)"
$NewFiles | Select-Object Fullname,CreationTime