# README.md

## Con este repositorio se llevará el tracking de las cosas y temas que estare aprendiendo con PowerShell en Windowos

Desde hace más de 5 años e estado aprendiendo Bash, la Shell general en Linux y ahora para complementar ese aprendizaje iniciaré el de PowerShell en Windows. Empezando por lo más general, PowerShell a diferencia de Bash/ZSH/FISH/ETC trata  su entorno y sus elementos como objetos más parecido a un lenguaje de programación, pero a un nivel muy básico en sintaxis, los beneficios de esto es que puede crear objetos y adaptar el entorno.

Su sintaxis se compone de un Verbo seguido por un Sustantivo que puede o no ir acompañado de algún Adjetivo, el término correcto es Descriptor, pero por simplicidad y siguiendo la semántica de como MicrosoftDocs lo explica lo dejaré así. PowerShell También tiene funciones, alias, administrador de paquetes, este no es nuevo, pero tampoco tan Viejo, se llama Winget/Nuget.

En un inicio a diferencia de una Shell en Linux powershell viene muy restringido, pero antes de saltar a como asignarle superpoderes de administrador, teleportacion y hechizos arcanos si tu usuario no quieres profundizar mucho en PowerShell y solo saber lo esencial aprende cuando, cuáles, en donde y como se usan los `$PROFILE` o "Perfiles" de PowerShell, ya que de un inicio parece demasiado sencillo, pero abre una cantidad exagerada de permisos por detrás inmensa aún más grande que solo teniendo al usuario `root` en Linux.

Existen 4 Perfiles de Usuario para PowerShell, cada perfil debe de tener un archivo de configuracion que por convención se llaman `Microsoft.PowerShell_profile.ps1`, otra convención es solo nombrarlo `profile.ps1`. No es regla que se tenga que tener los 4 perfiles el usuario dependiendo de su entorno y flow de trabajo puede hacer uso de hasta combinación de ellos, esto se hizo con la intención de peticionar los permisos y alcances que se puede tener, así dividir entre 4 es menos riesgo a tener todo en 1 solo perfil, o 2 o 3. Cada configuración de ubicarse en un lugar específico del entorno o `$env`. Como inicio y yo es el único que he estado usando y es el que más he comprobado que aún tiene seguridad en el entorno es este:

```powershell

PS1> $PRFILE.CurrentuserAllhosts
```

Esa línea nos regresará en texto plano la ubicación y el nombre que sugiere para la configuración del ese perfil:

```powershell
C:\Users\<YOURuser>\Documents\PowerShell\profile.ps1
```

Ese resultado no quiere decir que genero el perfil y que lo ubico ahí, solo señala en donde debe de ubicarse y un nombre convencional para darle, así que no batalles y copia y pega este OneLiner:

``` powershell
PS1> if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts )) { New-Item -ItemType File -Path $PROFILE.CurrentUserAllHosts -Force }
```

El archivo estará vacío, pero ya al menos guardará los permisos con los que podrás correr. Cierras esa terminal de PowerShell y abres una nueva y ejecutas este liner para activar el Perfil de Current User All Hosts:

``` powershell
PS1> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

En resumen el usuario actual que está en la sesión podrá invocar una sesión de PowerShell como administrador para hacer sus labores/trabajo/workflow/etc. y esto aplica en el host actual y si este usuario se mueve a otro host con su sesión de PowerShell mantendrá los permisos de procedencia, pero todos los demás usuarios, hosts y máquinas estarán con el perfil `undefined` y solo podrán usar PowerShell como usuario no administrador.

Credits:

* For all the Themes/CoorSchemes on Windows Terminal and various plus terminals <https://github.com/mbadolato/iTerm2-Color-Schemes>
* From WinUtil I managed to create my choco and winget installer function thanks to ![Chris Titus](https://github.com/ChrisTitusTech/winutil)

