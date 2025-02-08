function WindowsTweaks_Services {
    $service = @("WpcMonSvc", "SharedRealitySvc", "Fax", "autotimesvc", "wisvc", "SDRSVC", "MixedRealityOpenXRSvc", "WalletService", "SmsRouter", "SharedAccess", "MapsBroker", "PhoneSvc"
        "ScDeviceEnum", "TabletInputService", "icssvc", "edgeupdatem", "edgeupdate", "MicrosoftEdgeElevationService", "RetailDemo", "MessagingService", "PimIndexMaintenanceSvc", "OneSyncSvc"
        "UnistoreSvc", "DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service", "diagsvc", "WerSvc", "wercplsupport", "SCardSvr", "SEMgrSvc")
    foreach ($service in $service) {
        Stop-Service $service -ErrorAction SilentlyContinue
        Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function WindowsTweaks_Featuresc {
    $features = @("TFTP", "TelnetClient", "WCF-TCP-PortSharing45", "SmbDirect", "MicrosoftWindowsPowerShellV2Root"
        "Printing-XPSServices-Features", "WorkFolders-Client", "MSRDC-Infrastructure", "MicrosoftWindowsPowerShellV2")
    foreach ($feature in $features) {
        dism /Online /Disable-Feature /FeatureName:$feature /NoRestart
    }
    $capability = @("App.StepsRecorder*", "App.Support.QuickAssist*", "Browser.InternetExplore*", "Hello.Face*", "MathRecognizer*", "Microsoft.Windows.PowerShell.ISE*", "OpenSSH*", "Language.Handwriting")
    foreach ($capability in $capability) {
        Get-WindowsCapability -online | where-object { $_.name -like $capability } | Remove-WindowsCapability -online -ErrorAction SilentlyContinue
    }
}

function WindowsTweaks_Tasks {
    schtasks /change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
    schtasks /change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE
    schtasks /change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
    Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" | Disable-ScheduledTask
    $task = @("ProgramDataUpdater", "Proxy", "Consolidator", "Microsoft-Windows-DiskDiagnosticDataCollector", "MapsToastTask", "MapsUpdateTask", "FamilySafetyMonitor"
        "FODCleanupTask", "FamilySafetyRefreshTask", "XblGameSaveTask", "UsbCeip", "DmClient", "DmClientOnScenarioDownload")
    foreach ($task in $task) {
        Get-ScheduledTask -TaskName $task | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
}

function WindowsTweaks_Registry {
    # MarkC Mouse Acceleration Fix
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" ([byte[]](0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xCC, 0x0C, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x80, 0x99, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x66, 0x26,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00))
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" ([byte[]](0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA8,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x00, 0x00))
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Type "DWORD" -Value 10 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseTrails" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\DiagTrack" -Name "Start" -Type "DWORD" -Value 4 -Force 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -Name "OverlayTestMode" -Type "DWORD" -Value 00000005 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "Start" -Type "DWORD" -Value 4 -Force 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\" -Name "NetworkThrottlingIndex" -Type "DWORD" -Value 268435455 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\" -Name "SystemResponsiveness" -Type "DWORD" -Value 00000000 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type "DWORD" -Value 00000006 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "High" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Value "High" -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" -Name "Start" -Type "DWORD" -Value 4 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type "DWORD" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "LimitEnhancedDiagnosticDataWindowsAnalytics" -Type "DWORD" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type "DWORD" -Value 0 -Force 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" -Name "HideInsiderPage" -Type "DWORD" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\activity" -Name "Value" -Value "Deny" -Force
    ForEach ($result in Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches") {
        If (!($result.name -eq "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\DownloadsFolder")) {
            New-ItemProperty -Path "'HKLM:' + $result.Name.Substring( 18 )" -Name 'StateFlags0001' -Value 2 -PropertyType DWORD -Force -EA 0
        }
    }
}
            
function WindowsTweaks_Index {
    Label $env:SystemDrive Windows
    $drive = @('$env:SystemDrive', 'C:', 'D:', 'E:', 'F:', 'G:')
    foreach ($drive in $drive) {
        Get-WmiObject -Class Win32_Volume -Filter "DriveLetter='$drive'" | Set-WmiInstance -Arguments @{IndexingEnabled = $False }
    }
}