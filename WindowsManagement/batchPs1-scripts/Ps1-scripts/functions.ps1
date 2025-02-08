# Basic Functions in PowerShell

## STRUCTURE OF FUNCTIONS IN POWERSHELL

<#
function <function-name> {
    statements
}
#>

# Launch PowerShell as admin
function adm {
    Start-Process PowerShell -Verb RunAs
}

<#
function <function-name> {
   param ([type]$parameter1[,[type]$parameter2])
   <statement list>
}

function <function-name> [([type]$parameter1[,[type]$parameter2])] {
   <statement list>
}
#>

function Get-LFiles {
    param ($size)
    Get-ChildItem C:\Users\USER\Documents | 
    Where-Object {$_.Length -gt $size -and !$_.PSIsContainer} |
    Sort-Object -Descending
    Write-Host $size
}

function Get-LFiles2 ($size) {
    Get-ChildItem C:\Users\USER\Documents | 
    Where-Object {$_.Length -gt $size -and !$_.PSIsContainer} |
    Sort-Object -Descending
    Write-Host $size
}

function Get-LFiles3 {
    Get-ChildItem C:\Users\USER\Documents | 
    Where-Object {$_.Length -gt $args[0] -and !$_.PSIsContainer} |
    Sort-Object -Descending
    Write-Host $size
}

Function Get-Arguments {
    for ($i=0 ; $i -lt $args.length ; $i++) {
        Write-Host "$i) " $args[$i]
    }
}

Function Get-LFiles4 {
    param (
        #parameter(Mandatory=$true)
        [int] $Size=2000
    )
    Get-ChildItem C:\Users\USER\Documents | 
    Where-Object {$_.Length -gt $args[0] -and !$_.PSIsContainer} | Sort-Object -Descending
    Write-Host  $Size
}