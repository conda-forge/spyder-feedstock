@echo off
setlocal ENABLEDELAYEDEXPANSION

set menudir=%PREFIX%\Menu
set menu=%menudir%\spyder-menu.json

call :conda_based

call :menuinst_ver || goto :exit

call :base_env

:exit
    exit /b %errorlevel%

:conda_based
    if exist "%menudir%\conda-based-app" (
        :: Installed in installer environment, abridge shortcut name
        call :patch " ^({{ ENV_NAME }}^)="

        :: Nothing more to do for conda-based install
        goto :exit
    )
    goto :eof

:patch
    set tmpmenu=%menudir%\spyder-menu-tmp.json
    set findreplace=%~1
    for /f "delims=" %%a in (%menu%) do (
        set s=%%a
        echo !s:%findreplace%!>> "%tmpmenu%"
    )
    move /y "%tmpmenu%" "%menu%"
    goto :eof

:menuinst_ver
    :: How to robustly call the base environment python?
    for /F "tokens=*" %%i in (
        '%conda_python_exe% -c "from importlib.metadata import version; from packaging.version import parse; print(parse(version('menuinst')) < parse('2'))"'
    ) do (
        set isv1=%%~i
    )
    if "%isv1%"=="True" (
        copy /y "%menudir%\spyder-menu-v1.json.bak" "%menu%"

        :: Notify user
        echo. >> %PREFIX%\.messages.txt
        echo Warning! Using menuinst v1.>> %PREFIX%\.messages.txt
        echo Please update to menuinst v2 in the base environment and reinstall Spyder>> %PREFIX%\.messages.txt
    )
    goto :eof

:base_env
    if exist "%PREFIX%\condabin\" if exist "%PREFIX%\envs\" (
        :: Installed in a base environment, use distribution name
        call :patch "ENV_NAME=DISTRIBUTION_NAME"
    )
    goto :eof
