:::::::::::::::
:: VARIABLES :: --  Set these
:::::::::::::::

:: Which user to enable RDP for
set RDP_USER=vocatus

:: Connection timeout (in seconds)
set TIMEOUT=4


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
set SCRIPT_VERSION=1.7.0
set SCRIPT_UPDATED=2020-07-22
:: Get the date into ISO 8601 standard format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%
set TARGET=%1%
title RDP Enabler v%SCRIPT_VERSION%