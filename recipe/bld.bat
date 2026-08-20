setlocal ENABLEDELAYEDEXPANSION

set SPYDER_QT_BINDING=conda-forge
%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
if errorlevel 1 exit 1

set MENU_DIR=%PREFIX%\Menu
IF NOT EXIST (%MENU_DIR%) mkdir %MENU_DIR%

rem  Copy Spyder's icons
copy %RECIPE_DIR%\spyder.ico %MENU_DIR%\spyder.ico
copy %RECIPE_DIR%\reset_preferences.ico %MENU_DIR%\reset_preferences.ico

rem  Replace variables in menu files
for /F "delims=. tokens=1" %%i in ("%PKG_VERSION%") do set PKG_MAJOR_VER=%%i
call :replace spyder-menu-win.json spyder-menu.json
call :replace spyder-menu-v1.json spyder-menu-v1.json.bak

rem  Copy GUI executable stub
for /F "tokens=*" %%i in (
    '%CONDA_PYTHON_EXE% -c "import conda_build, pathlib; print(pathlib.Path(conda_build.__file__).parent / 'gui-64.exe')"'
) do (
    set exe_path=%%i
)
rem  gui-64.exe will be moved to Scripts in post-link.bat for full noarch
copy /y /b %exe_path% %MENU_DIR%

rem  Copy launch script
copy /y %RECIPE_DIR%\spyder-script.pyw %SCRIPTS%

rem  Remove spyder.ico from Scripts for full noarch; replaced in post-link.bat
del /q %SCRIPTS%\spyder.ico

:exit
    exit /b %errorlevel%

:replace
    for /f "delims=" %%i in (%RECIPE_DIR%\%1) do (
        set s=%%i
        set s=!s:__PKG_VERSION__=%PKG_VERSION%!
        echo !s:__PKG_MAJOR_VER__=%PKG_MAJOR_VER%!>> %MENU_DIR%\%2
    )
    goto :eof
