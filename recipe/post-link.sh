#!/bin/bash
set -e

[[ $(sed --version 2>/dev/null) ]] && opts=("-i" "-E") || opts=("-i" "" "-E")
menu="${PREFIX}/Menu/spyder-menu.json"

if [[ -f "${PREFIX}/Menu/conda-based-app" ]]; then
    # Installed in installer environment, abridge shortcut name
    sed "${opts[@]}" "s/ \(\{\{ ENV_NAME \}\}\)//g" $menu
    sed "${opts[@]}" "s/-__CFBID_ENV__//g" $menu

    # Nothing more to do for conda-based-installers
    exit
fi

env_name=$(basename ${PREFIX//_/-})
sed "${opts[@]}" "s/__CFBID_ENV__/${env_name}/g" $menu

# Do not create shortcut for menuinst version <2.1.2
menuinst_version=$($CONDA_PYTHON_EXE -c "import menuinst; print(menuinst.__version__)" 2>/dev/null || echo "0.0.0")
if [[ "$menuinst_version" < "2.1.2" ]]; then
    mv -f ${menu} ${menu}.bak
    echo "Warning: Spyder shortcut will not be created." >> ${PREFIX}/.message.txt
    echo "Please update to menuinst >=2.1.2 in the base environment and reinstall Spyder." >> ${PREFIX}/.message.txt
fi
