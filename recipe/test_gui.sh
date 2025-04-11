#!/bin/bash

set -euo pipefail
TO=20s

# Launch it
if [[ "$(uname -s)" == *'Linux'* ]]; then
    export EXTRA=xvfb-run
else
    export EXTRA=
fi
set +x
$EXTRA timeout $TO spyder
set -x
RESULT=$?
if [[ $RESULT -eq 124 ]]; then
    echo "Spyder succeeded with timeout"
else
    echo "Spyder failed with error code $RESULT (should be 124 for timeout)"
    exit 1
fi
