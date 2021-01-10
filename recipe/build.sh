#!/bin/bash

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

rm -rf $PREFIX/man
rm -f $PREFIX/bin/spyder_win_post_install.py
rm -rf $SP_DIR/Sphinx-*

# Set executable permissions for our scripts
chmod a+x $SP_DIR/spyder/plugins/ipythonconsole/scripts/conda-activate.sh
chmod a+x $SP_DIR/spyder/utils/check-git.sh

# Change scripts line endings to LF
awk 'BEGIN{RS="^$";ORS="";getline;gsub("\r","");print>ARGV[1]}' $SP_DIR/spyder/plugins/ipythonconsole/scripts/conda-activate.sh
awk 'BEGIN{RS="^$";ORS="";getline;gsub("\r","");print>ARGV[1]}' $SP_DIR/spyder/utils/check-git.sh
