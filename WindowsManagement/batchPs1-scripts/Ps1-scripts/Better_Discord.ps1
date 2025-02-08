Get-Process -Name Discord -ErrorAction Ignore | Stop-Process -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# https://github.com/BetterDiscord/BetterDiscord
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Windows.exe"
	OutFile         = "$DownloadsFolder\BetterDiscord-Windows.exe"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

Start-Process -FilePath "$DownloadsFolder\BetterDiscord-Windows.exe" -Wait
Remove-Item -Path "$DownloadsFolder\BetterDiscord-Windows.exe" -Force

# https://github.com/DiscordStyles/Fluent/blob/deploy/Fluent.theme.css
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/DiscordStyles/Fluent/deploy/Fluent.theme.css"
	OutFile         = "$env:APPDATA\BetterDiscord\themes\Fluent.theme.css"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

$Plugins = @(
	# https://github.com/rauenzi/BDPluginLibrary/blob/master/release/0PluginLibrary.plugin.js
	# Needed for YABDP4Nitro
	"https://raw.githubusercontent.com/rauenzi/BDPluginLibrary/master/release/0PluginLibrary.plugin.js",

	# https://github.com/riolubruh/YABDP4Nitro/blob/main/YABDP4Nitro.plugin.js
	"https://raw.githubusercontent.com/riolubruh/YABDP4Nitro/main/YABDP4Nitro.plugin.js"
)
foreach ($Plugin in $Plugins)
{
	$Parameters = @{
		Uri             = $Plugin
		OutFile         = "$env:APPDATA\BetterDiscord\plugins\$(Split-Path -Path $Plugin -Leaf)"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-Webrequest @Parameters
}
