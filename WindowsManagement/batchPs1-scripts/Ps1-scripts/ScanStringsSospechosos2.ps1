<#
.SYNOPSIS
	Scan Recursively for Obfuscation
.DESCRIPTION
	This PowerShell script Scans by string patterns  possible obfuscated files recursively
    in certain paths
.EXAMPLE
	PS> .\ScanStringsSospechosos.ps1
.LINK
	https://gitlab.com/robbpaulsen/pshell/WindowsManagement/batchPs1-scripts/Ps1-scripts
.NOTES
	Author: robbpaulsen
#>
# Definir los strings sospechosos que queremos buscar
$strings = @('Invoke-WebRequest', 'Start-Process', 'IEX', 'cmd.exe', 'powershell.exe', 'Base64', 'Decode', 'Invoke', 'Reflective', 'Shellcode', 'svchost', 'explorer', 'lsass', 'winlogon', 'dllhost', 'taskhost')

# Definir rutas de búsqueda
$paths = @('C:\Windows\Temp', 'C:\Windows\System32', 'C:\Windows\SysWOW64', 'C:\Users\*\AppData', 'C:\Users\*\AppData\Local\Temp', 'C:\ProgramData')

# Iniciar contador de tiempo
$startTime = [datetime]::Now

# Recorrer las rutas especificadas
foreach ($path in $paths) {
    # Obtener todos los archivos a procesar y contar el total para la barra de progreso
    $files = Get-ChildItem -Path $path -Recurse -Include *.exe, *.dll, *.ps1, *.bat, *.vbs -ErrorAction SilentlyContinue
    $totalFiles = $files.Count
    $currentFile = 0

    foreach ($file in $files) {
        # Actualizar barra de progreso
        $progress = [math]::Round(($currentFile / $totalFiles) * 100, 2)
        Write-Progress -Activity "Escaneando archivos en $path" -Status "Progreso: $progress%" -PercentComplete $progress
        
        # Leer contenido del archivo y buscar los strings
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        $foundStrings = @{} # Diccionario para contar ocurrencias en cada archivo

        foreach ($string in $strings) {
            # Contar ocurrencias del string en el archivo
            $matchCount = ([regex]::Matches($content, [regex]::Escape($string))).Count
            if ($matchCount -gt 0) {
                # Si se encontró el string, guardarlo en el diccionario con el contador
                $foundStrings[$string] = $matchCount
            }
        }

        # Si se encontraron strings en el archivo, mostrar resultados
        if ($foundStrings.Count -gt 0) {
            Write-Output "Archivo: $($file.FullName)"
            foreach ($key in $foundStrings.Keys) {
                Write-Output "  '$key' encontrado $($foundStrings[$key]) veces"
            }
        }

        # Incrementar contador de archivo procesado
        $currentFile++
    }
}

# Calcular y mostrar el tiempo total transcurrido
$endTime = [datetime]::Now
$elapsedTime = $endTime - $startTime
Write-Output "Tiempo total transcurrido: $($elapsedTime.Hours)h:$($elapsedTime.Minutes)m:$($elapsedTime.Seconds)s"
