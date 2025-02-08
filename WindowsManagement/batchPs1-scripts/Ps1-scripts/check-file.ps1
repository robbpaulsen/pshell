<#
.SYNOPSIS
        Checks a file
.DESCRIPTION
        This PowerShell script determines and prints the file type of the given file.
.PARAMETER Path
        Specifies the path to the file
.EXAMPLE
        PS> ./check-file C:\my.exe
.LINK
        https://github.com/fleschutz/PowerShell
.NOTES
        Author: Markus Fleschutz | License: CC0
#>

param([string]$Path = "")


function Check-Header { param( $path )
    $path = Resolve-Path $path

    # Hexidecimal signatures for expected files
    $known = @'
"Extension","Header"
"3gp","66 74 79 70 33 67"
"7z","37 7A BC AF 27 1C"
"8sv","38 53 56 58"
"8svx","46 4F 52 4D nn nn nn nn"
"aac","FF F1"
"acbm","46 4F 52 4D nn nn nn nn"
"ai","25 50 44 46"
"aif","41 49 46 46"
"aiff","46 4F 52 4D nn nn nn nn"
"anbm","46 4F 52 4D nn nn nn nn"
"anim","46 4F 52 4D nn nn nn nn "
"arj","60 EA"
"asf","30 26 B2 75 8E 66 CF 11"
"avi","52 49 46 46 nn nn nn nn "
"avi","52 49 46 46"
"bac","42 41 43 4B 4D 49 4B 45"
"bmp","42 4D"
"bpg","42 50 47 FB"
"cab","4D 53 43 46"
"cin","80 2A 5F D7"
"class","CA FE BA BE"
"cmus","46 4F 52 4D nn nn nn nn"
"cr2","49 49 2A 00 10 00 00 00 43 52"
"cr2","49 49 2A 00 10 00 00 00"
"crx","43 72 32 34"
"cur","00 00 02 00"
"cwk","05 07 00 00 42 4F 42 4F"
"cwk","06 07 E1 00 42 4F 42 4F"
"dat","50 4D 4F 43 43 4D 4F 43"
"db","00 06 15 61"
"DBA","00 01 42 44"
"DBA","BE BA FE CA"
"deb","21 3C 61 72 63 68 3E"
"dex","64 65 78 0A 30 33 35 00"
"djvu","41 54 26 54 46 4F 52 4D nn nn nn"
"dll","4D 5A"
"dmg","78 01 73 0D 62 62 60"
"dng","49 49 2A 00"
"doc","D0 CF 11 E0 A1 B1 1A E1"
"docx","50 4B 03 04"
"dpx","53 44 50 58"
"dwg","41 43 31 30"
"elf","7F 45 4C 46"
"eot","00 01 00 00"
"eps","C5 D0 D3 C6"
"epub","50 4B 03 04 0A 00 02 00"
"exe","4D 5A"
"exr","76 2F 31 01"
"fax","46 41 58 58"
"faxx","46 4F 52 4D nn nn nn nn"
"fh8","41 47 44 33"
"fits","53 49 4D 50 4C 45 20 20"
"flac","66 4C 61 43"
"flif","46 4C 49 46"
"flv","46 4C 56 01"
"ftxt","46 4F 52 4D nn nn nn nn"
"gif","47 49 46 38 37 61"
"gif","47 49 46 38 39 61"
"icns","69 63 6E 73"
"ico","00 00 01 00"
"idx","49 4E 44 58"
"iff","41 43 42 4D"
"iff","41 4E 42 4D"
"iff","41 4E 49 4D"
"iff","46 4F 52 4D nn nn nn nn"
"ilbm","46 4F 52 4D nn nn nn nn"
"iso","43 44 30 30 31"
"jp2","00 00 00 0C 6A 50 20 20 0D 0A 87"
"jpc","00 00 00 0C 6A 50 20 20"
"jpeg","FF D8 FF E0"
"jpg","FF D8 FF DB"
"jpg","FF D8 FF E0"
"lbm","49 4C 42 4D"
"lz","4C 5A 49 50"
"lz4","04 22 4D 18"
"mid","4D 54 68 64"
"mkv","1A 45 DF A3"
"MLV","4D 4C 56 49"
"mov","00 00 00 14 66 74 79 70 71 74 20"
"mp3","49 44 33"
"mp4","00 00 00 18 66 74 79 70 6D 70 34"
"msg","D0 CF 11 E0 A1 B1 1A E1"
"mus","43 4D 55 53"
"nes","4E 45 53 1A"
"ods","50 4B 05 06"
"ogg","4F 67 67 53"
"otf","4F 54 54 4F 00 01"
"PDB","00 00 00 00 00 00 00 00"
"pdf","25 50 44 46"
"png","89 50 4E 47 0D 0A 1A 0A"
"ppt","D0 CF 11 E0 A1 B1 1A E1"
"pptx","50 4B 03 04"
"ps","25 21 50 53"
"psd","38 42 50 53"
"rar","52 61 72 21 1A 07 00"
"rar","52 61 72 21 1A 07 01 00"
"rpm","ED AB EE DB"
"smu","53 4D 55 53"
"smus","46 4F 52 4D nn nn nn nn"
"sqlite","53 51 4C 69 74 65 20 66 6F 72 6D"
"stg","4D 49 4C 20"
"swf","43 57 53"
"tar","75 73 74 61 72 00 30 30"
"tar","75 73 74 61 72"
"TDA","00 01 44 54"
"tif","49 49 2A 00"
"tiff","4D 4D 00 2A"
"toast","45 52 02 00 00 00"
"torrent","64 38 3A 61 6E 6E 6F 75"
"tox","74 6F 78 33"
"ttf","00 01 00 00 00"
"txt","46 54 58 54"
"vsdx","50 4B 07 08"
"wav","52 49 46 46 nn nn nn nn"
"wav","52 49 46 46"
"wma","A6 D9 00 AA 00 62 CE 6C"
"wmv","30 26 B2 75 8E 66 CF 11"
"woff","77 4F 46 46"
"woff2","77 4F 46 32"
"xar","78 61 72 21"
"xls","D0 CF 11 E0 A1 B1 1A E1"
"xlsx","50 4B 03 04"
"yuv","59 55 56 4E"
"yuvn","46 4F 52 4D nn nn nn nn"
"zip","50 4B 03 04"
'@ | ConvertFrom-Csv | sort {$_.header.length} -Descending
    
    $known | % {$_.header = $_.header -replace '\s'}
    
    try {
        # Get content of each file (up to 4 bytes) for analysis
        $HeaderAsHexString = New-Object System.Text.StringBuilder
        [Byte[]](Get-Content -Path $path -TotalCount 4 -Encoding Byte -ea Stop) | % {
            if (("{0:X}" -f $_).length -eq 1) {
                $null = $HeaderAsHexString.Append('0{0:X}' -f $_)
            } else {
                $null = $HeaderAsHexString.Append('{0:X}' -f $_)
            }
        }
      
        # Validate file header
        # might change .startswith() to -match.
        # might remove 'select -f 1' to get all possible matching extensions, or just somehow make it a better match.
        $known | ? {$_.header.startswith($HeaderAsHexString.ToString())} | select -f 1 | % {$_.extension}
    } catch {}
}

Check-Header $Path