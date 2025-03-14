@echo off
setlocal ENABLEDELAYEDEXPANSION

set menudir=%PREFIX%\Menu
set menu=%menudir%\spyder-menu.json
set logfile=%PREFIX%\.messages.txt
set scriptsdir=%PREFIX%\Scripts

rem  Cleanup GUI files
move /y %scriptsdir%\gui-64.exe %scriptsdir%\spyder.exe
del %scriptsdir%\spyder-script.py

rem  Check for conda-based install
if exist "%menudir%\conda-based-app" (
    rem  Abridge shortcut name
    call :patch " ^({{ ENV_NAME }}^)=" %menu%

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
    '%conda_python_exe% -c "import menuinst; print(menuinst.__version__)"'
) do (
    if "%%~i" lss "2.1.2" call :use_menu_v1
)

:exit
    exit /b %errorlevel%

:patch
    set tmpmenu=%menudir%\tmp.json
    set findreplace=%~1
    for /f "delims=" %%a in (%~2) do (
        set s=%%a
        echo !s:%findreplace%!>> "%tmpmenu%"
    )
    move /y "%tmpmenu%" "%~2"
    goto :eof

:use_menu_v1
    rem  Replace spyder-menu.json with version 1 instance
    copy /y "%menudir%\spyder-menu-v1.json.bak" "%menu%"

    rem  Notify user
    echo. >> %logfile%
    echo Warning: Using menuinst v1 >> %logfile%
    echo Please update to menuinst ^>=2.1.2 in the base environment and reinstall Spyder >> %logfile%
    goto :eof
