param (
    [parameter(Mandatory = $true)][string[]]$VMs, 
    [parameter(Mandatory = $true)][string]$AdminAccountName,
    [parameter(Mandatory = $false)][string]$AdminAccountPassword,
    [parameter(Mandatory = $false)][int]$DelayafterStartInSeconds = 15,
    [parameter(Mandatory = $false)][int]$DelayafterRestartInMinutes = 5,
    [parameter(Mandatory = $false)][switch]$NoShutdown
)

#Validate if hyper-v module is available, install when needed
if (-not (Get-Module -listAvailable -Name Hyper-V)) {
    Write-Warning "Hyper-V module is not installed, installing now..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell -NoRestart:$true
}

#Set credentials, prompt for admin password for the account specified in $AdminAccountName if not specified in $AdminAccountPassowrd
if (-not $AdminAccountPassword) {
    $password = Read-Host "Please enter password for the specified admin account" -AsSecureString
}
else {
    $password = $AdminAccountPassword | ConvertTo-SecureString -AsPlainText -Force
}
$AdminCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminAccountName, $password

#Validate if specified VM(s) is/are valid and running
foreach ($VM in Hyper-V\Get-VM $VMs | Sort-Object Name) {
    if (-not (Hyper-V\Get-VM -VMName $VM.Name -ErrorAction SilentlyContinue)) {
        Write-Warning ("Specified VM {0} can't be found, check spelling/name. Exiting..." -f $VM.Name)
        return
    }
        
    #Start VM is it was not started and wait X amount of seconds specified in $DelayAfterStart
    if (-not ((Hyper-V\Get-VM -Name $VM.Name).State -eq 'Running')) {
        Write-Warning ("Specified VM {0} was not started, starting now and waiting for {1} seconds..." -f $VM.Name, $DelayafterStartInSeconds)
        Hyper-V\Start-VM -Name $VM.Name
        Start-Sleep -Seconds $DelayafterStartInSeconds
    }

    #Connect to VM, install PSWindowsUpdate, install all updates found and reboot if needed and shutdown afterwards if $NoShutdown was not specified.
    Write-Host ("Checking/Installing updates on {0}" -f $VM.Name) -ForegroundColor Green
    try {
        Invoke-Command -VMName $VM.Name -Credential $AdminCredential -ScriptBlock {
            Write-Host ("Installing NuGet provider") -ForegroundColor Green
            Set-ExecutionPolicy Bypass
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force:$true | Out-Null
            Write-Host ("Installing PSWindowsUpdate module") -ForegroundColor Green
            Install-Module PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
            Import-Module PSWindowsUpdate
            Write-Host ("Installing Update(s) if any... System will reboot afterwards if needed!") -ForegroundColor Green
            Install-WindowsUpdate -Install -ForceInstall -AcceptAll -AutoReboot
        } 
    }
    catch {
        Write-Warning ("Couldn't connect to {0}, check credentials! Skipping..." -f $VM.Name)
    }

    #Wait for VM to restart after updates
    Write-Host ("Waiting for 15 seconds before continuing....") -ForegroundColor Green
    Start-Sleep -Seconds 15

    #Wait for the VM to have an uptime of more than one minute and shutdown the VM if $NoShutdown was not specified
    if (-not $NoShutdown) {
        while ((Hyper-V\Get-VM $VM.Name).Uptime.TotalMinutes -le $DelayafterRestartInMinutes) {
            Write-Host ("Waiting for {0} to be online for more than {1} minute(s), sleeping for 15 seconds...(Current uptime is {2} minutes and {3} seconds)" -f $VM.Name, $DelayafterRestartInMinutes, $(Hyper-V\Get-VM $VM.Name).Uptime.Minutes, $(Hyper-V\Get-VM $VM.Name).Uptime.Seconds) -ForegroundColor Green
            Start-Sleep -Seconds 15
        }
        #Stop VM after waiting to $DelayafterRestartInMinutes
        Write-Host ("Shutting down {0} now..." -f $VM.Name) -ForegroundColor Green
        Hyper-V\Stop-VM -VMName $VM.Name -Force:$true
    }
    else {
        Write-Host ("The -NoShutdown parameter was used, not shutting down {0}..." -f $VM.Name)
    }        
}