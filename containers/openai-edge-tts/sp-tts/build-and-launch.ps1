<#
.SYNOPSIS
    Compila y ejecuta de manera detached una aplicacion.

.DESCRIPTION
    Usando docker build y docker run se compilara la
    aplicacion de openai-edge-tts para produccion de
    audio en espanol en base a texto.

.NOTES
    Name: build-and-launch.ps1
    Version: 0.1
    Author: Robbpaulsen
    Date: 03-01-2024
#>

Write-Host "Inicia 🚀⌛ la compilacion de la aplicacion OpenAI-Edge-TTS 👾🤖"

try {
    docker build --no-cache -t openai-edge-tts . 
} catch {
    Write-Warning -Message "☢️🚫Algo salio mal revisa los docker files $_ ☢️🚫"
}

Write-Host "✅ Se termino la compilacion 👾🤖"

Write-Host "⌛⌛Se Iniciara la ejecucion Detached del contenedor 🏗️⚓🐳"

try {
    docker run --name openai-edge-sp-tts -d -p 5050:5050 --restart unless-stopped --env-file .\.env openai-edge-tts
}
catch {
    Write-Warning -Message "☢️🚫No se ejecuto adecuadamente, intenta de nuevo $_ ☢️🚫"
}