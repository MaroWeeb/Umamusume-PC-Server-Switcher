    @echo off
    setlocal enabledelayedexpansion

    REM Get the absolute AppData path regardless of where script is run
    set "BASE_PATH=%LOCALAPPDATA%\..\LocalLow\Cygames"
    set "UMA_FOLDER=%BASE_PATH%\umamusume"
    set "UMA_JP=%BASE_PATH%\umamusume_jp"
    set "UMA_GLOBAL=%BASE_PATH%\umamusume_global"

    echo.
    echo === Umamusume PC Server Switcher ===
    echo.

    REM Make sure base path exists
    if not exist "!BASE_PATH!" (
        echo ❌ Error: Cygames folder not found at !BASE_PATH!
        goto end
    )

    REM If both backups exist, ask user to choose what to activate
    if exist "!UMA_JP!" if exist "!UMA_GLOBAL!" (
    echo Both JP and Global versions detected.
    echo Please choose which version to activate.
    :choose_version
    set /p version=Type JP or Global: 

    if /i "!version!"=="JP" (
        goto switch_to_jp
    ) else if /i "!version!"=="Global" (
        goto switch_to_global
    ) else (
        echo Invalid input. Please type JP or Global.
        goto choose_version
    )
)

    REM Case: No main folder — restore from backups
    if not exist "!UMA_FOLDER!" (
        if exist "!UMA_JP!" (
            echo No active version. Restoring JP...
            rename "!UMA_JP!" umamusume
            echo ✅ JP version is now active!!!!!!!!!!!
            goto switch_to_jp
        )
        if exist "!UMA_GLOBAL!" (
            echo No active version. Restoring Global...
            rename "!UMA_GLOBAL!" umamusume
            echo ✅ Global version is now active!
            goto switch_to_global
        )
    )

    REM Case: No folders at all
    if not exist "!UMA_FOLDER!" if not exist "!UMA_JP!" if not exist "!UMA_GLOBAL!" (
        echo ⚠️ No Umamusume folder found at all. Nothing to switch.
        goto end
    )

    REM Show currently active version
    if exist "!UMA_JP!" (
        echo Detected active version: Global
    )
    if exist "!UMA_GLOBAL!" (
        echo Detected active version: JP
    )

    REM Confirm before switching
    :confirm_switch
    set /p confirm=Do you want to switch? (Y/N): 
    if /i "!confirm!"=="Y" (
        goto switch_logic
    ) else if /i "!confirm!"=="N" (
        echo Cancelled.
        goto end
    ) else (
        echo Invalid input. Please type Y or N.
        goto confirm_switch
    )

    :switch_logic
    REM Main switch logic
    :switch_to_global
    if exist "!UMA_GLOBAL!" (
        echo Switching JP → Global...
        rename "!UMA_FOLDER!" umamusume_jp
        rename "!UMA_GLOBAL!" umamusume
        echo ✅ Global version is now active !
        for /f "tokens=2 delims== " %%A in ('findstr /i "Global_location" "config.ini"') do set "GAME_PATH=%%A"
        if defined GAME_PATH (
            echo Launching Global version...
            start "" "!GAME_PATH!"
        )
        goto end
    )
    :switch_to_jp
    if exist "!UMA_JP!" (
        echo Switching Global → JP...
        rename "!UMA_FOLDER!" umamusume_global
        rename "!UMA_JP!" umamusume
        echo ✅ JP version is now active !
        for /f "tokens=1,* delims== " %%A in ('findstr /i "JP_location" "config.ini"') do set "RAW_PATH=%%B"
        set "RAW_PATH=!RAW_PATH:"=!"  & REM remove quotes
        set "GAME_PATH=!RAW_PATH!"
        if defined GAME_PATH (
        echo Launching JP version...
        start "" "!GAME_PATH!"
)

        goto end
    )
    :end
    echo.
    pause
