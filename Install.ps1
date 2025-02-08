#Requires -RunAsAdministrator

$IsAdmin = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Output "`n⚠️ Necesitas ejecutar el script como administrador" -ForegroundColor Green -BackgroundColor Black
}

Clear-Host

# Setup the execution policy and marking the PSGallery as a trusted source
Write-Output "`n⏳ Configurando la Politica de Ejecucion para el Usuario y Marcando el Repositorio PSGallery como Trusted - " -ForegroundColor Yellow -NoNewline; Write-Output "[01]" -ForegroundColor Green -BackgroundColor Black
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
catch { 
    Write-Warning $_ 
}

# Set PS profile
Write-Output "`n⏳ Aplicando el Perfil de PowerShell y generando su Directorio - " -ForegroundColor Yellow -NoNewline ; Write-Output "[02]" -ForegroundColor Green -BackgroundColor Black
try {
    $dest1 = "${env:USERPROFILE}\Documents\PowerShell"
    if (!(Test-Path -path ${dest1})) { [System.IO.Directory]::CreateDirectory(${dest1}) > $null }
    Copy-Item ".\src\profile.ps1" -Destination ${dest1} -Force
}
catch { 
    Write-Warning $_ 
}

# Winget installation
Write-Output "`n⏳ Instalancion de Winget desde Fuente - " -ForegroundColor Yellow -NoNewline; Write-Output "[03]" -ForegroundColor Green -BackgroundColor Black
try {
    function header {
        param (
            [string]$title
        )
        Write-Output "$($title)`n$('='*64)`n"
    }

    function AAP {
        param (
            [string]$pkg
        )
        Write-Output "  ⏳ Installing $($pkg)..."
        Add-AppxPackage -ErrorAction:SilentlyContinue $pkg
        Write-Output "  $($pkg) installed. Continuing...`n"
    }
    
    function InstallPrereqs {
        header -title "Installing winget-cli Prerequisites..."
        Write-Output "  ⏳ Downloading Microsoft.VCLibs.x64.14.00.Desktop.appx..."
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        Write-Output "  ⏳ Downloading Microsoft.UI.Xaml.2.7.x64.appx...`n"
        Write-Output "  ⏳ Downloading Microsoft.UI.Xaml.2.7.x64.appx...`n"
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
        AAP -pkg "Microsoft.VCLibs.x64.14.00.Desktop.appx"
        AAP -pkg "Microsoft.UI.Xaml.2.7.x64.appx"
    }
    
    function Get-LatestGitHubRelease {
        param (
            [int]$assetIndex
        )

        try {
            $response = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
            $latestVersion = $response.tag_name
            Write-Output "  Latest version:`t$($latestVersion)`n"
            $assetUrl = $response.assets[$assetIndex].browser_download_url
            Invoke-WebRequest -Uri $assetUrl -OutFile Microsoft.DesktopAppInstaller.msixbundle
        }
        catch {
            Write-Warning $_
        }
    }

    function WingetCheck {
        if (-not (Get-Command -ErrorAction SilentlyContinue winget)) {
            Write-Output "  ⚠️ No se encontro Winget se instalaran las dependencias...`n"
            InstallPrereqs
            Write-Output "  ⏳ Descargando winget-cli ...`n"
            Get-LatestGitHubRelease -assetIndex 2
            Write-Output "  ⏳ Instalando winget-cli ... `n"
            AAP -pkg "Microsoft.DesktopAppInstaller.msixbundle"
            Write-Output "  ⏳ Recargando las variables de entorno...`n"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }
    }
    WingetCheck

    # Function to check and install Chocolatey
    function Install-Choco {
        if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
            Write-Output "  ⚠️ No se encontro Chocolatey inicia su instalacion..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Output "  ✅ Chocolatey se instalo satisfactoriamente."
        }
        else {
            Write-Output "`n⚠️ Chocolatey ya esta instalado."
        }
        catch {
            Write-Warning $_
        }
    }    
    # Call the function to check/install Chocolatey
    Install-Choco

    function InstallApps {
        header -title "Instalando Aplicaciones..."
        $appsJson = ".\apps.json"
        Write-Output "  `t⏳ Instalando las aplicaciones de $(${appsJson})..."
        Winget import -i ${appsJson} --accept-source-agreements --accept-package-agreements --disable-interactivity
        Write-Output "  ✅ Se completo la instalacion de $(${appsJson})... Saliendo..."
    } 
    InstallApps
}
catch { 
    Write-Warning $_ 
}

