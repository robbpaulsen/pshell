<#
.SYNOPSIS
	Installs Windows Subsystem for Linux (needs admin rights)
.DESCRIPTION
	This PowerShell script installs Windows Subsystem for Linux. It needs admin rights.
	Original script from github user fleschutz, and modified script by Steven Judd and
	modified it a bit more
.EXAMPLE
	PS> ./install-wsl.ps1
.LINK
	https://gitlab.com/robbpaulsen/pshell
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

#Requires -RunAsAdministrator

# Check for admin rights
try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()
	if ( -not(
	(New-Object Security.Principal.WindowsPrincipal (
				[Security.Principal.WindowsIdentity]::GetCurrent())
	).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))) {
		Write-Warning '⚠️ Must be run as Administrator'
		return
	}

	$WindowsFeatureList = @(
	'Microsoft-Windows-Subsystem-Linux'
	'Virtual-Machine-Platform'
	)
	$InstallResult = Enable-WindowsOptionalFeature -Online -FeatureName $WindowsFeatureList -All -NoRestart
	if ($InstallResult.RestartNeeded) {
		Write-Host '✔️ Finished the Features Installation'
		Write-Host '👉 The Installation of $WindowsFeatureList requires a Reboot'
		$null = Read-Host '👉 Press Enter to reboot or Ctrl+c to cancel'
		Restart-Computer
	}

# On the fly fix for utf-16 issue per github pull 21219 "https://github.com/PowerShell/Pull/21219"
	$origEncoding = [Console]::OutputEncoding
	try {
		[Console]::OutputEncoding = [System.Text.Encoding]::Unicode
		$WslVersion = wsl --version
		$WslList = wsl --list
	}
	finally {
		[Console]::OutPutEncoding = $origEncoding
	}
#region steps 1 and 2

# Setup WSL version 2 as the default
	$WslMajorVersion = ($WslVersion | 
		Select-String -Pattern 'wsl version: (\d)').Matches.Groups.Where({ $_.Name -eq 1 }).Value
	Wait-Debugger
	if ($WslMajorVersion -ne 2) {
		wsl --update
		wsl --set-default-version 2
	}
#end region steps 1 and 2
	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✔️ installed Windows Subsystem for Linux (WSL) in $Elapsed sec"
	"  NOTE: reboot now, then visit the Microsoft Store and install a Linux distribution (e.g. Ubuntu, openSUSE, SUSE Linux, Kali Linux, Debian, Fedora, Pengwin, or Alpine)"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}