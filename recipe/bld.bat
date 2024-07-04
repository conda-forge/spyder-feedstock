setlocal ENABLEDELAYEDEXPANSION

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
if errorlevel 1 exit 1

set MENU_DIR=%PREFIX%\Menu
IF NOT EXIST (%MENU_DIR%) mkdir %MENU_DIR%

rem  Copy Spyder's icon
copy %RECIPE_DIR%\spyder.ico %MENU_DIR%\spyder.ico

rem  Replace variables in menu files
for /F "delims=. tokens=1" %%i in ("%PKG_VERSION%") do set PKG_MAJOR_VER=%%i
call :replace spyder-menu.json spyder-menu.json
call :replace spyder-menu-v1.json spyder-menu-v1.json.bak

:exit
    exit /b %errorlevel%

:replace
    for /f "delims=" %%i in (%RECIPE_DIR%\%1) do (
        set s=%%i
        set s=!s:__PKG_VERSION__=%PKG_VERSION%!
        echo !s:__PKG_MAJOR_VER__=%PKG_MAJOR_VER%!>> %MENU_DIR%\%2
    )
    goto :eof