# Update the help modules on Powershell
Write-Output "`n⏳ Actualizando todos los Modulos para Ayuda de PowerShell - " -ForegroundColor Yellow -NoNewline; Write-Output "[04]" -ForegroundColor Green -BackgroundColor Black
try {
    Update-Help -Force -Verbose
}
catch { 
    Write-Warning $_ 
}

# Installing Modules for updating, terminal icons and PSReadline keyboard shortcuts
Write-Output "`n⏳ Instalando Modulos y Paquetes - " -ForegroundColor Yellow -NoNewline; Write-Output "[05]" -ForegroundColor Green -BackgroundColor Black
try {
    Install-Module PSWindowsUpdate -Repository PSGallery -Scope AllUsers -SkipPublisherCheck -Force
    Import-Module PSWindowsUpdate -Scope Global
    Install-Module MSCatalog -Repository PSGallery -Scope AllUsers -SkipPublisherCheck -Force
    Import-Module MSCatalog -Scope Global
    Install-Module -Name npm-Completion -Repository PSGallery -Scope CurrentUser -SkipPublisherCheck
    Import-Module -Name npm-Completion
}
catch {
    Write-Warning $_ 
}

# Instalacion de fonts y glyphed fonts
Write-Output "`n⏳ Installing glyphed fonts All Nerd Fonts and Symbols - " -ForegroundColor Yellow -NoNewline ; Write-Output "[06]" -ForegroundColor Green -BackgroundColor Black
try {
    $shellObject = New-Object -ComObject shell.application
    $fonts = $ShellObject.NameSpace(0x14)
    $fontsToInstallDirectory = ".\src\fonts\*.*tf"
    $fontsToInstall = Get-ChildItem ${fontsToInstallDirectory} -Recurse -Include '*.*tf'
    foreach ($f in ${fontsToInstall}) {
        $fullPath = $f.FullName
        $name = $f.Name
        $userInstalledFonts = "${env:USERPROFILE}\AppData\Local\Microsoft\Windows\Fonts"
        if (!(Test-Path "${userInstalledFonts}\${name}")) {
            ${fonts}.CopyHere(${fullPath})
        }
        else {
            continue
        }
    }
}
catch { 
    Write-Warning $_ 
}

# Set WT settings.json
Write-Output "`n⏳ Aplicando la configuracion de Windows Terminal - " -ForegroundColor Yellow -NoNewline ; Write-Output "[07]" -ForegroundColor Green -BackgroundColor Black
try {
    $dest2 = "${env:LOCALAPPDATA}\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
    if (!(Test-Path -path ${dest2})) { New-Item -ItemType Directory ${dest2} -Force }
    Copy-Item ".\src\wt\settings.json" -Destination ${dest2} | Out-Null
}
catch {
    Write-Warning $_ 
}

try {
    $dest3 = "C:\Program Files\PowerShell\7"
    if (!(Test-Path -path ${dest3})) { New-Item -ItemType Directory ${dest3} -Force }
    Copy-Item ".\src\icons\win.png" -Destination ${dest3} | Out-Null
}
catch { 
    Write-Warning $_ 
}

Write-Output "`n⏳ Win Term icons Setup - " -ForegroundColor Yellow -NoNewline ; Write-Output "[08]" -ForegroundColor Green -BackgroundColor Black
try {
    $dest4 = "C:\temp\wt_assets"
    if (!(Test-Path -path ${dest4})) { New-Item -ItemType Directory ${dest4} -Force }
    [System.IO.Directory]::CreateDirectory(${dest4}) > $null
    Copy-Item ".\src\icons" -Recurse -Destination ${dest4} -Force
}
catch { 
    Write-Warning $_ 
}

