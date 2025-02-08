# Collection of PowerShell Snippets, Functions, Aliases and General Sys Administration to ease Management

## Where does Windows store all drivers?

```

%WINDIR%\System32\DriverStore\FileRepository
```

### List all drivers

``` PowerShell

Get-WmiObject Win32_PnPSignedDriver| select DeviceName, DeviceClass,Manufacturer, DriverVersion, DriverDate,InfName|Out-GridView
```

### List all 3d party drivers (Nvidia, AMD, etc)

``` PowerShell

Get-WindowsDriver –Online| select Driver, ClassName, BootCritical, ProviderName, Date, Version, OriginalFileName|Out-GridView
```

### You can remove any of the installed drivers using the pnputil CLI tool:

``` PowerShell

pnputil.exe /remove-device oemxxx.inf
```

### A PS1 script to automate it:

#### Use this PowerShell script to find and remove old and unused device drivers from the Windows Driver Store
#### Explanation: http://woshub.com/how-to-remove-unused-drivers-from-driver-store/

``` PowerShell

$dismOut = dism /online /get-drivers
$Lines = $dismOut | select -Skip 10
$Operation = "theName"
$Drivers = @()
foreach ( $Line in $Lines ) {
    $tmp = $Line
    $txt = $($tmp.Split( ':' ))[1]
    switch ($Operation) {
        'theName' { $Name = $txt
                     $Operation = 'theFileName'
                     break
                   }
        'theFileName' { $FileName = $txt.Trim()
                         $Operation = 'theEntr'
                         break
                       }
        'theEntr' { $Entr = $txt.Trim()
                     $Operation = 'theClassName'
                     break
                   }
        'theClassName' { $ClassName = $txt.Trim()
                          $Operation = 'theVendor'
                          break
                        }
        'theVendor' { $Vendor = $txt.Trim()
                       $Operation = 'theDate'
                       break
                     }
        'theDate' { # we'll change the default date format for easy sorting
                     $tmp = $txt.split( '.' )
                     $txt = "$($tmp[2]).$($tmp[1]).$($tmp[0].Trim())"
                     $Date = $txt
                     $Operation = 'theVersion'
                     break
                   }
        'theVersion' { $Version = $txt.Trim()
                        $Operation = 'theNull'
                        $params = [ordered]@{ 'FileName' = $FileName
                                              'Vendor' = $Vendor
                                              'Date' = $Date
                                              'Name' = $Name
                                              'ClassName' = $ClassName
                                              'Version' = $Version
                                              'Entr' = $Entr
                                            }
                        $obj = New-Object -TypeName PSObject -Property $params
                        $Drivers += $obj
                        break
                      }
         'theNull' { $Operation = 'theName'
                      break
                     }
    }
}
$last = ''
$NotUnique = @()
foreach ( $Dr in $($Drivers | sort Filename) ) {
    if ($Dr.FileName -eq $last  ) {  $NotUnique += $Dr  }
    $last = $Dr.FileName
}
$NotUnique | sort FileName | ft
# search for duplicate drivers
$list = $NotUnique | select -ExpandProperty FileName -Unique
$ToDel = @()
foreach ( $Dr in $list ) {
    Write-Host "duplicate driver found" -ForegroundColor Yellow
    $sel = $Drivers | where { $_.FileName -eq $Dr } | sort date -Descending | select -Skip 1
    $sel | ft
    $ToDel += $sel
}
Write-Host "List of driver version  to remove" -ForegroundColor Red
$ToDel | ft
# Removing old driver versions
# Uncomment the Invoke-Expression to automatically remove old versions of device drivers
foreach ( $item in $ToDel ) {
    $Name = $($item.Name).Trim()
    #Write-Host "deleting $Name" -ForegroundColor Yellow
    Write-Host "pnputil.exe /remove-device  $Name" -ForegroundColor Yellow
    Invoke-Expression -Command "pnputil.exe /remove-device $Name"
}
```

# ~~Always~~ Update from the terminal with PowerShell or CMD

## How to use Windows update command line?

To run Windows update from command line, two powerful inbuilt tools can make a great difference. One is Command Prompt, and the other is PowerShell. Now, let’s see how to use them to perform Windows updates respectively.


## __Method 1:__

Run Windows update via Command Prompt. Command Prompt is a classical command-line-based application in most Windows operating systems to manage disks and handle system issues. When you type commands to update Windows, you should be careful because it only shows the results instead of the execution process. For Windows 10 system follow this steps:
> Step 1 Type cmd in the search box, and right-click the top one, then choose Run as administrator to open Command Prompt.
> Step 2 Type the following command lines and press "Enter" after each.

``` cmd

C:\Windows\System32> UsoClient StartScan
####  _This will scan for all available updates_

C:\Windows\System32> UsoClient StartDownload
#### _download the updates you scan for_

C:\Windows\System32> UsoClient StartInstall
#### _install all the downloaded updates_

C:\Windows\System32> UsoClient RestartDevice
#### _restart your computer for installing the updates_

C:\Windows\System32> UsoClient ScanInstallWait
#### _check, download, and install updates_
```

