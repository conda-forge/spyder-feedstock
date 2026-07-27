#!/bin/bash
set -e

# Set sed options depending on BSD or GNU
[[ $(sed --version 2>/dev/null) ]] && opts=("-i" "-E") || opts=("-i" "" "-E")

menu="${PREFIX}/Menu/spyder-menu.json"

# Minimum required menuinst version
if [[ "$OSTYPE" == "darwin"* ]]; then
    menuinst_min_version="2.4.0"
else
    menuinst_min_version="2.1.2"
fi

if [[ -f "${PREFIX}/Menu/conda-based-app" ]]; then
    # Installed in installer environment...

    # Abridge shortcut name
    sed "${opts[@]}" "s/ \(\{\{ ENV_NAME \}\}\)//g" $menu  # macOS application bundle name
    sed "${opts[@]}" "s/__CFBID_ENV__//g" $menu  # macOS CFBundleIdentifier

    # Prevent using user site-packages
    # See https://github.com/spyder-ide/spyder/issues/24773
    site=$(find ${PREFIX}/lib/python* -name "site.py")
    sed "${opts[@]}" 's/^ENABLE_USER_SITE = None/ENABLE_USER_SITE = False/g' "${site}"
fi

# Do not create shortcut for menuinst version less than min version
menuinst_version=$($CONDA_PYTHON_EXE -c "import menuinst; print(menuinst.__version__)" 2>/dev/null || echo "0.0.0")
last_version=$(echo -e "${menuinst_version}\n${menuinst_min_version}" | sort -V | tail -n1)
if [[ "${menuinst_version}" != "${last_version}" ]]; then
    mv -f ${menu} ${menu}.bak
    echo "Warning: Spyder shortcut will not be created." >> ${PREFIX}/.message.txt
    echo "Please update to menuinst >=${menuinst_min_version} in the base environment and reinstall Spyder." >> ${PREFIX}/.message.txt
    exit 0
fi

# Replace __CFBID_ENV__ because it does not conform to schema for CFBundleIdentifier
env_name=$(basename ${PREFIX//_/-})  # CFBundleIdentifier cannot have underscore
sed "${opts[@]}" "s/__CFBID_ENV__/${env_name}/g" $menu

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Get CFBundleIdentifier
    cfbundleid=$(grep '"CFBundleIdentifier"' $menu | sed -E 's/.*"CFBundleIdentifier": *"([^"]+)".*/\1/')

    # Set "Show scroll bars" to "Always" for Spyder's application bundle ID
    # See https://github.com/spyder-ide/spyder/issues/13118
    defaults write ${cfbundleid} AppleShowScrollBars Always
fi
