@echo off
setlocal enabledelayedexpansion

REM Get the absolute AppData path regardless of where script is run
set "BASE_PATH=%LOCALAPPDATA%\..\LocalLow\Cygames"
set "UMA_FOLDER=%BASE_PATH%\umamusume"
set "UMA_JP=%BASE_PATH%\umamusume_jp"
set "UMA_GLOBAL=%BASE_PATH%\umamusume_global"

echo.
echo === Umamusume PC Server Switcher ===

REM Make sure base path exists
if not exist "!BASE_PATH!" (
    echo Error: Cygames folder not found at !BASE_PATH!
    goto end
)

if exist "!UMA_JP!" if exist "!UMA_GLOBAL!" (
    echo Both JP and Global versions detected.
    echo Please choose which version to activate.
    set /p version=Type JP or Global: 

    if /i "!version!"=="JP" (
        goto switch_to_jp
    ) else if /i "!version!"=="Global" (
        goto switch_to_global
    ) else (
        echo Invalid input. Cancelled.
        goto end
    )
)

REM Case 2: No main folder — restore from backups
if not exist "!UMA_FOLDER!" (
    if exist "!UMA_JP!" (
        echo No active version. Restoring JP...
        rename "!UMA_JP!" umamusume
        echo ✅ JP version is now active.
        goto end
    )
    if exist "!UMA_GLOBAL!" (
        echo No active version. Restoring Global...
        rename "!UMA_GLOBAL!" umamusume
        echo ✅ Global version is now active.
        goto end
    )
)

if not exist "!UMA_FOLDER!" if not exist "!UMA_JP!" if not exist "!UMA_GLOBAL!" (
    echo ⚠️ No Umamusume folder found at all. Nothing to switch.
    goto end
)

if exist "!UMA_JP!" (
    echo Detected active version: Global
)

if exist "!UMA_GLOBAL!" (
    echo Detected active version: JP
)

set /p confirm=Do you want to switch? (Y/N): 
if /i not "!confirm!"=="Y" (
    echo Cancelled.
    goto end
)

REM Case 1: Main folder exists
if exist "!UMA_FOLDER!" (
    echo Detected active umamusume
    if exist "!UMA_GLOBAL!" (
        echo Switching JP → Global...
        rename "!UMA_FOLDER!" umamusume_jp
        rename "!UMA_GLOBAL!" umamusume
        echo ✅ Global version is now active.
        goto end
    )
    if exist "!UMA_JP!" (
        echo Switching Global → JP...
        rename "!UMA_FOLDER!" umamusume_global
        rename "!UMA_JP!" umamusume
        echo ✅ JP version is now active.
        goto end
    )
    echo ⚠️ No backup found. Cannot switch.
    goto end
)

:switch_to_jp
    rename "!UMA_GLOBAL!" umamusume_global
    rename "!UMA_JP!" umamusume
    echo ✅ Switched to JP.
    goto end

:switch_to_global
    rename "!UMA_JP!" umamusume_jp
    rename "!UMA_GLOBAL!" umamusume
    echo ✅ Switched to Global.
    goto end

:end
echo.
pause