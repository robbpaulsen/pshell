:::::::::::::::
:: VARIABLES :: -------------- These are the defaults. Change them if you so desire. --------- ::
:::::::::::::::
:: Rules for variables:
::  * NO quotes!                       (bad:  "c:\directory\path"       )
::  * NO trailing slashes on the path! (bad:   c:\directory\            )
::  * Spaces are okay                  (okay:  c:\my folder\with spaces )
::  * Network paths are okay           (okay:  \\server\share name      )
::                                     (       \\172.16.1.5\share name  )

:: no user-set variables for this script

:: --------------------------- Don't edit anything below this line --------------------------- ::


:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-08-28


:::::::::::::
:: EXECUTE ::
:::::::::::::
echo.
echo  Attempt to repair Windows Update?
echo.
pause

:: Start the repair
net stop bits 2>NUL
net stop wuauserv 2>NUL
net stop cryptsvc 2>NUL

:: Cleanup directories
Del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
Rmdir "%Windir%\SoftwareDistribution\Download" /s /q
Rmdir "%systemroot%\SoftwareDistribution\DataStore" /s /q
Rmdir "%systemroot%\system32\catroot2" /s /q

:: Windows XP & 2003 - Delete %systemroot%\SoftwareDistribution\ as well                               C;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
pushd /d %windir%\system32;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRmsxml2,msxml3,Browseui,shell32,wuapi,wuaueng,wuaueng1,wucltui,wups,wuweb,jscript,atl,Mssip32) do (
        regsvr32 %%i.dll /s,msjava,jscript,msxml,actxprxy,shdocvw) do (
)       regsvr32 c:\windows\system32\%%i.dll /s
)c.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;A
netsh reset winsock
proxycfg.exe -dpi,wuaueng1,wuaueng,wucltui,wups2,wups,wuweb,Softpub,Mssip32,Initpki,softpub,wintrust,ini

:: Restart services
net start wuauserv
net start bits
net start cryptsvc

bitsadmin.exe /reset /allusers
wuauclt /resetauthorization /detectnow

popd