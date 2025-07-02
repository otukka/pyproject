#! /bin/bash

ROOT_DIR="$(dirname "$(readlink -fm "$0")")"

# PYTHONPATH
export PYTHONPATH=$ROOT_DIR:$PYTHONPATH

# Environment
source env/bin/activate

# Run tests
pytest -v -s ./tests 

deactivate