## `windows-update-command-line`

### For older versions of operating systems like Windows 8, you need to enter the following commands in the Command Prompt window one by one:

``` cmd

C:\Windows\System32> wuauclt /detectnow
#### _check for updates_

C:\Windows\System32> wuauclt /updatenow
#### _start to install the detected updates_

C:\Windows\System32> wuauclt /detectnow /updatenow
#### _check, download, and install updates_
```

### What to do if you fail to update Windows from command line?

However, not every time you can successfully run Windows update command line, Windows 10 update may fail with error code 0x80070057 or other errors. But don't worry, this part will walk you through how to force Windows to update. Before learning force Windows update command line, one of the most important things is to back up your operating system out of safety.

### Force Windows to update from Microsoft

When you finish the backup, you can begin to update Windows forcibly. The first tip is to free download Windows 10:

* Go to the Microsoft official website, go to the "Download Windows 10" section, and click "Update now".
* force-update-windows-10-download
* Download and install the latest version of Windows 10.
* Then, follow the instructions to force update Windows 10.

### Force Windows to update with CMD

For those who don’t want to install Windows with the Windows assistant tool, force updating Windows 10 with CMD is a good choice:

* Run Command Prompt as administrator as we said before.
* Type the force windows update command line: 

``` cmd

C:\Windows\System32> wuauclt.exe /updatenow
```

Windows update is a free service that you should never ignore. It can keep your computer stay with the latest security and software updates. In this article, we have introduced two effective ways to perform the Windows update command line and provided you with another two tips for force update Windows if you meet upgrade failure. In addition, if you are worried about data loss, follow our guide to back up your operating system via AOMEI Partition Assistant Professional.

### If updates continue to fail reset the Windows Update agent settings, re-register the libraries, and restore the wususerv service to its default state by using the command:

``` PowerShell

Reset-WUComponents -Verbose
```

### To check the source of Windows Update on your computer (is it the Windows Update servers on the Internet or is it the local WSUS), run the following command:

``` PowerShell

Get-WUServiceManager
```

### To scan your computer against Microsoft Update servers on the Internet (these servers contain updates for Office and other products in addition to Windows updates), run this command:

``` PowerShell

Get-WUlist -MicrosoftUpdate
```

### You will get this warning:

[!Info]
> Get-WUlist : Service Windows Update was not found on computer. Use Get-WUServiceManager to get registered service.

### To allow scanning on Microsoft Update, run this command:

``` PowerShell

Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7
```

### If you want to remove specific products or specific KBs from the list of updates that your computer receives, you can exclude them by:

* Category (-NotCategory);
* Title (-NotCategory);
* Update number (-NotKBArticleID).


### For example, to exclude driver updates, OneDrive, and a specific KB from the update list:

``` PowerShell

Get-WUlist -NotCategory "Drivers" -NotTitle "OneDrive" -NotKBArticleID KB4489873
```

### You can download all available updates to your computer (update files are downloaded to the local update cache in the C:\Windows\SoftwareDistribution\Download).

``` PowerShell

Get-WindowsUpdate -Download -AcceptAll
```

Windows will download any available updates (MSU and CAB files) from the update server to the local update directory, but it will not install them automatically.

## Installing Windows Updates with PowerShell


### To automatically download and install all available updates for your Windows device from Windows Update servers (instead of local WSUS), run the command:

``` PowerShell

Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
```

_The AcceptAll option accepts the installation of all update packages, and AutoReboot allows Windows to automatically restart after the updates are installed._

### You can also use the following options:

``` PowerShell

    IgnoreReboot – disable automatic computer reboot;
    ScheduleReboot – Schedule the exact time of the computer’s reboot.
```

### You can write the update installation history to a log file (you can use it instead of the WindowsUpdate.log file).

``` PowerShell

Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "c:\logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force
```

### You can only install the specific updates by their KB numbers:

``` PowerShell

Get-WindowsUpdate -KBArticleID KB2267602, KB4533002 -Install
```

### If you want to skip some updates during installation, run this command:

``` PowerShell

Install-WindowsUpdate -NotCategory "Drivers" -NotTitle OneDrive -NotKBArticleID KB4011670 -AcceptAll -IgnoreReboot
```

### Check whether you need to restart your computer after installing the update (pending reboot):

``` PowerShell

Get-WURebootStatus | select RebootRequired, RebootScheduled
```

### Check Windows Update History Using PowerShell

The Get-WUHistory cmdlet is used to get the list of updates that have previously been automatically or manually installed on your computer.

Check the date when the specific update was installed on the computer:

``` PowerShell

Get-WUHistory| Where-Object {$_.Title -match "KB4517389"} | Select-Object *|ft
Get-WUHistory for a specific KB
```


### Find out when your computer was last scanned and when the update was installed:

``` PowerShell

Get-WULastResults |select LastSearchSuccessDate, LastInstallationSuccessDate
Get-WULastResults - last update scan
```

### Uninstalling Windows Updates with PowerShell use the `Remove-WindowsUpdate` cmdlet to uninstall Windows updates on a computer. Simply specify the KB number as the argument of the KBArticleID parameter:

