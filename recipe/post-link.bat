@echo off
setlocal ENABLEDELAYEDEXPANSION

set menudir=%PREFIX%\Menu
set menu=%menudir%\spyder-menu.json
set logfile=%PREFIX%\.messages.txt

rem  Check for conda-based install
if exist "%menudir%\conda-based-app" (
    rem  Abridge shortcut name
    call :patch " ^({{ ENV_NAME }}^)="

    rem  Nothing more to do for conda-based install
    goto :exit
)

rem  Check for CONDA_PYTHON_EXE
if not exist "%conda_python_exe%" (
    rem  CONDA_PYTHON_EXE environment variable does not exist.
    rem  v1 type shortcuts will not work
    goto :exit
)

rem  Check menuinst version
for /F "tokens=*" %%i in (
    '%conda_python_exe% -c "import menuinst; print(int(menuinst.__version__[0]) < 2)"'
) do (
    if "%%~i"=="True" call :use_menu_v1
)

:exit
    exit /b %errorlevel%

:patch
    set tmpmenu=%menudir%\spyder-menu-tmp.json
    set findreplace=%~1
    for /f "delims=" %%a in (%menu%) do (
        set s=%%a
        echo !s:%findreplace%!>> "%tmpmenu%"
    )
    move /y "%tmpmenu%" "%menu%"
    goto :eof

:use_menu_v1
    copy /y "%menudir%\spyder-menu-v1.json.bak" "%menu%"

    rem  Notify user
    echo. >> %logfile%
    echo Warning: Using menuinst v1 >> %logfile%
    echo Please update to menuinst v2 in the base environment and reinstall Spyder >> %logfile%
    goto :eof
