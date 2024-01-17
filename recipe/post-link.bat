@echo off
setlocal ENABLEDELAYEDEXPANSION

set PREFIX=C:\Users\rclary\Documents\Repos\spyder-feedstock\recipe


if exist "%menudir%\conda-based-app" (
    :: Installed in installer environment, abridge shortcut name
    call :patch " ^({{ ENV_NAME }}^)="
)

if exist "%PREFIX%\condabin\" if exist "%PREFIX%\envs\" (
    :: Installed in a base environment, use distribution name
    call :patch "ENV_NAME=DISTRIBUTION_NAME"
)

:exit
exit /b %errorlevel%

:patch
    set menudir=%PREFIX%
    set menu=%menudir%\spyder-menu.json
    set tmpmenu=%menudir%\spyder-menu-tmp.json
    set findreplace=%~1
    for /f "delims=" %%a in (%menu%) do (
        set s=%%a
        echo !s:%findreplace%!>> "%tmpmenu%"
    )
    move /y "%tmpmenu%" "%menu%"
    goto :exit
