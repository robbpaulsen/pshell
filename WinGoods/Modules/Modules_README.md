# Modulos en PowerShell

Un módulo es una unidad reutilizable independiente que puede contener cmdlets, proveedores, funciones, variables y otros tipos de recursos que se pueden importar como una sola unidad.

PowerShell incluye un conjunto base de módulos. También puede instalar más módulos según sea necesario. De forma predeterminada, los módulos instalados se cargan automáticamente la primera vez que se usa un comando desde un módulo. Use la $PSModuleAutoloadingPreference variable para habilitar, deshabilitar y configurar la carga automática de módulos.

Puede descargar o volver a cargar durante una sesión. Use el Remove-Module cmdlet para descargar un módulo de la sesión. Use el `Import-Module` cmdlet para cargar un módulo.

## Instalación de un módulo publicado

Un módulo publicado es un módulo que está disponible en un repositorio registrado, como el Galería de PowerShell. Los módulos PowerShellGet y Microsoft.PowerShell.PSResourceGet proporcionan cmdlets para buscar, instalar y publicar módulos de PowerShell en un repositorio registrado.

El módulo PowerShellGet se incluye con PowerShell 5.0 y versiones posteriores. El módulo Microsoft.PowerShell.PSResourceGet se incluye con PowerShell 7.4 y versiones posteriores. Microsoft.PowerShell.PSResourceGet es el nuevo administrador de paquetes preferido para PowerShell y se puede instalar en versiones anteriores de PowerShell. Use el `Install-Module` cmdlet o `Install-PSResource` para instalar módulos desde el Galería de PowerShell.

### Instalación manual de un módulo

Si recibe un módulo como una carpeta con archivos en él, debe instalarlo en el equipo para poder usarlo en PowerShell.

PowerShell incluye varios módulos preinstalados. En los equipos basados en Windows, muchas características de Windows incluyen módulos para administrar la característica. Esos módulos se instalan cuando se instala la característica. Otros módulos pueden aparecer en un programa de instalación o instalador que instala el módulo.

De forma predeterminada, la Modules carpeta del usuario actual no existe. Si instaló un módulo en el CurrentUser ámbito mediante `Install-Module` o `Install-PSResource`, esos cmdlets crean la Modules carpeta para el usuario actual. Si la carpeta no existe, puede crearla manualmente.

Use el siguiente comando para crear una Modules carpeta para el usuario actual:

``` powershell

$folder = New-Item -Type Directory -Path $HOME\Documents\PowerShell\Modules
```

Copie toda la carpeta del módulo en la nueva carpeta creada. En PowerShell, use el Copy-Item cmdlet . Por ejemplo, ejecute el siguiente comando para copiar la MyModule carpeta de C:\PSTest a la carpeta que acaba de crear:

``` powershell

Copy-Item -Path C:\PSTest\MyModule -Destination $folder
```

### Carga automática de módulos

La primera vez que ejecute un comando desde un módulo instalado, PowerShell importa (carga) automáticamente ese módulo. El módulo debe almacenarse en las ubicaciones especificadas en la variable de $env:PSModulePath entorno. Los módulos de otras ubicaciones deben importarse mediante el `Import-Module` cmdlet.


* Ejcutar el comando:

``` powershell

Get-CimInstance Win32_OperatingSystem
```

* Obtener el comando

``` powershell

Get-Command Get-CimInstance
```

* Obtener ayuda para el comando

``` powershell

Get-Help Get-CimInstance
```

### Importación manual de un módulo

La importación manual de un módulo es necesaria cuando un módulo no está instalado en las ubicaciones especificadas por la $env:PSModulePath variable de entorno, o cuando el módulo se proporciona como un .dll archivo o .psm1 independiente, en lugar de un módulo empaquetado.

Puede importar un módulo que esté instalado en $env:PSModulePath si especifica el nombre del módulo. Por ejemplo, el siguiente comando importa el módulo BitsTransfer a la sesión actual.


``` powershell

Import-Module BitsTransfer
```

Para importar un módulo que no está en $env:PSModulePath, use la ruta de acceso completa a la carpeta del módulo. Por ejemplo, para agregar el módulo TestCmdlets en el directorio a la C:\ps-test sesión, escriba:

``` powershell

Import-Module C:\ps-test\TestCmdlets
```

Para importar un archivo de módulo que no está incluido en una carpeta de módulos, use la ruta de acceso completa al archivo de módulo en el comando . Por ejemplo, para agregar el módulo TestCmdlets.dll en el directorio a la C:\ps-test sesión, escriba:

``` powershell

Import-Module C:\ps-test\TestCmdlets.dll
```

### Importación de un módulo al principio de cada sesión

El `Import-Module` comando importa módulos a la sesión actual de PowerShell. Para importar un módulo en cada sesión de PowerShell que inicie, agregue el `Import-Module` comando al perfil de PowerShell.

### Búsqueda de módulos instalados

Enumerar los modulos disponible spara el usuario en sesion:

``` powershell

Get-Module
```

Enumerar todo los modulos disponibles en el sistema:

``` powershell

Get-Module -ListAvailable
```

### Enumeración de los comandos de un módulo

Primero y antes dee buscar todos los comandos que un modulo contiene en muchas ocasiones el modulo recien instalado no tiene el mismo nombre con el cual fue instalado, si este es tu caso
haz una busqueda de entre todos los modulos instalados haciendo uso de un "WildCard" com con el cmndlet `Get-Command`, la implementacion para modulos es igual:

``` powershell

Get-Module *POSSIBLEmoduleNAME*

Get-Module *WindowsUpdate*
```

Ya despues usa el `Get-Command` cmdlet para buscar todos los comandos disponibles. Puede usar los parámetros del `Get-Command` cmdlet para filtrar comandos como por módulo, nombre y nombre.


``` powershell 

Get-Command -Module <module-name>
```

``` powershell

Get-Command -Module BitsTransfer
```

Tambien muchos modulos en especial los que se pueden descargar del "PSGallery" deben de cumplir con ciertos estandares como el incluir un archivo XML para ayuda, asi que
la mayoria ya tiene un manual aun que sea del menu de ayuda minimo:

``` powershell

Get-Help -Name <FullNameOfModule>

Get-Help -Name Get-WindowsUpdate -Full
```

### Modulos, Recursos y Paquetes

En la misma PSGallery o en Github llegfaremos a encontrar modulos que no se instalan con el cmdlet `Install-Module` ahora es un `Install-Resource` estos dos cmdlets instalan modulos, cada uno tiene
sus atributos, pros y contras diferentes que es decision de cada usuario cual usar solo revisar bieni la documentacion para hacer uso del mismo, em cambio el cmdlet `Install-Package` es nativo de
Microsoft y se presenta cuando se instalan o habilitan cualidades de un Servidor Windows, Data Center y/o Windows Enterprise que estan mas sujetos al uso de proveedores de paqueteria/software
de proveedores dados de alta con Microsoft asi que solo para proyectos especificos se podran ver o usar aparte de que solo se ejecutan dos veces:

- Para Habilitar/Instalar lo requerido
- Para Desinstalar/Deshabilitar lo que ya no se requiere