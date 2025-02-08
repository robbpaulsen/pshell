# Funciones en PowerShell

Si escribes scripts o comandos únicos tipo One Liners de PowerShell y te encuentras escribiendolos una y otra vez y que a menudo tiene que modificarlos para distintos escenarios, es bastante probable que sean buenos candidatos para convertirlos en una función que se pueda volver a usar.

Nomenclatura

Al asignar nombres a las funciones de PowerShell, use un nombre en Pascal case con un verbo aprobado y un sustantivo en singular. También recomiendo agregar un prefijo al nombre. Por ejemplo: <ApprovedVerb>-<Prefix><SingularNoun>.

En PowerShell hay una lista específica de verbos aprobados que se pueden obtener mediante la ejecución de Get-Verb.

``` powershell

Get-Verb | Sort-Object -Property Verb
```

###### OutPut

``` powershell

Verb        Group
----        -----

Add         Common
Approve     Lifecycle
Assert      Lifecycle
Backup      Data
Block       Security
Checkpoint  Data
Clear       Common
Close       Common
Compare     Data
Complete    Lifecycle
Compress    Data
Confirm     Lifecycle
Connect     Communications
Convert     Data
ConvertFrom Data
ConvertTo   Data
Copy        Common
Debug       Diagnostic
Deny        Lifecycle
Disable     Lifecycle
Disconnect  Communications
Dismount    Data
Edit        Data
Enable      Lifecycle
Enter       Common
Exit        Common
Expand      Data
Export      Data
Find        Common
Format      Common
Get         Common
Grant       Security
Group       Data
Hide        Common
Import      Data
Initialize  Data
```

### Syntaxis de las funciones en PowerShell

``` powershell

function Get-Version {
    $PSVersionTable.PSVersion
}
```

Esta funcion devuelve a pantalla la version de powershell de la sesion actual.

### Conflictos con CmdLets y Modulos Existentes

Llegara la ocasion en la que el nombre que se asigno a la funcion creada tendra conflicto con alguna ya en el sistema por lo que es recomendado agregar "PS" en la parte del sustantivo


``` powershell

function Get-PSVersion {
    $PSVersionTable.PSVersion
}
```

### Cerrando la terminal de Powershell

Al cerrar la terminal y abrir una nueva sesion la funcion que habiamos cargado a memoria ya no existira, si lo que se busca es que esta sea tenga persistencia independiente de cad sesion es mejor agregar la funcion al perfil de PowerShell que se este usando para eso revisar la seccion de "Profile".