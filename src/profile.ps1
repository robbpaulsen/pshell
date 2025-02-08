using namespace System.Management.Automation
using namespace System.Management.Automation.Language

if ($host.Name -eq 'ConsoleHost') {
	Import-Module PSReadLine
}

# 256 color terminal support
$env:TERM = "xterm-256color"

Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Profiles to import
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
}

# ===== Autocompletion script blocks =====
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# ===== Remember History =====
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | out-null
if (Test-path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }

# Import Modules and External Profiles
# Ensure Terminal-Icons module is installed before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# ===== Touch =====
function touch {
    Param(
          [Parameter(Mandatory = $true)]
          [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
      (Get-Item -Path $Path).LastWriteTime = Get-Date
    }
    else {
          New-Item -Type File -Path $Path
    }
}

# ===== Reload User Profile =====
function reload-profile {
	. $Profile.CurrentUserAllHosts
}

# ===== Uncompress Zip Archive Files =====

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

# ===== Which/Whence like function to verify if a command/cmdlet is installed =====
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

# ===== Export an item to the environment =====
function export($name, $value) {
    Set-Item -Force -Path "env:$name" -Value $value;
}

# ===== Stop a Process like with PKILL =====
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

# ===== Grep the name of a process =====
function pgrep($name) {
    Get-Process $name
}

# ===== Quick Access to System Information =====
function sysinfo {
    Get-ComputerInfo
}

# ===== Flush dns table =====
function flushdns {
    Clear-DnsClientCache
}

# ===== Launch PowerShell as admin inside a regular PowerShell Session =====
function adm {
    Start-Process PowerShell -Verb RunAs
}

# ===== Listing Functions =====
function ls {
	lsd
}

function la {
    lsd.exe -a
}

function ll {
    lsd.exe -ahl
}

function lstree {
    lsd.exe -a --tree
}

# ===== System wide file search for all powershell executables =====
function PSPShells {
    Get-Childitem –Path C:\ -Include powershell.exe, powershell_ise.exe, pwsh.exe -Recurse -ErrorAction SilentlyContinue -Force
}

# prevent config from overriding specified parameters
foreach ($param in $PSBoundParameters.Keys) {
    Set-Variable $param $PSBoundParameters[$param]
}

# ===== VARIABLES =====
$e = [char]0x1B
$ansiRegex = '([\u001B\u009B][[\]()#;?]*(?:(?:(?:[a-zA-Z\d]*(?:;[-a-zA-Z\d\/#&.:=?%@~_]*)*)?\u0007)|(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PR-TZcf-ntqry=><~])))'
$cimSession = New-CimSession
$os = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption,OSArchitecture,LastBootUpTime,TotalVisibleMemorySize,FreePhysicalMemory -CimSession $cimSession

# ===== Os Information =====
function info_os {
    return @{
        title   = "OS"
        content = "$($os.Caption.TrimStart('Microsoft ')) [$($os.OSArchitecture)]"
    }
}

# ===== MOTHERBOARD =====
function info_motherboard {
    $motherboard = Get-CimInstance Win32_BaseBoard -CimSession $cimSession -Property Manufacturer,Product
    return @{
        title = "Motherboard"
        content = "{0} {1}" -f $motherboard.Manufacturer, $motherboard.Product
    }
}

# ===== COMPUTER =====
function info_computer {
    $compsys = Get-CimInstance -ClassName Win32_ComputerSystem -Property Manufacturer,Model -CimSession $cimSession
    return @{
        title   = "Host"
        content = '{0} {1}' -f $compsys.Manufacturer, $compsys.Model
    }
}


# ===== KERNEL =====
function info_kernel {
    return @{
        title   = "Kernel"
        content = "$([System.Environment]::OSVersion.Version)"
    }
}


# ===== UPTIME =====
function info_uptime {
    @{
        title   = "Uptime"
        content = $(switch ([System.DateTime]::Now - $os.LastBootUpTime) {
            ({ $PSItem.Days -eq 1 }) { '1 day' }
            ({ $PSItem.Days -gt 1 }) { "$($PSItem.Days) days" }
            ({ $PSItem.Hours -eq 1 }) { '1 hour' }
            ({ $PSItem.Hours -gt 1 }) { "$($PSItem.Hours) hours" }
            ({ $PSItem.Minutes -eq 1 }) { '1 minute' }
            ({ $PSItem.Minutes -gt 1 }) { "$($PSItem.Minutes) minutes" }
        }) -join ' '
    }
}

# ===== RESOLUTION =====
function info_resolution {
    Add-Type -AssemblyName System.Windows.Forms
    $displays = foreach ($monitor in [System.Windows.Forms.Screen]::AllScreens) {
        "$($monitor.Bounds.Size.Width)x$($monitor.Bounds.Size.Height)"
    }

    return @{
        title   = "Resolution"
        content = $displays -join ', '
    }
}

# ===== CPU/GPU =====
function info_cpu {
    $cpu = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Env:COMPUTERNAME).OpenSubKey("HARDWARE\DESCRIPTION\System\CentralProcessor\0")
    $cpuname = $cpu.GetValue("ProcessorNameString")
    $cpuname = if ($cpuname.Contains('@')) {
        ($cpuname -Split '@')[0].Trim()
    } else {
        $cpuname.Trim()
    }
    return @{
        title   = "CPU"
        content = "$cpuname @ $($cpu.GetValue("~MHz") / 1000)GHz" # [math]::Round($cpu.GetValue("~MHz") / 1000, 1) is 2-5ms slower
    }
}

function info_gpu {
    [System.Collections.ArrayList]$lines = @()
    #loop through Win32_VideoController
    foreach ($gpu in Get-CimInstance -ClassName Win32_VideoController -Property Name -CimSession $cimSession) {
        [void]$lines.Add(@{
            title   = "GPU"
            content = $gpu.Name
        })
    }
    return $lines
}


# ===== CPU USAGE =====
function info_cpu_usage {
    # Get all running processes and assign to a variable to allow reuse
    $processes = [System.Diagnostics.Process]::GetProcesses()
    $loadpercent = 0
    $proccount = $processes.Count
    # Get the number of logical processors in the system
    $CPUs = [System.Environment]::ProcessorCount

    $timenow = [System.Datetime]::Now
    $processes.ForEach{
        if ($_.StartTime -gt 0) {
            # Replicate the functionality of New-Timespan
            $timespan = ($timenow.Subtract($_.StartTime)).TotalSeconds

            # Calculate the CPU usage of the process and add to the total
            $loadpercent += $_.CPU * 100 / $timespan / $CPUs
        }
    }

    return @{
        title   = "CPU Usage"
        content = get_level_info "" $cpustyle $loadpercent "$proccount processes" -altstyle
    }
}


# ===== MEMORY =====
function info_memory {
    $total = $os.TotalVisibleMemorySize / 1mb
    $used = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1mb
    $usage = [math]::floor(($used / $total * 100))
    return @{
        title   = "Memory"
        content = get_level_info "   " $memorystyle $usage "$($used.ToString("#.##")) GiB / $($total.ToString("#.##")) GiB"
    }
}


# ===== DISK USAGE =====
function info_disk {
    [System.Collections.ArrayList]$lines = @()

    function to_units($value) {
        if ($value -gt 1tb) {
            return "$([math]::round($value / 1tb, 1)) TiB"
        } else {
            return "$([math]::floor($value / 1gb)) GiB"
        }
    }

    [System.IO.DriveInfo]::GetDrives().ForEach{
        $diskLetter = $_.Name.SubString(0,2)

        if ($showDisks.Contains($diskLetter) -or $showDisks.Contains("*")) {
            try {
                if ($_.TotalSize -gt 0) {
                    $used = $_.TotalSize - $_.AvailableFreeSpace
                    $usage = [math]::Floor(($used / $_.TotalSize * 100))
    
                    [void]$lines.Add(@{
                        title   = "Disk ($diskLetter)"
                        content = get_level_info "" $diskstyle $usage "$(to_units $used) / $(to_units $_.TotalSize)"
                    })
                }
            } catch {
                [void]$lines.Add(@{
                    title   = "Disk ($diskLetter)"
                    content = "(failed to get disk usage)"
                })
            }
        }
    }

    return $lines
}

# ===== POWERSHELL VERSION =====
function info_pwsh {
    return @{
        title   = "Shell"
        content = "PowerShell v$($PSVersionTable.PSVersion)"
    }
}

