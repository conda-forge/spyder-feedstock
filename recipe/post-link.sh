#!/bin/bash
set -e

[[ $(sed --version 2>/dev/null) ]] && opts=("-i" "-E") || opts=("-i" "" "-E")
menu="${PREFIX}/Menu/spyder-menu.json"

if [[ -f "${PREFIX}/Menu/conda-based-app" ]]; then
    # Installed in installer environment, abridge shortcut name
    sed "${opts[@]}" "s/ \(\{\{ ENV_NAME \}\}\)//g" $menu
elif [[ -d "${PREFIX}/condabin" && -d "${PREFIX}/envs" ]]; then
    # Installed in a base environment, use distribution name
    sed "${opts[@]}" "s/ENV_NAME/DISTRIBUTION_NAME/g" $menu
fi
