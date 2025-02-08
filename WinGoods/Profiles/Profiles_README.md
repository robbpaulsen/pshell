# Perfiles en PowerShell

Los Perfiles de PowerShell para personalizar el entorno y agregar elementos específicos de la sesión a cada sesión de PowerShell que inicie.

Un perfil de PowerShell es un script que se ejecuta cuando se inicia PowerShell. Puede usar el perfil como script de inicio para personalizar el entorno. Puede agregar comandos, alias, funciones, variables, módulos, unidades de PowerShell y mucho más. También puede agregar otros elementos específicos de la sesión al perfil para que estén disponibles en cada sesión sin tener que importarlos ni volver a crearlos.

PowerShell admite varios perfiles para usuarios y programas host. Sin embargo, no crea los perfiles automáticamente.

## Tipos y Ubicaciones de Perfiles

* Todos los usuarios, todos los hosts
>       Windows: $PSHOME\Profile.ps1
>       Linux: /opt/microsoft/powershell/7/profile.ps1
>       macOS: /usr/local/microsoft/powershell/7/profile.ps1
* Todos los usuarios, host actual
>       Windows: $PSHOME\Microsoft.PowerShell_profile.ps1
>       Linux: /opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
>       macOS: /usr/local/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
* Usuario actual, todos los hosts
>	Windows: $HOME\Documents\PowerShell\Profile.ps1
>       Linux: ~/.config/powershell/profile.ps1
>       macOS: ~/.config/powershell/profile.ps1
* Usuario actual, Host actual
>       Windows: $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
>       Linux: ~/.config/powershell/Microsoft.PowerShell_profile.ps1
>       macOS: ~/.config/powershell/Microsoft.PowerShell_profile.ps1


## La Variable $PROFILE

Dependiendo de que usuario seamos la variable $PROFILE marcara una ruta para ese perfil usado en el momento. Pero esta es la que definira los permisos apra la ejecucion de scripts firmados y no firmados, es parte de los permisos dentro del entorno, sin tanto rodeo lo que un usuario que desarrolla codigo y/o esta haciendo pruebas dentro del entron de Windows lo que busca es ubicar su peerfil en el `$PROFILE.CurrentUserAllHosts` , si sopias y pegas esta variable en tu terminal te dara esta ruta con este archivo `C:\Users\USUARIO\Documents\PowerShell\profile.ps1` , ahi queremos generar el perfil.

## Crear un perfil

Para crear un perfil en esa ubicacion y haciendo uso de una funcion que primero haga un test para comprobar si ya existe uno de lo contrario que lo genere, seria esta:

``` powershell

if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
  New-Item -ItemType File -Path $PROFILE.CurrentUserAllHosts -Force
}
```

Esto solo cubrira el como hacerlo en Windows, si estas en otro sistema operativo revisa la documentaicon oficial en !(learn.microsoft.com/es-es/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4)

## Ya tengo un Perfil y ahora que?

La funcion de arriba solo genera el archivo de un perfil pero esta vacio, que es lo que contiene un perfil? un perfil puede contener desde cutomizaciones propias, funciones, alias de commandos y mas herramientas
que pueden ser agregadas, aqui dejare un Ejemplo de las cosas que se pueden agregar a un perfil se llama `EXAMPLE_Microsoft.PowerShell_profile.ps1`.