@echo off

set menudir=%PREFIX%\Menu
set menu=%menudir%\spyder-menu.json
set logfile=%PREFIX%\.messages.txt
set scriptsdir=%PREFIX%\Scripts

rem  Cleanup GUI files
move /y %scriptsdir%\gui-64.exe %scriptsdir%\spyder.exe
del %scriptsdir%\spyder-script.py

rem  Check for conda-based install
if exist "%menudir%\conda-based-app" (
    call :conda_based_install
    rem  Nothing more to do for conda-based install
    goto :exit
)

call :not_conda_based_install

:exit
    exit /b %errorlevel%

:conda_based_install
    rem  Abridge shortcut name
    call :patch " ^({{ ENV_NAME }}^)=" %menu%

    rem  Prevent using user site-packages
    rem  See https://github.com/spyder-ide/spyder/issues/24773
    set site=%PREFIX%\Lib\site.py
    set site_tmp=%PREFIX%\Lib\site.py.bak

    rem delayed expansion must be disabled because site.py has ! characters
    (for /f "delims=" %%A in ('findstr /n "^" "%site%"') do (
        rem Split line number and content
        for /f "tokens=1* delims=:" %%N in ("%%A") do (
            if "%%O"=="ENABLE_USER_SITE = None" (
                echo ENABLE_USER_SITE = False
            ) else (
                echo.%%O
            )
        )
    )) > "%site_tmp%" && move /y %site_tmp% %site% >nul

    goto :eof

:not_conda_based_install
    rem  Check for CONDA_PYTHON_EXE
    if not exist "%conda_python_exe%" (
        rem  CONDA_PYTHON_EXE environment variable does not exist.
        rem  v1 type shortcuts will not work
        goto :exit
    )

    rem  Check menuinst version
    set menuinst_min_ver=2.3.0
    for /F "tokens=*" %%i in (
        '%conda_python_exe% -c "import menuinst; print(menuinst.__version__)"'
    ) do (
        set menuinst_ver=%%~i
    )
    for /f "delims=" %%i in (
        'powershell -Command "[version]'%menuinst_ver%' -lt [version]'%menuinst_min_ver%'"'
    ) do (
        if "%%~i" == "True" call :use_menu_v1
    )
    goto :eof

:patch
    set tmpmenu=%menudir%\tmp.json
    set findreplace=%~1
    setlocal ENABLEDELAYEDEXPANSION
    (for /f "delims=" %%a in ('findstr /n "^" "%~2"') do (
        set "s=%%a"
        set "s=!s:*:=!"
        echo !s:%findreplace%!
    )) > "%tmpmenu%" && move /y "%tmpmenu%" "%~2" >nul
    endlocal
    goto :eof

:use_menu_v1
    rem  Replace spyder-menu.json with version 1 instance
    copy /y "%menudir%\spyder-menu-v1.json.bak" "%menu%"

    rem  Notify user
    echo. >> %logfile%
    echo Warning: Using menuinst v1 >> %logfile%
    echo Please update to menuinst ^>=%menuinst_min_ver% in the base environment and reinstall Spyder >> %logfile%
    goto :eof
