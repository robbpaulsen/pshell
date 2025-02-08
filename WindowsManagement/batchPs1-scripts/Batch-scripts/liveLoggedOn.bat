:: Purpose:       Checks who's logged-on to a remote computer
::                Pings first to create an ARP entry, seems to lessen the chance of a timeout error.
:: Requirements:  Run this script with a network admin account
SETLOCAL
@echo off

:::::::::::::::
:: VARIABLES :: -------------- These are the defaults. Change them if you so desire. --------- ::
:::::::::::::::

:: Set method of querying remote system. Valid methods are:
::  - WMIC                (most reliable, however provides the least information)
::  - Windows_query_user  (requires Windows Vista and up; doesn't work on XP)
::  - PsLoggedon          (requires PsLoggedon.exe from sysinternals)
set METHOD=WMIC

:: --------------------------- Don't edit anything below this line --------------------------- ::



:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
@echo off
title Who's Logged On?
set TARGET=%1%
set SCRIPT_VERSION=1.7.1
set SCRIPT_UPDATED=2014-09-08
set RUNONCE=NO
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%


:::::::::::::::
:: EXECUTION ::
:::::::::::::::
if not '%1%'=='' set RUNONCE=YES && goto run_once
cls
echo.
echo  Check who's logged on to a remote computer.
echo.
echo  Available methods, from most reliable to least:
echo   - WMIC                Uses WMIC to query the remote system
echo   - Windows_query_user  Uses Windows' built-in "query user /SERVER:%TARGET%" command
echo                        (Your local PC must be running Windows Vista or 7 to use this)
echo   - PsLoggedon          Uses SysInternal's PsLoggedon.exe to query the remote system
echo.
echo  Currently set to use the '%METHOD%' method.
echo.
:loop
set /P TARGET= Check:
	if %TARGET%==exit goto end
:go
echo.
echo Checking %TARGET% using %METHOD%...
echo.
ping -n 1 %TARGET% >NUL
goto %METHOD%


::
:: Method #1: WMIC. Most accurate, usually works. Valid on XP and up.
::
:WMIC
WMIC /FAILFAST:on /NODE:"%TARGET%" computersystem GET name, username
::WMIC /FAILFAST:on /NODE:"%TARGET%" csproduct get vendor,name,identifyingnumber
if %ERRORLEVEL%==1 echo. && echo WMIC method failed. Trying Windows_query_user method... && echo. && goto Windows_query_user
if %RUNONCE%==YES (goto end) ELSE (goto loop)

::
:: Method #2: Windows built-in. Only available on Vista/7 to my knowledge. Provides the most information.
::
:Windows_query_user
query user /SERVER:%TARGET%
if %RUNONCE%==YES (goto end) ELSE (goto loop)

::
:: Method #3: SysInternals utility. Works most of the time. the PsLoggedon.exe file is required.
::
:PsLoggedon
PsLoggedon.exe -l \\%TARGET%
if %RUNONCE%==YES goto end


:run_once
echo.
echo Checking %TARGET% using %METHOD% method...
echo.
goto %METHOD%


:end
title %USERNAME%
