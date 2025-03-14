#!/bin/bash

export SPYDER_QT_BINDING=conda-forge
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

rm -rf $PREFIX/man
rm -f $PREFIX/bin/spyder_win_post_install.py
rm -rf $SP_DIR/Sphinx-*

# Create the Menu directory
mkdir -p "${PREFIX}/Menu"

# Copy menu.json template, replacing version
sed -e "s/__PKG_VERSION__/${PKG_VERSION}/g" -e "s/__PKG_MAJOR_VER__/${PKG_VERSION%%.*}/g" "${RECIPE_DIR}/spyder-menu-unix.json" > "${PREFIX}/Menu/spyder-menu.json"

# Copy application icons
if [[ $OSTYPE == "darwin"* ]]; then
    cp "${RECIPE_DIR}/spyder.icns" "${PREFIX}/Menu/spyder.icns"
else
    cp "${RECIPE_DIR}/spyder.png" "${PREFIX}/Menu/spyder.png"
fi