# ===== PACKAGES =====
function info_pkgs {
    $pkgs = @()

    if ("winget" -in $ShowPkgs -and (Get-Command -Name winget -ErrorAction Ignore)) {
        $wingetpkg = (winget list | Where-Object {$_.Trim("`n`r`t`b-\|/ ").Length -ne 0} | Measure-Object).Count - 1

        if ($wingetpkg) {
            $pkgs += "$wingetpkg (system)"
        }
    }

    if ("choco" -in $ShowPkgs -and (Get-Command -Name choco -ErrorAction Ignore)) {
        $chocopkg = Invoke-Expression $(
            "(& choco list" + $(if([version](& choco --version).Split('-')[0]`
            -lt [version]'2.0.0'){" --local-only"}) + ")[-1].Split(' ')[0] - 1")

        if ($chocopkg) {
            $pkgs += "$chocopkg (choco)"
        }
    }

    if ("scoop" -in $ShowPkgs) {
        $scoopdir = if ($Env:SCOOP) { "$Env:SCOOP\apps" } else { "$Env:UserProfile\scoop\apps" }

        if (Test-Path $scoopdir) {
            $scooppkg = (Get-ChildItem -Path $scoopdir -Directory).Count - 1
        }

        if ($scooppkg) {
            $pkgs += "$scooppkg (scoop)"
        }
    }

    foreach ($pkgitem in $CustomPkgs) {
        if (Test-Path Function:"info_pkg_$pkgitem") {
            $count = & "info_pkg_$pkgitem"
            $pkgs += "$count ($pkgitem)"
        }
    }

    if (-not $pkgs) {
        $pkgs = "(none)"
    }

    return @{
        title   = "Packages"
        content = $pkgs -join ', '
    }
}


# ===== BATTERY =====
function info_battery {
    Add-Type -AssemblyName System.Windows.Forms
    $battery = [System.Windows.Forms.SystemInformation]::PowerStatus

    if ($battery.BatteryChargeStatus -eq 'NoSystemBattery') {
        return @{
            title = "Battery"
            content = "(none)"
        }
    }

    $status = if ($battery.BatteryChargeStatus -like '*Charging*') {
        "Charging"
    } elseif ($battery.PowerLineStatus -like '*Online*') {
        "Plugged in"
    } else {
        "Discharging"
    }

    $timeRemaining = $battery.BatteryLifeRemaining / 60
    # Don't show time remaining if Windows hasn't properly reported it yet
    $timeFormatted = if ($timeRemaining -ge 0) {
        $hours = [math]::floor($timeRemaining / 60)
        $minutes = [math]::floor($timeRemaining % 60)
        ", ${hours}h ${minutes}m"
    }

    return @{
        title = "Battery"
        content = get_level_info "  " $batterystyle "$([math]::round($battery.BatteryLifePercent * 100))" "$status$timeFormatted" -altstyle
    }
}

# ===== LOCALE =====
function info_locale {
    # Hashtables for language and region codes
    $localeLookup = @{
        "10" = "American Samoa";                             "100" = "Guinea";                            "10026358" = "Americas";                                                                                                                                            
        "10028789" = "Åland Islands";                        "10039880" = "Caribbean";                    "10039882" = "Northern Europe";                                                                                                                                            
        "10039883" = "Southern Africa";                      "101" = "Guyana";                            "10210824" = "Western Europe";                                                                                                                                            
        "10210825" = "Australia and New Zealand";            "103" = "Haiti";                             "104" = "Hong Kong SAR";                                                                                                                                            
        "10541" = "Europe";                                  "106" = "Honduras";                          "108" = "Croatia";                                                                                                                                            
        "109" = "Hungary";                                   "11" = "Argentina";                          "110" = "Iceland";                                                                                                                                            
        "111" = "Indonesia";                                 "113" = "India";                             "114" = "British Indian Ocean Territory";                                                                                                                                            
        "116" = "Iran";                                      "117" = "Israel";                            "118" = "Italy";                                                                                                                                            
        "119" = "Côte d'Ivoire";                             "12" = "Australia";                          "121" = "Iraq";                                                                                                                                            
        "122" = "Japan";                                     "124" = "Jamaica";                           "125" = "Jan Mayen";                                                                                                                                            
        "126" = "Jordan";                                    "127" = "Johnston Atoll";                    "129" = "Kenya";                                                                                                                                            
        "130" = "Kyrgyzstan";                                "131" = "North Korea";                       "133" = "Kiribati";                                                                                                                                            
        "134" = "Korea";                                     "136" = "Kuwait";                            "137" = "Kazakhstan";                                                                                                                                            
        "138" = "Laos";                                      "139" = "Lebanon";                           "14" = "Austria";                                                                                                                                            
        "140" = "Latvia";                                    "141" = "Lithuania";                         "142" = "Liberia";                                                                                                                                            
        "143" = "Slovakia";                                  "145" = "Liechtenstein";                     "146" = "Lesotho";                                                                                                                                            
        "147" = "Luxembourg";                                "148" = "Libya";                             "149" = "Madagascar";                                                                                                                                            
        "151" = "Macao SAR";                                 "15126" = "Isle of Man";                     "152" = "Moldova";                                                                                                                                            
        "154" = "Mongolia";                                  "156" = "Malawi";                            "157" = "Mali";                                                                                                                                            
        "158" = "Monaco";                                    "159" = "Morocco";                           "160" = "Mauritius";                                                                                                                                            
        "161832015" = "Saint Barthélemy";                    "161832256" = "U.S. Minor Outlying Islands"; "161832257" = "Latin America and the Caribbean";                                                                                                                                            
        "161832258" = "Bonaire, Sint Eustatius and Saba";    "162" = "Mauritania";                        "163" = "Malta";                                                                                                                                            
        "164" = "Oman";                                      "165" = "Maldives";                          "166" = "Mexico";                                                                                                                                            
        "167" = "Malaysia";                                  "168" = "Mozambique";                        "17" = "Bahrain";                                                                                                                                            
        "173" = "Niger";                                     "174" = "Vanuatu";                           "175" = "Nigeria";                                                                                                                                            
        "176" = "Netherlands";                               "177" = "Norway";                            "178" = "Nepal";                                                                                                                                            
        "18" = "Barbados";                                   "180" = "Nauru";                             "181" = "Suriname";                                                                                                                                            
        "182" = "Nicaragua";                                 "183" = "New Zealand";                       "184" = "Palestinian Authority";                                                                                                                                            
        "185" = "Paraguay";                                  "187" = "Peru";                              "19" = "Botswana";                                                                                                                                            
        "190" = "Pakistan";                                  "191" = "Poland";                            "192" = "Panama";                                                                                                                                            
        "193" = "Portugal";                                  "194" = "Papua New Guinea";                  "195" = "Palau";                                                                                                                                            
        "196" = "Guinea-Bissau";                             "19618" = "North Macedonia";                 "197" = "Qatar";                                                                                                                                            
        "198" = "Réunion";                                   "199" = "Marshall Islands";                  "2" = "Antigua and Barbuda";                                                                                                                                            
        "20" = "Bermuda";                                    "200" = "Romania";                           "201" = "Philippines";                                                                                                                                            
        "202" = "Puerto Rico";                               "203" = "Russia";                            "204" = "Rwanda";                                                                                                                                            
        "205" = "Saudi Arabia";                              "206" = "Saint Pierre and Miquelon";         "207" = "Saint Kitts and Nevis";                                                                                                                                            
        "208" = "Seychelles";                                "209" = "South Africa";                      "20900" = "Melanesia";                                                                                                                                            
        "21" = "Belgium";                                    "210" = "Senegal";                           "212" = "Slovenia";                                                                                                                                            
        "21206" = "Micronesia";                              "21242" = "Midway Islands";                  "2129" = "Asia";                                                                                                                                            
        "213" = "Sierra Leone";                              "214" = "San Marino";                        "215" = "Singapore";                                                                                                                                            
        "216" = "Somalia";                                   "217" = "Spain";                             "218" = "Saint Lucia";                                                                                                                                            
        "219" = "Sudan";                                     "22" = "Bahamas";                            "220" = "Svalbard";                                                                                                                                            
        "221" = "Sweden";                                    "222" = "Syria";                             "223" = "Switzerland";                                                                                                                                            
        "224" = "United Arab Emirates";                      "225" = "Trinidad and Tobago";               "227" = "Thailand";                                                                                                                                            
        "228" = "Tajikistan";                                "23" = "Bangladesh";                         "231" = "Tonga";                                                                                                                                            
        "232" = "Togo";                                      "233" = "São Tomé and Príncipe";             "234" = "Tunisia";                                                                                                                                            
        "235" = "Turkey";                                    "23581" = "Northern America";                "236" = "Tuvalu";                                                                                                                                            
        "237" = "Taiwan";                                    "238" = "Turkmenistan";                      "239" = "Tanzania";                                                                                                                                            
        "24" = "Belize";                                     "240" = "Uganda";                            "241" = "Ukraine";                                                                                                                                            
        "242" = "United Kingdom";                            "244" = "United States";                     "245" = "Burkina Faso";                                                                                                                                            
        "246" = "Uruguay";                                   "247" = "Uzbekistan";                        "248" = "Saint Vincent and the Grenadines";                                                                                                                                            
        "249" = "Venezuela";                                 "25" = "Bosnia and Herzegovina";             "251" = "Vietnam";                                                                                                                                            
        "252" = "U.S. Virgin Islands";                       "253" = "Vatican City";                      "254" = "Namibia";                                                                                                                                            
        "258" = "Wake Island";                               "259" = "Samoa";                             "26" = "Bolivia";                                                                                                                                            
        "260" = "Swaziland";                                 "261" = "Yemen";                             "26286" = "Polynesia";                                                                                                                                            
        "263" = "Zambia";                                    "264" = "Zimbabwe";                          "269" = "Serbia and Montenegro (Former)";                                                                                                                                            
        "27" = "Myanmar";                                    "270" = "Montenegro";                        "27082" = "Central America";                                                                                                                                            
        "271" = "Serbia";                                    "27114" = "Oceania";                         "273" = "Curaçao";                                                                                                                                            
        "276" = "South Sudan";                               "28" = "Benin";                              "29" = "Belarus";                                                                                                                                            
        "3" = "Afghanistan";                                 "30" = "Solomon Islands";                    "300" = "Anguilla";                                                                                                                                            
        "301" = "Antarctica";                                "302" = "Aruba";                             "303" = "Ascension Island";                                                                                                                                            
        "304" = "Ashmore and Cartier Islands";               "305" = "Baker Island";                      "306" = "Bouvet Island";                                                                                                                                            
        "307" = "Cayman Islands";                            "308" = "Channel Islands";                   "309" = "Christmas Island";                                                                                                                                            
        "30967" = "Sint Maarten";                            "310" = "Clipperton Island";                 "311" = "Cocos (Keeling) Islands";                                                                                                                                            
        "312" = "Cook Islands";                              "313" = "Coral Sea Islands";                 "31396" = "South America";                                                                                                                                            
        "314" = "Diego Garcia";                              "315" = "Falkland Islands";                  "317" = "French Guiana";                                                                                                                                            
        "31706" = "Saint Martin";                            "318" = "French Polynesia";                  "319" = "French Southern Territories";                                                                                                                                            
        "32" = "Brazil";                                     "321" = "Guadeloupe";                        "322" = "Guam";                                                                                                                                            
        "323" = "Guantanamo Bay";                            "324" = "Guernsey";                          "325" = "Heard Island and McDonald Islands";                                                                                                                                            
        "326" = "Howland Island";                            "327" = "Jarvis Island";                     "328" = "Jersey";                                                                                                                                            
        "329" = "Kingman Reef";                              "330" = "Martinique";                        "331" = "Mayotte";                                                                                                                                            
        "332" = "Montserrat";                                "333" = "Netherlands Antilles (Former)";     "334" = "New Caledonia";                                                                                                                                            
        "335" = "Niue";                                      "336" = "Norfolk Island";                    "337" = "Northern Mariana Islands";                                                                                                                                            
        "338" = "Palmyra Atoll";                             "339" = "Pitcairn Islands";                  "34" = "Bhutan";                                                                                                                                            
        "340" = "Rota Island";                               "341" = "Saipan";                            "342" = "South Georgia and the South Sandwich Islands";                                                                                                                                            
        "343" = "St Helena, Ascension and Tristan da Cunha"; "346" = "Tinian Island";                     "347" = "Tokelau";                                                                                                                                            
        "348" = "Tristan da Cunha";                          "349" = "Turks and Caicos Islands";          "35" = "Bulgaria";                                                                                                                                            
        "351" = "British Virgin Islands";                    "352" = "Wallis and Futuna";                 "37" = "Brunei";                                                                                                                                            
        "38" = "Burundi";                                    "39" = "Canada";                             "39070" = "World";                                                                                                                                            
        "4" = "Algeria";                                     "40" = "Cambodia";                           "41" = "Chad";                                                                                                                                            
        "42" = "Sri Lanka";                                  "42483" = "Western Africa";                  "42484" = "Middle Africa";                                                                                                                                            
        "42487" = "Northern Africa";                         "43" = "Congo";                              "44" = "Congo (DRC)";                                                                                                                                            
        "45" = "China";                                      "46" = "Chile";                              "47590" = "Central Asia";                                                                                                                                            
        "47599" = "South-Eastern Asia";                      "47600" = "Eastern Asia";                    "47603" = "Eastern Africa";                                                                                                                                            
        "47609" = "Eastern Europe";                          "47610" = "Southern Europe";                 "47611" = "Middle East";                                                                                                                                            
        "47614" = "Southern Asia";                           "49" = "Cameroon";                           "5" = "Azerbaijan";                                                                                                                                            
        "50" = "Comoros";                                    "51" = "Colombia";                           "54" = "Costa Rica";                                                                                                                                            
        "55" = "Central African Republic";                   "56" = "Cuba";                               "57" = "Cabo Verde";                                                                                                                                            
        "59" = "Cyprus";                                     "6" = "Albania";                             "61" = "Denmark";                                                                                                                                            
        "62" = "Djibouti";                                   "63" = "Dominica";                           "65" = "Dominican Republic";                                                                                                                                            
        "66" = "Ecuador";                                    "67" = "Egypt";                              "68" = "Ireland";                                                                                                                                            
        "69" = "Equatorial Guinea";                          "7" = "Armenia";                             "70" = "Estonia";                                                                                                                                            
        "71" = "Eritrea";                                    "72" = "El Salvador";                        "7299303" = "Timor-Leste";                                                                                                                                            
        "73" = "Ethiopia";                                   "742" = "Africa";                            "75" = "Czech Republic";                                                                                                                                            
        "77" = "Finland";                                    "78" = "Fiji";                               "8" = "Andorra";                                                                                                                                            
        "80" = "Micronesia";                                 "81" = "Faroe Islands";                      "84" = "France";                                                                                                                                            
        "86" = "Gambia";                                     "87" = "Gabon";                              "88" = "Georgia";                                                                                                                                            
        "89" = "Ghana";                                      "9" = "Angola";                              "90" = "Gibraltar";                                                                                                                                            
        "91" = "Grenada";                                    "93" = "Greenland";                          "94" = "Germany";                                                                                                                                            
        "98" = "Greece";                                     "99" = "Guatemala";                          "9914689" = "Kosovo";                                                                                                                                            
    }
    $languageLookup = @{
        "aa" = "Afar";                                                "aa-DJ" = "Afar (Djibouti)";                                       "aa-ER" = "Afar (Eritrea)";                                                                                                                                            
        "aa-ET" = "Afar (Ethiopia)";                                  "af" = "Afrikaans";                                                "af-NA" = "Afrikaans (Namibia)";                                                                                                                                            
        "af-ZA" = "Afrikaans (South Africa)";                         "agq" = "Aghem";                                                   "agq-CM" = "Aghem (Cameroon)";                                                                                                                                            
        "ak" = "Akan";                                                "ak-GH" = "Akan (Ghana)";                                          "am" = "Amharic";                                                                                                                                            
        "am-ET" = "Amharic (Ethiopia)";                               "ar" = "Arabic";                                                   "ar-001" = "Arabic (World)";                                                                                                                                            
        "ar-AE" = "Arabic (U.A.E.)";                                  "ar-BH" = "Arabic (Bahrain)";                                      "ar-DJ" = "Arabic (Djibouti)";                                                                                                                                            
        "ar-DZ" = "Arabic (Algeria)";                                 "ar-EG" = "Arabic (Egypt)";                                        "ar-ER" = "Arabic (Eritrea)";                                                                                                                                            
        "ar-IL" = "Arabic (Israel)";                                  "ar-IQ" = "Arabic (Iraq)";                                         "ar-JO" = "Arabic (Jordan)";                                                                                                                                            
        "ar-KM" = "Arabic (Comoros)";                                 "ar-KW" = "Arabic (Kuwait)";                                       "ar-LB" = "Arabic (Lebanon)";                                                                                                                                            
        "ar-LY" = "Arabic (Libya)";                                   "ar-MA" = "Arabic (Morocco)";                                      "ar-MR" = "Arabic (Mauritania)";                                                                                                                                            
        "ar-OM" = "Arabic (Oman)";                                    "ar-PS" = "Arabic (Palestinian Authority)";                        "ar-QA" = "Arabic (Qatar)";                                                                                                                                            
        "ar-SA" = "Arabic (Saudi Arabia)";                            "ar-SD" = "Arabic (Sudan)";                                        "ar-SO" = "Arabic (Somalia)";                                                                                                                                            
        "ar-SS" = "Arabic (South Sudan)";                             "ar-SY" = "Arabic (Syria)";                                        "ar-TD" = "Arabic (Chad)";                                                                                                                                            
        "ar-TN" = "Arabic (Tunisia)";                                 "ar-YE" = "Arabic (Yemen)";                                        "arn" = "Mapudungun";                                                                                                                                            
        "arn-CL" = "Mapudungun (Chile)";                              "as" = "Assamese";                                                 "as-IN" = "Assamese (India)";                                                                                                                                            
        "asa" = "Asu";                                                "asa-TZ" = "Asu (Tanzania)";                                       "ast" = "Asturian";                                                                                                                                            
        "ast-ES" = "Asturian (Spain)";                                "az" = "Azerbaijani";                                              "az-Cyrl" = "Azerbaijani (Cyrillic)";                                                                                                                                            
        "az-Cyrl-AZ" = "Azerbaijani (Cyrillic, Azerbaijan)";          "az-Latn" = "Azerbaijani (Latin)";                                 "az-Latn-AZ" = "Azerbaijani (Latin, Azerbaijan)";                                                                                                                                            
        "ba" = "Bashkir";                                             "ba-RU" = "Bashkir (Russia)";                                      "bas" = "Basaa";                                                                                                                                            
        "bas-CM" = "Basaa (Cameroon)";                                "be" = "Belarusian";                                               "be-BY" = "Belarusian (Belarus)";                                                                                                                                            
        "bem" = "Bemba";                                              "bem-ZM" = "Bemba (Zambia)";                                       "bez" = "Bena";                                                                                                                                            
        "bez-TZ" = "Bena (Tanzania)";                                 "bg" = "Bulgarian";                                                "bg-BG" = "Bulgarian (Bulgaria)";                                                                                                                                            
        "bin" = "Edo";                                                "bin-NG" = "Edo (Nigeria)";                                        "bm" = "Bambara";                                                                                                                                            
        "bm-Latn" = "Bambara (Latin)";                                "bm-Latn-ML" = "Bambara (Latin, Mali)";                            "bn" = "Bangla";                                                                                                                                            
        "bn-BD" = "Bangla (Bangladesh)";                              "bn-IN" = "Bangla (India)";                                        "bo" = "Tibetan";                                                                                                                                            
        "bo-CN" = "Tibetan (PRC)";                                    "bo-IN" = "Tibetan (India)";                                       "br" = "Breton";                                                                                                                                            
        "br-FR" = "Breton (France)";                                  "brx" = "Bodo";                                                    "brx-IN" = "Bodo (India)";                                                                                                                                            
        "bs" = "Bosnian";                                             "bs-Cyrl" = "Bosnian (Cyrillic)";                                  "bs-Cyrl-BA" = "Bosnian (Cyrillic, Bosnia and Herzegovina)";                                                                                                                                            
        "bs-Latn" = "Bosnian (Latin)";                                "bs-Latn-BA" = "Bosnian (Latin, Bosnia and Herzegovina)";          "byn" = "Blin";                                                                                                                                            
        "byn-ER" = "Blin (Eritrea)";                                  "ca" = "Catalan";                                                  "ca-AD" = "Catalan (Andorra)";                                                                                                                                            
        "ca-ES" = "Catalan (Catalan)";                                "ca-ES-valencia" = "Valencian (Spain)";                            "ca-FR" = "Catalan (France)";                                                                                                                                            
        "ca-IT" = "Catalan (Italy)";                                  "ce" = "Chechen";                                                  "ce-RU" = "Chechen (Russia)";                                                                                                                                            
        "cgg" = "Chiga";                                              "cgg-UG" = "Chiga (Uganda)";                                       "chr" = "Cherokee";                                                                                                                                            
        "chr-Cher" = "Cherokee (Cherokee)";                           "chr-Cher-US" = "Cherokee (Cherokee)";                             "co" = "Corsican";                                                                                                                                            
        "co-FR" = "Corsican (France)";                                "cs" = "Czech";                                                    "cs-CZ" = "Czech (Czechia / Czech Republic)";                                                                                                                                            
        "cu" = "Church Slavic";                                       "cu-RU" = "Church Slavic (Russia)";                                "cy" = "Welsh";                                                                                                                                            
        "cy-GB" = "Welsh (United Kingdom)";                           "da" = "Danish";                                                   "da-DK" = "Danish (Denmark)";                                                                                                                                            
        "da-GL" = "Danish (Greenland)";                               "dav" = "Taita";                                                   "dav-KE" = "Taita (Kenya)";                                                                                                                                            
        "de" = "German";                                              "de-AT" = "German (Austria)";                                      "de-BE" = "German (Belgium)";                                                                                                                                            
        "de-CH" = "German (Switzerland)";                             "de-DE" = "German (Germany)";                                      "de-IT" = "German (Italy)";                                                                                                                                            
        "de-LI" = "German (Liechtenstein)";                           "de-LU" = "German (Luxembourg)";                                   "dje" = "Zarma";                                                                                                                                            
        "dje-NE" = "Zarma (Niger)";                                   "dsb" = "Lower Sorbian";                                           "dsb-DE" = "Lower Sorbian (Germany)";                                                                                                                                            
        "dua" = "Duala";                                              "dua-CM" = "Duala (Cameroon)";                                     "dv" = "Divehi";                                                                                                                                            
        "dv-MV" = "Divehi (Maldives)";                                "dyo" = "Jola-Fonyi";                                              "dyo-SN" = "Jola-Fonyi (Senegal)";                                                                                                                                            
        "dz" = "Dzongkha";                                            "dz-BT" = "Dzongkha (Bhutan)";                                     "ebu" = "Embu";                                                                                                                                            
        "ebu-KE" = "Embu (Kenya)";                                    "ee" = "Ewe";                                                      "ee-GH" = "Ewe (Ghana)";                                                                                                                                            
        "ee-TG" = "Ewe (Togo)";                                       "el" = "Greek";                                                    "el-CY" = "Greek (Cyprus)";                                                                                                                                            
        "el-GR" = "Greek (Greece)";                                   "en" = "English";                                                  "en-001" = "English (World)";                                                                                                                                            
        "en-029" = "English (Caribbean)";                             "en-150" = "English (Europe)";                                     "en-AG" = "English (Antigua and Barbuda)";                                                                                                                                            
        "en-AI" = "English (Anguilla)";                               "en-AS" = "English (American Samoa)";                              "en-AT" = "English (Austria)";                                                                                                                                            
        "en-AU" = "English (Australia)";                              "en-BB" = "English (Barbados)";                                    "en-BE" = "English (Belgium)";                                                                                                                                            
        "en-BI" = "English (Burundi)";                                "en-BM" = "English (Bermuda)";                                     "en-BS" = "English (Bahamas)";                                                                                                                                            
        "en-BW" = "English (Botswana)";                               "en-BZ" = "English (Belize)";                                      "en-CA" = "English (Canada)";                                                                                                                                            
        "en-CC" = "English (Cocos [Keeling] Islands)";                "en-CH" = "English (Switzerland)";                                 "en-CK" = "English (Cook Islands)";                                                                                                                                            
        "en-CM" = "English (Cameroon)";                               "en-CX" = "English (Christmas Island)";                            "en-CY" = "English (Cyprus)";                                                                                                                                            
        "en-DE" = "English (Germany)";                                "en-DK" = "English (Denmark)";                                     "en-DM" = "English (Dominica)";                                                                                                                                            
        "en-ER" = "English (Eritrea)";                                "en-FI" = "English (Finland)";                                     "en-FJ" = "English (Fiji)";                                                                                                                                            
        "en-FK" = "English (Falkland Islands)";                       "en-FM" = "English (Micronesia)";                                  "en-GB" = "English (United Kingdom)";                                                                                                                                            
        "en-GD" = "English (Grenada)";                                "en-GG" = "English (Guernsey)";                                    "en-GH" = "English (Ghana)";                                                                                                                                            
        "en-GI" = "English (Gibraltar)";                              "en-GM" = "English (Gambia)";                                      "en-GU" = "English (Guam)";                                                                                                                                            
        "en-GY" = "English (Guyana)";                                 "en-HK" = "English (Hong Kong SAR)";                               "en-ID" = "English (Indonesia)";                                                                                                                                            
        "en-IE" = "English (Ireland)";                                "en-IL" = "English (Israel)";                                      "en-IM" = "English (Isle of Man)";                                                                                                                                            
        "en-IN" = "English (India)";                                  "en-IO" = "English (British Indian Ocean Territory)";              "en-JE" = "English (Jersey)";                                                                                                                                            
        "en-JM" = "English (Jamaica)";                                "en-KE" = "English (Kenya)";                                       "en-KI" = "English (Kiribati)";                                                                                                                                            
        "en-KN" = "English (Saint Kitts and Nevis)";                  "en-KY" = "English (Cayman Islands)";                              "en-LC" = "English (Saint Lucia)";                                                                                                                                            
        "en-LR" = "English (Liberia)";                                "en-LS" = "English (Lesotho)";                                     "en-MG" = "English (Madagascar)";                                                                                                                                            
        "en-MH" = "English (Marshall Islands)";                       "en-MO" = "English (Macao SAR)";                                   "en-MP" = "English (Northern Mariana Islands)";                                                                                                                                            
        "en-MS" = "English (Montserrat)";                             "en-MT" = "English (Malta)";                                       "en-MU" = "English (Mauritius)";                                                                                                                                            
        "en-MW" = "English (Malawi)";                                 "en-MY" = "English (Malaysia)";                                    "en-NA" = "English (Namibia)";                                                                                                                                            
        "en-NF" = "English (Norfolk Island)";                         "en-NG" = "English (Nigeria)";                                     "en-NL" = "English (Netherlands)";                                                                                                                                            
        "en-NR" = "English (Nauru)";                                  "en-NU" = "English (Niue)";                                        "en-NZ" = "English (New Zealand)";                                                                                                                                            
        "en-PG" = "English (Papua New Guinea)";                       "en-PH" = "English (Philippines)";                                 "en-PK" = "English (Pakistan)";                                                                                                                                            
        "en-PN" = "English (Pitcairn Islands)";                       "en-PR" = "English (Puerto Rico)";                                 "en-PW" = "English (Palau)";                                                                                                                                            
        "en-RW" = "English (Rwanda)";                                 "en-SB" = "English (Solomon Islands)";                             "en-SC" = "English (Seychelles)";                                                                                                                                            
        "en-SD" = "English (Sudan)";                                  "en-SE" = "English (Sweden)";                                      "en-SG" = "English (Singapore)";                                                                                                                                            
        "en-SH" = "English (St Helena, Ascension, Tristan da Cunha)"; "en-SI" = "English (Slovenia)";                                    "en-SL" = "English (Sierra Leone)";                                                                                                                                            
        "en-SS" = "English (South Sudan)";                            "en-SX" = "English (Sint Maarten)";                                "en-SZ" = "English (Swaziland)";                                                                                                                                            
        "en-TC" = "English (Turks and Caicos Islands)";               "en-TK" = "English (Tokelau)";                                     "en-TO" = "English (Tonga)";                                                                                                                                            
        "en-TT" = "English (Trinidad and Tobago)";                    "en-TV" = "English (Tuvalu)";                                      "en-TZ" = "English (Tanzania)";                                                                                                                                            
        "en-UG" = "English (Uganda)";                                 "en-UM" = "English (US Minor Outlying Islands)";                   "en-US" = "English (United States)";                                                                                                                                            
        "en-VC" = "English (Saint Vincent and the Grenadines)";       "en-VG" = "English (British Virgin Islands)";                      "en-VI" = "English (US Virgin Islands)";                                                                                                                                            
        "en-VU" = "English (Vanuatu)";                                "en-WS" = "English (Samoa)";                                       "en-ZA" = "English (South Africa)";                                                                                                                                            
        "en-ZM" = "English (Zambia)";                                 "en-ZW" = "English (Zimbabwe)";                                    "eo" = "Esperanto";                                                                                                                                            
        "eo-001" = "Esperanto (World)";                               "es" = "Spanish";                                                  "es-419" = "Spanish (Latin America)";                                                                                                                                            
        "es-AR" = "Spanish (Argentina)";                              "es-BO" = "Spanish (Bolivia)";                                     "es-BR" = "Spanish (Brazil)";                                                                                                                                            
        "es-BZ" = "Spanish (Belize)";                                 "es-CL" = "Spanish (Chile)";                                       "es-CO" = "Spanish (Colombia)";                                                                                                                                            
        "es-CR" = "Spanish (Costa Rica)";                             "es-CU" = "Spanish (Cuba)";                                        "es-DO" = "Spanish (Dominican Republic)";                                                                                                                                            
        "es-EC" = "Spanish (Ecuador)";                                "es-ES" = "Spanish (Spain)";                                       "es-GQ" = "Spanish (Equatorial Guinea)";                                                                                                                                            
        "es-GT" = "Spanish (Guatemala)";                              "es-HN" = "Spanish (Honduras)";                                    "es-MX" = "Spanish (Mexico)";                                                                                                                                            
        "es-NI" = "Spanish (Nicaragua)";                              "es-PA" = "Spanish (Panama)";                                      "es-PE" = "Spanish (Peru)";                                                                                                                                            
        "es-PH" = "Spanish (Philippines)";                            "es-PR" = "Spanish (Puerto Rico)";                                 "es-PY" = "Spanish (Paraguay)";                                                                                                                                            
        "es-SV" = "Spanish (El Salvador)";                            "es-US" = "Spanish (United States)";                               "es-UY" = "Spanish (Uruguay)";                                                                                                                                            
        "es-VE" = "Spanish (Venezuela)";                              "et" = "Estonian";                                                 "et-EE" = "Estonian (Estonia)";                                                                                                                                            
        "eu" = "Basque";                                              "eu-ES" = "Basque (Basque)";                                       "ewo" = "Ewondo";                                                                                                                                            
        "ewo-CM" = "Ewondo (Cameroon)";                               "fa" = "Persian";                                                  "fa-IR" = "Persian (Iran)";                                                                                                                                            
        "ff" = "Fulah";                                               "ff-CM" = "Fulah (Cameroon)";                                      "ff-GN" = "Fulah (Guinea)";                                                                                                                                            
        "ff-Latn" = "Fulah (Latin)";                                  "ff-Latn-SN" = "Fulah (Latin, Senegal)";                           "ff-MR" = "Fulah (Mauritania)";                                                                                                                                            
        "ff-NG" = "Fulah (Nigeria)";                                  "fi" = "Finnish";                                                  "fi-FI" = "Finnish (Finland)";                                                                                                                                            
        "fil" = "Filipino";                                           "fil-PH" = "Filipino (Philippines)";                               "fo" = "Faroese";                                                                                                                                            
        "fo-DK" = "Faroese (Denmark)";                                "fo-FO" = "Faroese (Faroe Islands)";                               "fr" = "French";                                                                                                                                            
        "fr-029" = "French (Caribbean)";                              "fr-BE" = "French (Belgium)";                                      "fr-BF" = "French (Burkina Faso)";                                                                                                                                            
        "fr-BI" = "French (Burundi)";                                 "fr-BJ" = "French (Benin)";                                        "fr-BL" = "French (Saint Barthélemy)";                                                                                                                                            
        "fr-CA" = "French (Canada)";                                  "fr-CD" = "French (Congo DRC)";                                    "fr-CF" = "French (Central African Republic)";                                                                                                                                            
        "fr-CG" = "French (Congo)";                                   "fr-CH" = "French (Switzerland)";                                  "fr-CI" = "French (Côte d’Ivoire)";                                                                                                                                            
        "fr-CM" = "French (Cameroon)";                                "fr-DJ" = "French (Djibouti)";                                     "fr-DZ" = "French (Algeria)";                                                                                                                                            
        "fr-FR" = "French (France)";                                  "fr-GA" = "French (Gabon)";                                        "fr-GF" = "French (French Guiana)";                                                                                                                                            
        "fr-GN" = "French (Guinea)";                                  "fr-GP" = "French (Guadeloupe)";                                   "fr-GQ" = "French (Equatorial Guinea)";                                                                                                                                            
        "fr-HT" = "French (Haiti)";                                   "fr-KM" = "French (Comoros)";                                      "fr-LU" = "French (Luxembourg)";                                                                                                                                            
        "fr-MA" = "French (Morocco)";                                 "fr-MC" = "French (Monaco)";                                       "fr-MF" = "French (Saint Martin)";                                                                                                                                            
        "fr-MG" = "French (Madagascar)";                              "fr-ML" = "French (Mali)";                                         "fr-MQ" = "French (Martinique)";                                                                                                                                            
        "fr-MR" = "French (Mauritania)";                              "fr-MU" = "French (Mauritius)";                                    "fr-NC" = "French (New Caledonia)";                                                                                                                                            
        "fr-NE" = "French (Niger)";                                   "fr-PF" = "French (French Polynesia)";                             "fr-PM" = "French (Saint Pierre and Miquelon)";                                                                                                                                            
        "fr-RE" = "French (Reunion)";                                 "fr-RW" = "French (Rwanda)";                                       "fr-SC" = "French (Seychelles)";                                                                                                                                            
        "fr-SN" = "French (Senegal)";                                 "fr-SY" = "French (Syria)";                                        "fr-TD" = "French (Chad)";                                                                                                                                            
        "fr-TG" = "French (Togo)";                                    "fr-TN" = "French (Tunisia)";                                      "fr-VU" = "French (Vanuatu)";                                                                                                                                            
        "fr-WF" = "French (Wallis and Futuna)";                       "fr-YT" = "French (Mayotte)";                                      "fur" = "Friulian";                                                                                                                                            
        "fur-IT" = "Friulian (Italy)";                                "fy" = "Frisian";                                                  "fy-NL" = "Frisian (Netherlands)";                                                                                                                                            
        "ga" = "Irish";                                               "ga-IE" = "Irish (Ireland)";                                       "gd" = "Scottish Gaelic";                                                                                                                                            
        "gd-GB" = "Scottish Gaelic (United Kingdom)";                 "gl" = "Galician";                                                 "gl-ES" = "Galician (Galician)";                                                                                                                                            
        "gn" = "Guarani";                                             "gn-PY" = "Guarani (Paraguay)";                                    "gsw" = "Alsatian";                                                                                                                                            
        "gsw-CH" = "Alsatian (Switzerland)";                          "gsw-FR" = "Alsatian (France)";                                    "gsw-LI" = "Alsatian (Liechtenstein)";                                                                                                                                            
        "gu" = "Gujarati";                                            "gu-IN" = "Gujarati (India)";                                      "guz" = "Gusii";                                                                                                                                            
        "guz-KE" = "Gusii (Kenya)";                                   "gv" = "Manx";                                                     "gv-IM" = "Manx (Isle of Man)";                                                                                                                                            
        "ha" = "Hausa";                                               "ha-Latn" = "Hausa (Latin)";                                       "ha-Latn-GH" = "Hausa (Latin, Ghana)";                                                                                                                                            
        "ha-Latn-NE" = "Hausa (Latin, Niger)";                        "ha-Latn-NG" = "Hausa (Latin, Nigeria)";                           "haw" = "Hawaiian";                                                                                                                                            
        "haw-US" = "Hawaiian (United States)";                        "he" = "Hebrew";                                                   "he-IL" = "Hebrew (Israel)";                                                                                                                                            
        "hi" = "Hindi";                                               "hi-IN" = "Hindi (India)";                                         "hr" = "Croatian";                                                                                                                                            
        "hr-BA" = "Croatian (Latin, Bosnia and Herzegovina)";         "hr-HR" = "Croatian (Croatia)";                                    "hsb" = "Upper Sorbian";                                                                                                                                            
        "hsb-DE" = "Upper Sorbian (Germany)";                         "hu" = "Hungarian";                                                "hu-HU" = "Hungarian (Hungary)";                                                                                                                                            
        "hy" = "Armenian";                                            "hy-AM" = "Armenian (Armenia)";                                    "ia" = "Interlingua";                                                                                                                                            
        "ia-001" = "Interlingua (World)";                             "ia-FR" = "Interlingua (France)";                                  "ibb" = "Ibibio";                                                                                                                                            
        "ibb-NG" = "Ibibio (Nigeria)";                                "id" = "Indonesian";                                               "id-ID" = "Indonesian (Indonesia)";                                                                                                                                            
        "ig" = "Igbo";                                                "ig-NG" = "Igbo (Nigeria)";                                        "ii" = "Yi";                                                                                                                                            
        "ii-CN" = "Yi (PRC)";                                         "is" = "Icelandic";                                                "is-IS" = "Icelandic (Iceland)";                                                                                                                                            
        "it" = "Italian";                                             "it-CH" = "Italian (Switzerland)";                                 "it-IT" = "Italian (Italy)";                                                                                                                                            
        "it-SM" = "Italian (San Marino)";                             "it-VA" = "Italian (Vatican City)";                                "iu" = "Inuktitut";                                                                                                                                            
        "iu-Cans" = "Inuktitut (Syllabics)";                          "iu-Cans-CA" = "Inuktitut (Syllabics, Canada)";                    "iu-Latn" = "Inuktitut (Latin)";                                                                                                                                            
        "iu-Latn-CA" = "Inuktitut (Latin, Canada)";                   "ja" = "Japanese";                                                 "ja-JP" = "Japanese (Japan)";                                                                                                                                            
        "jgo" = "Ngomba";                                             "jgo-CM" = "Ngomba (Cameroon)";                                    "jmc" = "Machame";                                                                                                                                            
        "jmc-TZ" = "Machame (Tanzania)";                              "jv" = "Javanese";                                                 "jv-Java" = "Javanese (Javanese)";                                                                                                                                            
        "jv-Java-ID" = "Javanese (Javanese, Indonesia)";              "jv-Latn" = "Javanese";                                            "jv-Latn-ID" = "Javanese (Indonesia)";                                                                                                                                            
        "ka" = "Georgian";                                            "ka-GE" = "Georgian (Georgia)";                                    "kab" = "Kabyle";                                                                                                                                            
        "kab-DZ" = "Kabyle (Algeria)";                                "kam" = "Kamba";                                                   "kam-KE" = "Kamba (Kenya)";                                                                                                                                            
        "kde" = "Makonde";                                            "kde-TZ" = "Makonde (Tanzania)";                                   "kea" = "Kabuverdianu";                                                                                                                                            
        "kea-CV" = "Kabuverdianu (Cabo Verde)";                       "khq" = "Koyra Chiini";                                            "khq-ML" = "Koyra Chiini (Mali)";                                                                                                                                            
        "ki" = "Kikuyu";                                              "ki-KE" = "Kikuyu (Kenya)";                                        "kk" = "Kazakh";                                                                                                                                            
        "kk-KZ" = "Kazakh (Kazakhstan)";                              "kkj" = "Kako";                                                    "kkj-CM" = "Kako (Cameroon)";                                                                                                                                            
        "kl" = "Greenlandic";                                         "kl-GL" = "Greenlandic (Greenland)";                               "kln" = "Kalenjin";                                                                                                                                            
        "kln-KE" = "Kalenjin (Kenya)";                                "km" = "Khmer";                                                    "km-KH" = "Khmer (Cambodia)";                                                                                                                                            
        "kn" = "Kannada";                                             "kn-IN" = "Kannada (India)";                                       "ko" = "Korean";                                                                                                                                            
        "ko-KP" = "Korean (North Korea)";                             "ko-KR" = "Korean (Korea)";                                        "kok" = "Konkani";                                                                                                                                            
        "kok-IN" = "Konkani (India)";                                 "kr" = "Kanuri";                                                   "kr-NG" = "Kanuri (Nigeria)";                                                                                                                                            
        "ks" = "Kashmiri";                                            "ks-Arab" = "Kashmiri (Perso-Arabic)";                             "ks-Arab-IN" = "Kashmiri (Perso-Arabic)";                                                                                                                                            
        "ks-Deva" = "Kashmiri (Devanagari)";                          "ks-Deva-IN" = "Kashmiri (Devanagari, India)";                     "ksb" = "Shambala";                                                                                                                                            
        "ksb-TZ" = "Shambala (Tanzania)";                             "ksf" = "Bafia";                                                   "ksf-CM" = "Bafia (Cameroon)";                                                                                                                                            
        "ksh" = "Colognian";                                          "ksh-DE" = "Ripuarian (Germany)";                                  "ku" = "Central Kurdish";                                                                                                                                            
        "ku-Arab" = "Central Kurdish (Arabic)";                       "ku-Arab-IQ" = "Central Kurdish (Iraq)";                           "ku-Arab-IR" = "Kurdish (Perso-Arabic, Iran)";                                                                                                                                            
        "kw" = "Cornish";                                             "kw-GB" = "Cornish (United Kingdom)";                              "ky" = "Kyrgyz";                                                                                                                                            
        "ky-KG" = "Kyrgyz (Kyrgyzstan)";                              "la" = "Latin";                                                    "la-001" = "Latin (World)";                                                                                                                                            
        "lag" = "Langi";                                              "lag-TZ" = "Langi (Tanzania)";                                     "lb" = "Luxembourgish";                                                                                                                                            
        "lb-LU" = "Luxembourgish (Luxembourg)";                       "lg" = "Ganda";                                                    "lg-UG" = "Ganda (Uganda)";                                                                                                                                            
        "lkt" = "Lakota";                                             "lkt-US" = "Lakota (United States)";                               "ln" = "Lingala";                                                                                                                                            
        "ln-AO" = "Lingala (Angola)";                                 "ln-CD" = "Lingala (Congo DRC)";                                   "ln-CF" = "Lingala (Central African Republic)";                                                                                                                                            
        "ln-CG" = "Lingala (Congo)";                                  "lo" = "Lao";                                                      "lo-LA" = "Lao (Lao P.D.R.)";                                                                                                                                            
        "lrc" = "Northern Luri";                                      "lrc-IQ" = "Northern Luri (Iraq)";                                 "lrc-IR" = "Northern Luri (Iran)";                                                                                                                                            
        "lt" = "Lithuanian";                                          "lt-LT" = "Lithuanian (Lithuania)";                                "lu" = "Luba-Katanga";                                                                                                                                            
        "lu-CD" = "Luba-Katanga (Congo DRC)";                         "luo" = "Luo";                                                     "luo-KE" = "Luo (Kenya)";                                                                                                                                            
        "luy" = "Luyia";                                              "luy-KE" = "Luyia (Kenya)";                                        "lv" = "Latvian";                                                                                                                                            
        "lv-LV" = "Latvian (Latvia)";                                 "mas" = "Masai";                                                   "mas-KE" = "Masai (Kenya)";                                                                                                                                            
        "mas-TZ" = "Masai (Tanzania)";                                "mer" = "Meru";                                                    "mer-KE" = "Meru (Kenya)";                                                                                                                                            
        "mfe" = "Morisyen";                                           "mfe-MU" = "Morisyen (Mauritius)";                                 "mg" = "Malagasy";                                                                                                                                            
        "mg-MG" = "Malagasy (Madagascar)";                            "mgh" = "Makhuwa-Meetto";                                          "mgh-MZ" = "Makhuwa-Meetto (Mozambique)";                                                                                                                                            
        "mgo" = "Meta'";                                              "mgo-CM" = "Meta' (Cameroon)";                                     "mi" = "Maori";                                                                                                                                            
        "mi-NZ" = "Maori (New Zealand)";                              "mk" = "Macedonian (FYROM)";                                       "mk-MK" = "Macedonian (Former Yugoslav Republic of Macedonia)";                                                                                                                                            
        "ml" = "Malayalam";                                           "ml-IN" = "Malayalam (India)";                                     "mn" = "Mongolian";                                                                                                                                            
        "mn-Cyrl" = "Mongolian (Cyrillic)";                           "mn-MN" = "Mongolian (Cyrillic, Mongolia)";                        "mn-Mong" = "Mongolian (Traditional Mongolian)";                                                                                                                                            
        "mn-Mong-CN" = "Mongolian (Traditional Mongolian, PRC)";      "mn-Mong-MN" = "Mongolian (Traditional Mongolian, Mongolia)";      "mni" = "Manipuri";                                                                                                                                            
        "mni-IN" = "Manipuri (India)";                                "moh" = "Mohawk";                                                  "moh-CA" = "Mohawk (Mohawk)";                                                                                                                                            
        "mr" = "Marathi";                                             "mr-IN" = "Marathi (India)";                                       "ms" = "Malay";                                                                                                                                            
        "ms-BN" = "Malay (Brunei Darussalam)";                        "ms-MY" = "Malay (Malaysia)";                                      "ms-SG" = "Malay (Latin, Singapore)";                                                                                                                                            
        "mt" = "Maltese";                                             "mt-MT" = "Maltese (Malta)";                                       "mua" = "Mundang";                                                                                                                                            
        "mua-CM" = "Mundang (Cameroon)";                              "my" = "Burmese";                                                  "my-MM" = "Burmese (Myanmar)";                                                                                                                                            
        "mzn" = "Mazanderani";                                        "mzn-IR" = "Mazanderani (Iran)";                                   "naq" = "Nama";                                                                                                                                            
        "naq-NA" = "Nama (Namibia)";                                  "nb" = "Norwegian (Bokmål)";                                       "nb-NO" = "Norwegian, Bokmål (Norway)";                                                                                                                                            
        "nb-SJ" = "Norwegian, Bokmål (Svalbard and Jan Mayen)";       "nd" = "North Ndebele";                                            "nd-ZW" = "North Ndebele (Zimbabwe)";                                                                                                                                            
        "nds" = "Low German";                                         "nds-DE" = "Low German (Germany)";                                 "nds-NL" = "Low German (Netherlands)";                                                                                                                                            
        "ne" = "Nepali";                                              "ne-IN" = "Nepali (India)";                                        "ne-NP" = "Nepali (Nepal)";                                                                                                                                            
        "nl" = "Dutch";                                               "nl-AW" = "Dutch (Aruba)";                                         "nl-BE" = "Dutch (Belgium)";                                                                                                                                            
        "nl-BQ" = "Dutch (Bonaire, Sint Eustatius and Saba)";         "nl-CW" = "Dutch (Curaçao)";                                       "nl-NL" = "Dutch (Netherlands)";                                                                                                                                            
        "nl-SR" = "Dutch (Suriname)";                                 "nl-SX" = "Dutch (Sint Maarten)";                                  "nmg" = "Kwasio";                                                                                                                                            
        "nmg-CM" = "Kwasio (Cameroon)";                               "nn" = "Norwegian (Nynorsk)";                                      "nn-NO" = "Norwegian, Nynorsk (Norway)";                                                                                                                                            
        "nnh" = "Ngiemboon";                                          "nnh-CM" = "Ngiemboon (Cameroon)";                                 "no" = "Norwegian";                                                                                                                                            
        "nqo" = "N'ko";                                               "nqo-GN" = "N'ko (Guinea)";                                        "nr" = "South Ndebele";                                                                                                                                            
        "nr-ZA" = "South Ndebele (South Africa)";                     "nso" = "Sesotho sa Leboa";                                        "nso-ZA" = "Sesotho sa Leboa (South Africa)";                                                                                                                                            
        "nus" = "Nuer";                                               "nus-SS" = "Nuer (South Sudan)";                                   "nyn" = "Nyankole";                                                                                                                                            
        "nyn-UG" = "Nyankole (Uganda)";                               "oc" = "Occitan";                                                  "oc-FR" = "Occitan (France)";                                                                                                                                            
        "om" = "Oromo";                                               "om-ET" = "Oromo (Ethiopia)";                                      "om-KE" = "Oromo (Kenya)";                                                                                                                                            
        "or" = "Odia";                                                "or-IN" = "Odia (India)";                                          "os" = "Ossetic";                                                                                                                                            
        "os-GE" = "Ossetian (Cyrillic, Georgia)";                     "os-RU" = "Ossetian (Cyrillic, Russia)";                           "pa" = "Punjabi";                                                                                                                                            
        "pa-Arab" = "Punjabi (Arabic)";                               "pa-Arab-PK" = "Punjabi (Islamic Republic of Pakistan)";           "pa-IN" = "Punjabi (India)";                                                                                                                                            
        "pap" = "Papiamento";                                         "pap-029" = "Papiamento (Caribbean)";                              "pl" = "Polish";                                                                                                                                            
        "pl-PL" = "Polish (Poland)";                                  "prg" = "Prussian";                                                "prg-001" = "Prussian (World)";                                                                                                                                            
        "prs" = "Dari";                                               "prs-AF" = "Dari (Afghanistan)";                                   "ps" = "Pashto";                                                                                                                                            
        "ps-AF" = "Pashto (Afghanistan)";                             "pt" = "Portuguese";                                               "pt-AO" = "Portuguese (Angola)";                                                                                                                                            
        "pt-BR" = "Portuguese (Brazil)";                              "pt-CH" = "Portuguese (Switzerland)";                              "pt-CV" = "Portuguese (Cabo Verde)";                                                                                                                                            
        "pt-GQ" = "Portuguese (Equatorial Guinea)";                   "pt-GW" = "Portuguese (Guinea-Bissau)";                            "pt-LU" = "Portuguese (Luxembourg)";                                                                                                                                            
        "pt-MO" = "Portuguese (Macao SAR)";                           "pt-MZ" = "Portuguese (Mozambique)";                               "pt-PT" = "Portuguese (Portugal)";                                                                                                                                            
        "pt-ST" = "Portuguese (São Tomé and Príncipe)";               "pt-TL" = "Portuguese (Timor-Leste)";                              "quc" = "K'iche'";                                                                                                                                            
        "quc-Latn" = "K'iche'";                                       "quc-Latn-GT" = "K'iche' (Guatemala)";                             "quz" = "Quechua";                                                                                                                                            
        "quz-BO" = "Quechua (Bolivia)";                               "quz-EC" = "Quechua (Ecuador)";                                    "quz-PE" = "Quechua (Peru)";                                                                                                                                            
        "rm" = "Romansh";                                             "rm-CH" = "Romansh (Switzerland)";                                 "rn" = "Rundi";                                                                                                                                            
        "rn-BI" = "Rundi (Burundi)";                                  "ro" = "Romanian";                                                 "ro-MD" = "Romanian (Moldova)";                                                                                                                                            
        "ro-RO" = "Romanian (Romania)";                               "rof" = "Rombo";                                                   "rof-TZ" = "Rombo (Tanzania)";                                                                                                                                            
        "ru" = "Russian";                                             "ru-BY" = "Russian (Belarus)";                                     "ru-KG" = "Russian (Kyrgyzstan)";                                                                                                                                            
        "ru-KZ" = "Russian (Kazakhstan)";                             "ru-MD" = "Russian (Moldova)";                                     "ru-RU" = "Russian (Russia)";                                                                                                                                            
        "ru-UA" = "Russian (Ukraine)";                                "rw" = "Kinyarwanda";                                              "rw-RW" = "Kinyarwanda (Rwanda)";                                                                                                                                            
        "rwk" = "Rwa";                                                "rwk-TZ" = "Rwa (Tanzania)";                                       "sa" = "Sanskrit";                                                                                                                                            
        "sa-IN" = "Sanskrit (India)";                                 "sah" = "Sakha";                                                   "sah-RU" = "Sakha (Russia)";                                                                                                                                            
        "saq" = "Samburu";                                            "saq-KE" = "Samburu (Kenya)";                                      "sbp" = "Sangu";                                                                                                                                            
        "sbp-TZ" = "Sangu (Tanzania)";                                "sd" = "Sindhi";                                                   "sd-Arab" = "Sindhi (Arabic)";                                                                                                                                            
        "sd-Arab-PK" = "Sindhi (Islamic Republic of Pakistan)";       "sd-Deva" = "Sindhi (Devanagari)";                                 "sd-Deva-IN" = "Sindhi (Devanagari, India)";                                                                                                                                            
        "se" = "Sami (Northern)";                                     "se-FI" = "Sami, Northern (Finland)";                              "se-NO" = "Sami, Northern (Norway)";                                                                                                                                            
        "se-SE" = "Sami, Northern (Sweden)";                          "seh" = "Sena";                                                    "seh-MZ" = "Sena (Mozambique)";                                                                                                                                            
        "ses" = "Koyraboro Senni";                                    "ses-ML" = "Koyraboro Senni (Mali)";                               "sg" = "Sango";                                                                                                                                            
        "sg-CF" = "Sango (Central African Republic)";                 "shi" = "Tachelhit";                                               "shi-Latn" = "Tachelhit (Latin)";                                                                                                                                            
        "shi-Latn-MA" = "Tachelhit (Latin, Morocco)";                 "shi-Tfng" = "Tachelhit (Tifinagh)";                               "shi-Tfng-MA" = "Tachelhit (Tifinagh, Morocco)";                                                                                                                                            
        "si" = "Sinhala";                                             "si-LK" = "Sinhala (Sri Lanka)";                                   "sk" = "Slovak";                                                                                                                                            
        "sk-SK" = "Slovak (Slovakia)";                                "sl" = "Slovenian";                                                "sl-SI" = "Slovenian (Slovenia)";                                                                                                                                            
        "sma" = "Sami (Southern)";                                    "sma-NO" = "Sami, Southern (Norway)";                              "sma-SE" = "Sami, Southern (Sweden)";                                                                                                                                            
        "smj" = "Sami (Lule)";                                        "smj-NO" = "Sami, Lule (Norway)";                                  "smj-SE" = "Sami, Lule (Sweden)";                                                                                                                                            
        "smn" = "Sami (Inari)";                                       "smn-FI" = "Sami, Inari (Finland)";                                "sms" = "Sami (Skolt)";                                                                                                                                            
        "sms-FI" = "Sami, Skolt (Finland)";                           "sn" = "Shona";                                                    "sn-Latn" = "Shona (Latin)";                                                                                                                                            
        "sn-Latn-ZW" = "Shona (Latin, Zimbabwe)";                     "so" = "Somali";                                                   "so-DJ" = "Somali (Djibouti)";                                                                                                                                            
        "so-ET" = "Somali (Ethiopia)";                                "so-KE" = "Somali (Kenya)";                                        "so-SO" = "Somali (Somalia)";                                                                                                                                            
        "sq" = "Albanian";                                            "sq-AL" = "Albanian (Albania)";                                    "sq-MK" = "Albanian (Macedonia, FYRO)";                                                                                                                                            
        "sq-XK" = "Albanian (Kosovo)";                                "sr" = "Serbian";                                                  "sr-Cyrl" = "Serbian (Cyrillic)";                                                                                                                                            
        "sr-Cyrl-BA" = "Serbian (Cyrillic, Bosnia and Herzegovina)";  "sr-Cyrl-ME" = "Serbian (Cyrillic, Montenegro)";                   "sr-Cyrl-RS" = "Serbian (Cyrillic, Serbia)";                                                                                                                                            
        "sr-Cyrl-XK" = "Serbian (Cyrillic, Kosovo)";                  "sr-Latn" = "Serbian (Latin)";                                     "sr-Latn-BA" = "Serbian (Latin, Bosnia and Herzegovina)";                                                                                                                                            
        "sr-Latn-ME" = "Serbian (Latin, Montenegro)";                 "sr-Latn-RS" = "Serbian (Latin, Serbia)";                          "sr-Latn-XK" = "Serbian (Latin, Kosovo)";                                                                                                                                            
        "ss" = "Swati";                                               "ss-SZ" = "Swati (Eswatini former Swaziland)";                     "ss-ZA" = "Swati (South Africa)";                                                                                                                                            
        "ssy" = "Saho";                                               "ssy-ER" = "Saho (Eritrea)";                                       "st" = "Southern Sotho";                                                                                                                                            
        "st-LS" = "Sesotho (Lesotho)";                                "st-ZA" = "Southern Sotho (South Africa)";                         "sv" = "Swedish";                                                                                                                                            
        "sv-AX" = "Swedish (Åland Islands)";                          "sv-FI" = "Swedish (Finland)";                                     "sv-SE" = "Swedish (Sweden)";                                                                                                                                            
        "sw" = "Kiswahili";                                           "sw-CD" = "Kiswahili (Congo DRC)";                                 "sw-KE" = "Kiswahili (Kenya)";                                                                                                                                            
        "sw-TZ" = "Kiswahili (Tanzania)";                             "sw-UG" = "Kiswahili (Uganda)";                                    "syr" = "Syriac";                                                                                                                                            
        "syr-SY" = "Syriac (Syria)";                                  "ta" = "Tamil";                                                    "ta-IN" = "Tamil (India)";                                                                                                                                            
        "ta-LK" = "Tamil (Sri Lanka)";                                "ta-MY" = "Tamil (Malaysia)";                                      "ta-SG" = "Tamil (Singapore)";                                                                                                                                            
        "te" = "Telugu";                                              "te-IN" = "Telugu (India)";                                        "teo" = "Teso";                                                                                                                                            
        "teo-KE" = "Teso (Kenya)";                                    "teo-UG" = "Teso (Uganda)";                                        "tg" = "Tajik";                                                                                                                                            
        "tg-Cyrl" = "Tajik (Cyrillic)";                               "tg-Cyrl-TJ" = "Tajik (Cyrillic, Tajikistan)";                     "th" = "Thai";                                                                                                                                            
        "th-TH" = "Thai (Thailand)";                                  "ti" = "Tigrinya";                                                 "ti-ER" = "Tigrinya (Eritrea)";                                                                                                                                            
        "ti-ET" = "Tigrinya (Ethiopia)";                              "tig" = "Tigre";                                                   "tig-ER" = "Tigre (Eritrea)";                                                                                                                                            
        "tk" = "Turkmen";                                             "tk-TM" = "Turkmen (Turkmenistan)";                                "tn" = "Setswana";                                                                                                                                            
        "tn-BW" = "Setswana (Botswana)";                              "tn-ZA" = "Setswana (South Africa)";                               "to" = "Tongan";                                                                                                                                            
        "to-TO" = "Tongan (Tonga)";                                   "tr" = "Turkish";                                                  "tr-CY" = "Turkish (Cyprus)";                                                                                                                                            
        "tr-TR" = "Turkish (Turkey)";                                 "ts" = "Tsonga";                                                   "ts-ZA" = "Tsonga (South Africa)";                                                                                                                                            
        "tt" = "Tatar";                                               "tt-RU" = "Tatar (Russia)";                                        "twq" = "Tasawaq";                                                                                                                                            
        "twq-NE" = "Tasawaq (Niger)";                                 "tzm" = "Tamazight";                                               "tzm-Arab" = "Central Atlas Tamazight (Arabic)";                                                                                                                                            
        "tzm-Arab-MA" = "Central Atlas Tamazight (Arabic, Morocco)";  "tzm-Latn" = "Tamazight (Latin)";                                  "tzm-Latn-DZ" = "Tamazight (Latin, Algeria)";                                                                                                                                            
        "tzm-Latn-MA" = "Central Atlas Tamazight (Latin, Morocco)";   "tzm-Tfng" = "Tamazight (Tifinagh)";                               "tzm-Tfng-MA" = "Central Atlas Tamazight (Tifinagh, Morocco)";                                                                                                                                            
        "ug" = "Uyghur";                                              "ug-CN" = "Uyghur (PRC)";                                          "uk" = "Ukrainian";                                                                                                                                            
        "uk-UA" = "Ukrainian (Ukraine)";                              "ur" = "Urdu";                                                     "ur-IN" = "Urdu (India)";                                                                                                                                            
        "ur-PK" = "Urdu (Islamic Republic of Pakistan)";              "uz" = "Uzbek";                                                    "uz-Arab" = "Uzbek (Perso-Arabic)";                                                                                                                                            
        "uz-Arab-AF" = "Uzbek (Perso-Arabic, Afghanistan)";           "uz-Cyrl" = "Uzbek (Cyrillic)";                                    "uz-Cyrl-UZ" = "Uzbek (Cyrillic, Uzbekistan)";                                                                                                                                            
        "uz-Latn" = "Uzbek (Latin)";                                  "uz-Latn-UZ" = "Uzbek (Latin, Uzbekistan)";                        "vai" = "Vai";                                                                                                                                            
        "vai-Latn" = "Vai (Latin)";                                   "vai-Latn-LR" = "Vai (Latin, Liberia)";                            "vai-Vaii" = "Vai (Vai)";                                                                                                                                            
        "vai-Vaii-LR" = "Vai (Vai, Liberia)";                         "ve" = "Venda";                                                    "ve-ZA" = "Venda (South Africa)";                                                                                                                                            
        "vi" = "Vietnamese";                                          "vi-VN" = "Vietnamese (Vietnam)";                                  "vo" = "Volapük";                                                                                                                                            
        "vo-001" = "Volapük (World)";                                 "vun" = "Vunjo";                                                   "vun-TZ" = "Vunjo (Tanzania)";                                                                                                                                            
        "wae" = "Walser";                                             "wae-CH" = "Walser (Switzerland)";                                 "wal" = "Wolaytta";                                                                                                                                            
        "wal-ET" = "Wolaytta (Ethiopia)";                             "wo" = "Wolof";                                                    "wo-SN" = "Wolof (Senegal)";                                                                                                                                            
        "xh" = "isiXhosa";                                            "xh-ZA" = "isiXhosa (South Africa)";                               "xog" = "Soga";                                                                                                                                            
        "xog-UG" = "Soga (Uganda)";                                   "yav" = "Yangben";                                                 "yav-CM" = "Yangben (Cameroon)";                                                                                                                                            
        "yi" = "Yiddish";                                             "yi-001" = "Yiddish (World)";                                      "yo" = "Yoruba";                                                                                                                                            
        "yo-BJ" = "Yoruba (Benin)";                                   "yo-NG" = "Yoruba (Nigeria)";                                      "zgh" = "Standard Moroccan Tamazight";                                                                                                                                            
        "zgh-Tfng" = "Standard Moroccan Tamazight (Tifinagh)";        "zgh-Tfng-MA" = "Standard Moroccan Tamazight (Tifinagh, Morocco)"; "zh" = "Chinese";                                                                                                                                            
        "zh-CN" = "Chinese (Simplified, PRC)";                        "zh-Hans" = "Chinese (Simplified)";                                "zh-Hans-HK" = "Chinese (Simplified Han, Hong Kong SAR)";                                                                                                                                            
        "zh-Hans-MO" = "Chinese (Simplified Han, Macao SAR)";         "zh-Hant" = "Chinese (Traditional)";                               "zh-HK" = "Chinese (Traditional, Hong Kong S.A.R.)";                                                                                                                                            
        "zh-MO" = "Chinese (Traditional, Macao S.A.R.)";              "zh-SG" = "Chinese (Simplified, Singapore)";                       "zh-TW" = "Chinese (Traditional, Taiwan)";                                                                                                                                            
        "zu" = "isiZulu";                                             "zu-ZA" = "isiZulu (South Africa)"
    }

    # Get the current user's language and region using the registry
    $Region = $localeLookup[(Get-ItemProperty -Path "HKCU:Control Panel\International\Geo").Nation]
    # Iterate through registry key in case multiple languages are configured
    (Get-ItemProperty -Path "HKCU:Control Panel\International\User Profile").Languages | ForEach-Object {
        $Languages += " - $($languageLookup[$_])"
    }

    return @{
        title = "Locale"
        content = "$Region$Languages"
    }
}

# ===== WEATHER =====
function info_weather {
    return @{
        title = "Weather"
        content = try {
            (Invoke-RestMethod wttr.in/?format="%t+-+%C+(%l)").TrimStart("+")
        } catch {
            "$e[91m(Network Error)"
        }
    }
}


# ===== IP =====
function info_local_ip {
    try {
        # Get all network adapters
        foreach ($ni in [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()) {
            # Get the IP information of each adapter
            $properties = $ni.GetIPProperties()
            # Check if the adapter is online, has a gateway address, and the adapter does not have a loopback address
            if ($ni.OperationalStatus -eq 'Up' -and !($null -eq $properties.GatewayAddresses[0]) -and !$properties.GatewayAddresses[0].Address.ToString().Equals("0.0.0.0")) {
                # Check if adapter is a WiFi or Ethernet adapter
                if ($ni.NetworkInterfaceType -eq "Wireless80211" -or $ni.NetworkInterfaceType -eq "Ethernet") {
                    foreach ($ip in $properties.UnicastAddresses) {
                        if ($ip.Address.AddressFamily -eq "InterNetwork") {
                            if (!$local_ip) { $local_ip = $ip.Address.ToString() }
                        }
                    }
                }
            }
        }
    } catch {
    }
    return @{
        title = "Local IP"
        content = if (-not $local_ip) {
            "$e[91m(Unknown)"
        } else {
            $local_ip
        }
    }
}

function info_public_ip {
    return @{
        title = "Public IP"
        content = try {
            Invoke-RestMethod ifconfig.me/ip
        } catch {
            "$e[91m(Network Error)"
        }
    }
}


## Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else {
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}

function EventLogFailed {
    Try {
        Get-WinEvent -ListLog Security|out-null
    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error.' }
    Try {
        $Events = Get-WinEvent -LogName "Security" -FilterXPath "*[EventData[(Data[@Name='LogonType']='10') or (Data[@Name='LogonType']='3')] and System[EventID=4625]]" -ErrorAction Stop
        ForEach ($Event in $Events) {
            $eventXML = [xml]$Event.ToXml()
            Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "TimeCreate" -Value $Event.TimeCreated
            FOREACH ($j in $eventXML.Event.System.ChildNodes) {
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $j.ToString() -Value $eventXML.Event.System.($j.ToString())
            }
            For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'
            }
        }
        $Events |select TimeCreate,EventRecordID,TargetUserName,IpAddress,IpPort
    }
    Catch { return 'Result: Null. Pleace Use EventLogFailedLogParser. Maybe Wait a second.'}
}

## function search on cheat.sh
function cheatsh {
	param (
        [string]$query
	)
	curl.exe cheat.sh/${query}
}

function chk-remote-vigilance {
	Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Select-Object -Property Name, Enabled
}

# Lista todos los Appx instaldos para el usurio en sesion
function List-Appx-Pkgs {
	Get-AppxPackage | ? { !$_.NonRemovable } | Select Name, PackageFullName
}

# Lista todos los Appx instaldos para todos los usuarios en el sistema
function List-All-Appx-Pkgs {
	Get-AppxPackage -AllUsers | ? { !$_.NonRemovable } | Select Name, PackageFullName
}

function crt {
 curl.exe -s "https://crt.sh/?q=%25.$1" | grep.exe -oE "[\.a-zA-Z0-9-]+\.$1" | Sort-Object
}

function get-ips4 {
	param (
	[string]$ingest
	)
	$regex = '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
	grep -Eo $regex $ingest
}

function get-ip4-port {
	param (
	[string]$ingest
	)
	$regex = '\b([0-9]{1,3}\.){3}[0-9]{1,3}:([0-9]{5})\b'
	grep -Eo $regex $ingest
}

function get-macs {
	param (
	[string]$ingest
	)
	$regex = '\b([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\b'
	grep -Eo $regex $ingest
}

function get-ipv6 {
	param (
	[string]$ingest
	)
	$regex = '\b(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))\b'
	grep -Eo $regex $ingest
}

function get-email-pass {
	param (
	[string]$ingest
	)
	$regex = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}:[^&]+\b'
	grep -Eo $regex $ingest
}

function get-emails {
	param (
	[string]$ingest
	)
	$regex = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}'
	grep -Eo $regex $ingest
}

function get-passwds {
	param (
	[string]$ingest
	)
	$regex = '(P|p)assw(d|D|ord|ORD)(:|=)[^&]+'
	grep -Eo $regex $ingest
}

function random_user {
	curl -s -H -L GET 'https://usernameapiv1.vercel.app/api/random-usernames'
}

## Final Line to set prompt
oh-my-posh init pwsh --config ${env:POSH_THEMES_PATH}\tokyonight_storm.omp.json | Invoke-Expression

# Oh-My-Posh Completions
oh-my-posh completion powershell | Out-String | Invoke-Expression

winfetch.ps1