```  PowerShell

Remove-WindowsUpdate -KBArticleID KB4489873 -NoRestart
```

How to Hide or Show Windows Updates Using PowerShell. You can hide certain updates to prevent the Windows Update service from installing them (most often you need to hide the driver updates). For example, to hide the KB4489873 and KB4489243 updates, run these commands:

``` PowerShell

$HideList = "KB4489873", "KB4489243"
Get-WindowsUpdate -KBArticleID $HideList –Hide
```

Or use an alias:

``` PowerShell 

Hide-WindowsUpdate -KBArticleID $HideList -Verbose
powershell - hide specific KBs in windows update
```

Hidden updates will not appear in the list of available updates the next time you use the Get-WindowsUpdate command to check for updates.
List hidden updates:

``` PowerShell

Get-WindowsUpdate –IsHidden
```

### _Notice that the H (Hidden) attribute has appeared in the Status column for hidden updates._


``` PowerShell

Get-WindowsUpdate –IsHidden - find hidden updates
```

### _To unhide updates on the computer:_

``` PowerShell

Get-WindowsUpdate -KBArticleID $HideList -WithHidden -Hide:$false
```

# or:

``` PowerShell

Show-WindowsUpdate -KBArticleID $HideList
```

# Reboot directly into troubleshoot mode

``` cmd

C:\Windows\System32> shutdown.exe /f /r /o /t 0
```

#### _Notice that you actually have to be inside the `C:\Windows\System32` directory_

## Steps To Fix a corrupt `WPA Registry`

1) Download https://github.com/asdcorp/rearm/archive/refs/heads/principalis.zip
2) Extract this zip file.
3) Copy rearm.cmd file to the root of the C drive, like C:\rearm.cmd
4) Open the command prompt as administrator and enter the below command
5) Shutdown /f /r /o /t 0
6) After the system restarts, select Troubleshoot > Advanced Options > Command Prompt.

### Enter the following command:

``` cmd

C:\rearm.cmd
```

### _If it says the command is not recognized, enter:_

``` cmd

C:\Windows\System32> bcdedit | find "osdevice"
```

### _It will show you the OS drive letter. Use that drive letter in the command, for example:_

``` cmd

C:\Windows\System32> E:\rearm.cmd
```

Wait for it to finish. When it's finished, you will be able to type in the command prompt, If not then wait.
Once done, exit and then normally boot into Windows.

## Check the installed Windows OS Architecture:

``` PowerShell

 Get-WmiObject -Class Win32_OperatingSystem | Format-List OSArchitecture
 ```

 ## Check the installed Windows Language:

 ``` PowerShell

 dism /english /online /get-intl | find /i "Default system UI language"
 ```


# In-place Repair Upgrade Windows OS Isntalled Keeping files and apps


## In-place repair upgrade using Windows ISO file is a good way to fix system errors. Follow steps:

1) Download the Windows ISO, preferably from MSDL in the same Windows language, and architecture.
2) Check the installed Windows architecture, open Powershell as admin and enter:

``` PowerShell

Get-WmiObject -Class Win32_OperatingSystem | Format-List OSArchitecture
```
##### _x64 means 64 Bit, x86 means 32 Bit_

To check the installed Windows Language, open Powershell as admin and enter:

``` PowerShell

dism /english /online /get-intl | find /i "Default system UI language"
```

3) Double-click on the ISO file once it is downloaded.
##### _If it opens in another program like 7-Zip, close it, right-click on the ISO, Open With > Windows Explorer_

##### *A new DVD drive will appear in Windows Explorer, which means the installation image has been mounted successfully.*

4) Go into that DVD drive and run setup.exe, just continue until you reach the final confirmation screen.
##### _Make sure it says "Keep all files and apps" on the final screen. Then you can continue the process and wait until it is done._

# All posible ways to check within windows machines IP:

``` PowerShell

IPCONFIG /all
ROUTE PRINT
ARP -a
NETSTAT.EXE -n |FIND /v "127.0.0."
NET use
NETSH winhttp show proxy
TRACERT -h 2 8.8.8.8
WMIC printer get DriverName, Name, Portname | FIND /v /i "microsoft"
Qappsrv
REG query HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\SshHostKeys
REG query HKEY_CURRENT_USER\SOFTWARE\9bis.com\KiTTY\SshHostKeys
REG query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces /s|find /i "address "
REG query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces /s|find /i "server "
REG query "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default"
REG query "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers"
FIND *\Documents\*.rdp "full address:"
NSLOOKUP %USERDNSDOMAIN%
NSLOOKUP -type=srv _kerberos._tcp.%USERDNSDOMAIN%
NSLOOKUP -type=srv _kpasswd._tcp.%USERDNSDOMAIN%
NSLOOKUP -type=srv _ldap._tcp.%USERDNSDOMAIN%
NSLOOKUP -type=srv _ldap._tcp.dc._msdcs.%USERDNSDOMAIN%
TRACERT -h 2 %USERDNSDOMAIN%
dsregcmd /status
```
