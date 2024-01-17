setlocal ENABLEDELAYEDEXPANSION

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
if errorlevel 1 exit 1

set MENU_DIR=%PREFIX%\Menu
IF NOT EXIST (%MENU_DIR%) mkdir %MENU_DIR%

copy %RECIPE_DIR%\spyder.ico %MENU_DIR%\spyder.ico

for /F "delims=. tokens=1" %%i in ("%PKG_VERSION%") do set PKG_MAJOR_VER=%%i

for /f "delims=" %%i in (%RECIPE_DIR%\spyder-menu.json) do (
    set s=%%i
    set s=!s:__PKG_VERSION__=%PKG_VERSION%!
    echo !s:__PKG_MAJOR_VER__=%PKG_MAJOR_VER%!>> %MENU_DIR%\spyder-menu.json
)

del %SCRIPTS%\spyder_win_post_install.py
del %SCRIPTS%\spyder.bat
del %SCRIPTS%\spyder
