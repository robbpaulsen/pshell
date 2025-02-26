
<# ======================== COLSOLE QR CODE GENERATOR ==================================
 
SYNOPSIS
Use 'chart.googleapis.com' to create a qrcode then represent the qrcode in the console!

USAGE
1. Run script
2. Enter text or url to generate
3. Choose invert colors or not
4. Check console for results
#>

Add-Type -AssemblyName System.Drawing
[Console]::BackgroundColor = "Black"
[Console]::SetWindowSize(90, 40)
[Console]::Title = "QR Code Generator"
[Console]::CursorVisible = $false
cls

function Generate-QRCodeURL {
    param ([string]$URL,[int]$sizePercentage = 25)
    $EncodedURL = [uri]::EscapeDataString($URL)
    $newSize = [math]::Round((300 * $sizePercentage) / 100)
    $QRCodeURL = "https://chart.googleapis.com/chart?chs=${newSize}x${newSize}&cht=qr&chl=$EncodedURL"
    return $QRCodeURL
}

$URL = read-host "Text or URL to encode "
$highC = Read-Host "High contrast (y/n)"
$inverse = Read-Host "Invert colors (y/n)"
$QRCodeURL = Generate-QRCodeURL -URL $URL

function Download-QRCodeImage {
    param ([string]$QRCodeURL)
    $TempFile = [System.IO.Path]::GetTempFileName() + ".png"
    Invoke-WebRequest -Uri $QRCodeURL -OutFile $TempFile
    return $TempFile
}

$QRCodeURL = Generate-QRCodeURL -URL $URL
$QRCodeImageFile = Download-QRCodeImage -QRCodeURL $QRCodeURL
$QRCodeImage = [System.Drawing.Image]::FromFile($QRCodeImageFile)
$Bitmap = New-Object System.Drawing.Bitmap($QRCodeImage)

if (($highC -eq 'n') -and ($inverse -eq 'y')){
    $Chars = @('░', '█')
}
elseif (($highC -eq 'n') -and ($inverse -eq 'n')){
    $Chars = @('█', '░')
}

if (($highC -eq 'y') -and ($inverse -eq 'y')){
$Chars = @(' ', '█')
}
elseif (($highC -eq 'y') -and ($inverse -eq 'n')){
$Chars = @('█', ' ')
}

for ($y = 0; $y -lt $Bitmap.Height; $y += 2) {
    for ($x = 0; $x -lt $Bitmap.Width; $x++) {
        $Index = if ($Bitmap.GetPixel($x, $y).ToArgb() -eq -16777216) { 1 } else { 0 }  # Check if the pixel is black or white
        Write-Host -NoNewline $Chars[$Index]
    }
    Write-Host
}

$QRCodeImage.Dispose()
Remove-Item -Path $QRCodeImageFile -Force
pause
