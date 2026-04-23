#!/usr/bin/env bash
set -euo pipefail
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"

PROJECT_DIR="${1:-.}"

# Resolve absolute project path
ABS_PROJECT="$(pwd)/$PROJECT_DIR"

echo "Running pi-sandbox:latest with >$ABS_PROJECT< mounted to /home/piuser/workspace ..."

docker run -it --rm -v ${ABS_PROJECT}:/home/piuser/workspace:rw -e PI_PROJECT_DIR=/home/piuser/workspace -w /home/piuser/workspace   pi-sandbox:latest
