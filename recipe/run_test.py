"""
Check that conda_activate.sh is executable.
"""

import os
import sys

import spyder

# Get path to conda activate script
pkg_root = os.path.dirname(spyder.__file__)
conda_activate = os.path.join(
    pkg_root,
    "plugins",
    "ipythonconsole",
    "scripts",
    "conda-activate.sh"
)

# Check the file exists
if not os.path.isfile(conda_activate):
    sys.exit(1)

# Check the file is executable
executable = os.access(conda_activate, os.X_OK)
if not executable:
    sys.exit(1)
