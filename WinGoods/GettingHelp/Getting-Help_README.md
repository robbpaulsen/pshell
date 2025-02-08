# ========== Antes de Avanzar ========== #

Antes de seguir avanzando, cuando se instala windows se instala todo lo necesario depediendo de tu metodo de tu instalacion, pero todo esta ahi para el 
usuario, aun que no se tenga acceso, lo que sucede es que no esta completamente desplegado, en el caso de los Modulos de ayuda de PowerShell para todos
los comandos primero debemos ejecutar este comando para actualizar la base de Ayuda de PowerShell, ponerla al dia con la base en linea y que se generen todos lo modoulos de ayuda en formato apto para la terminal:

``` pwoershell

Update-Help Microsoft.PowerShell.Utility -Force
```

Ya que termine se podran visualizar todos los modulos de ayuda para los cmdlets de PowerShell. Abajo dejare un Script que generara todos los modulos de ayuda sino existen y/o los actualizara con la base en linea aparte de esto generara un Hash para cada modulo para revisar si hay alguna actualizacion nueva a futuro, Guardarlo como `Get-UpdateHelpVersion.ps1`:

``` pwoershell
Param(
    [parameter(Mandatory=$False)]
    [String[]]
    $Module
)
$HelpInfoNamespace = @{helpInfo='http://schemas.microsoft.com/powershell/help/2010/05'}

if ($Module) { $Modules = Get-Module $Module -ListAvailable | where {$_.HelpInfoUri} }
else { $Modules = Get-Module -ListAvailable | where {$_.HelpInfoUri} }

foreach ($mModule in $Modules)
{
    $mDir = $mModule.ModuleBase

    if (Test-Path $mdir\*helpinfo.xml)
    {
        $mName=$mModule.Name
        $mNodes = dir $mdir\*helpinfo.xml -ErrorAction SilentlyContinue |
            Select-Xml -Namespace $HelpInfoNamespace -XPath "//helpInfo:UICulture"
        foreach ($mNode in $mNodes)
        {
            $mCulture=$mNode.Node.UICultureName
            $mVer=$mNode.Node.UICultureVersion

            [PSCustomObject]@{"ModuleName"=$mName; "Culture"=$mCulture; "Version"=$mVer}
        }
    }
}
```

### Syntaxis para Pedir Ayuda a un modulo

El cmdlet general para pedir ayuda sobre algun comando es `Get-Help`, este modulo tambien acepta `WildCards` haciendo uso de los "*'s" , Ejemplo:

``` powershell

Get-Help *service*
```

Esto nos regresara todos los cmdlets que contienen la palabra "service" :

```
Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
Get-Service                       Cmdlet    Microsoft.PowerShell.Man… Gets the services on the computer.
New-Service                       Cmdlet    Microsoft.PowerShell.Man… Creates a new Windows service.
Remove-Service                    Cmdlet    Microsoft.PowerShell.Man… Removes a Windows service.
Restart-Service                   Cmdlet    Microsoft.PowerShell.Man… Stops and then starts one or more services.
Resume-Service                    Cmdlet    Microsoft.PowerShell.Man… Resumes one or more suspended (paused) services.
Set-Service                       Cmdlet    Microsoft.PowerShell.Man… Starts, stops, and suspends a service, and changes its properties.
Start-Service                     Cmdlet    Microsoft.PowerShell.Man… Starts one or more stopped services.
Stop-Service                      Cmdlet    Microsoft.PowerShell.Man… Stops one or more running services.
Suspend-Service                   Cmdlet    Microsoft.PowerShell.Man… Suspends (pauses) one or more running services.
Add-WUServiceManager              Cmdlet    PSWindowsUpdate           Add-WUServiceManager…
Get-WUServiceManager              Cmdlet    PSWindowsUpdate           Get-WUServiceManager…
Remove-WUServiceManager           Cmdlet    PSWindowsUpdate           Remove-WUServiceManager…
Enable-VMIntegrationService       Cmdlet    Hyper-V                   Enable-VMIntegrationService…
Get-VMIntegrationService          Cmdlet    Hyper-V                   Get-VMIntegrationService…
Disable-VMIntegrationService      Cmdlet    Hyper-V                   Disable-VMIntegrationService…
Set-NetFirewallServiceFilter      Function  NetSecurity               …
Get-NetFirewallServiceFilter      Function  NetSecurity               …
```

El cmndlet `Get-Help` tambien se le puede especificar el nombre del cmdlet con el falg "-Name"

``` powershell

Get-Help -Name Get-Help
```

Agregando el flag `-Detailed` dara una ayuda mas detallada del cmdlet:

``` powershell

Get-Help -Name Get-Help -Detailed
```

Aparte de `-Detailed` , tambein existe `-Full` y `-Examples`, que agregaran mas y mas detalle al cmdlet y aparte Ejemplos practicos que se tengan

``` powershell

Get-Help -Name Get-Help -Examples
```

``` powershell

Get-Help -Name Get-Help -Full
```

Esta es un ventaja muy grande sobre otras Shells, como Bash, que aun que tieene manuales muy extensos que lo que carece son ejemplos, cuando 
el usuario aun no entiende por completo un uso practico.

###### Soy usuario de Linux y no quiero que esto se mal entienda a una mala critica de la Bash Shell o su manual, como usuario de linux prefiero usar la Bash Shell, esto es solo para fines ded explicacion.