# Crear el directorio de confiuraciones para otras herramientas como Glow, Glab, etc.
Write-Output "`n⏳ Crear el directorio de confiuraciones para otras Herramientas Glow, Glab, etc - " -ForegroundColor Yellow -NoNewline ; Write-Output "[09]" -ForegroundColor Green -BackgroundColor Black
try {
    $dest5 = "${env:USERPROFILE}\AppData\Local"
    $dest6 = "${env:USERPROFILE}\AppData\Roaming"
    Copy-Item ".\src\configs\glow" -Recurse -Destination ${dest5} -Force
    Copy-Item ".\src\configs\topgrade" -Recurse -Destination ${dest6} -Force
}
catch { 
    Write-Warning $_
}

try {
    $dest7 = "${env:USERPROFILE}\Pictures\"
    if (!(Test-Path -path ${dest7})) { New-Item -ItemType Directory ${dest7} -Force }
    Copy-Item ".\src\3k" -Recurse -Destination ${dest7} -Force
}
catch { 
    Write-Warning $_ 
}

try {
    $dest8 = "${env:USERPROFILE}\Documents\PowerShell\Scripts"
    if (!(Test-Path -path ${dest8})) { New-Item -ItemType Directory ${dest8} -Force }
    Copy-Item ".\src\winfetch" -Recurse -Destination ${dest8} -Force
}
catch { 
    Write-Warning $_ 
}

Write-Output "`n⏳Inicia la instalacion de WSL ..." -ForegroundColor Yellow -NoNewline

try {
    $StopWatch = [system.diagnostics.stopwatch]::startNew()

    Write-Output "`n⏳ Habilitando WSL ..." -ForegroundColor Yellow -NoNewline ; Write-Output "👉 [01]" -ForegroundColor Green -BackgroundColor Black
    & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    Write-Output "`n⏳ Habilitando VirtualMachiine Platform ..." -ForegroundColor Yellow -NoNewline ; Write-Output "👉 [02]" -ForegroundColor Green -BackgroundColor Black
    & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Write-Output "`n⏳ Actualizando el kernel de WSL ..."  -ForegroundColor Yellow -NoNewline ; Write-Output "👉 [03]" -ForegroundColor Green -BackgroundColor Black
    & wsl --update

    Write-Output "`n⏳ Habilitando la version 2 de WSL ..." -ForegroundColor Yellow -NoNewline ; Write-Output "👉 [04]" -ForegroundColor Green -BackgroundColor Black
    & wsl --set-default-version 2

    [int]$transcurrido = $StopWatch.Elapsed.TotalSeconds
    Write-Output "`n✅ Se instalo WSL en $transcurrido seg" -ForegroundColor Yellow -NoNewline ; Write-Output "`nNOTA: reinicia el equipo ahora para que tome efecto la habilitacion de WSL, despues visota o instalal desde powershell tu distribucion"
}
catch {
    Write-Warning $_
}

try {
    $StopWatch = [system.diagnostics.stopwatch]::startNew()
    $features = @(
        "VirtualMachinePlatform"
        "Containers"
        "Microsoft-Windows-Subsystem-Linux"
    )
    foreach ($feature in $features) {
        Write-Output "`t⏳ Habilitando: $feature" -ForegroundColor Magenta
        Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $feature
    }
    [int]$transcurrido = $StopWatch.Elapsed.TotalSeconds
    Write-Output "`n✅ Se Habilitaron en $transcurrido Segs" -ForegroundColor Yellow -NoNewline
} 
catch {
    Write-Warning $_
}


try {
    $StopWatch = [system.diagnostics.stopwatch]::startNew()
    $features = @(
        "SmbDirect"
        "Printing-Foundation-InternetPrinting-Client"
        "Printing-Foundation-Features"
        "WorkFolders-Client"
        "Microsoft-RemoteDesktopConnection"
    )
    foreach ($feature in $features) {
        Write-Output "`t⏳ Deshabilitando: $feature" -ForegroundColor Magenta
        Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $feature
    }
    [int]$transcurrido = $StopWatch.Elapsed.TotalSeconds
    Write-Output "`n✅ Se deshabilitaron $transcurrido Segs" -ForegroundColor Yellow -NoNewline
}
catch {
    Write-Warning $_
}

Write-Output "`n✅ Finalizaron las instalaciones y configuraciones" -ForegroundColor Yellow -NoNewline ; Write-Output "[10]" -ForegroundColor Green -BackgroundColor Black