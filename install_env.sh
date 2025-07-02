#!/bin/bash

# Default to using system Python if no version is specified
PYTHONVERSION="${1:-system}"

ROOT="$PWD"
CUSTOM_DIR="$HOME/python"
PYTHON_BIN=""  # Global variable

install_python() {
    local version=$1
    local install_dir="$CUSTOM_DIR/$version"
    local tmpdir="/tmp/python-build-$version"

    if [[ ! -d "$tmpdir" ]]; then
        echo "Downloading Python $version..." >&2
        mkdir -p "$tmpdir" || exit 1
        cd "$tmpdir" || exit 1
        wget https://www.python.org/ftp/python/"$version"/Python-"$version".tgz || exit 1
    fi

    if [[ ! -d "$install_dir" ]]; then
        echo "Installing Python $version..." >&2
        cd "$tmpdir" || exit 1
        tar -xzf Python-"$version".tgz || exit 1
        cd Python-"$version" || exit 1
        ./configure --prefix="$install_dir" || exit 1
        make -j"$(nproc)" install || exit 1
    fi

    echo "Installed Python $version at $install_dir" >&2
    PYTHON_BIN="$install_dir/bin/python3"
}

setup_env() {
    local python_bin=$1

    # Remove existing environment if exists
    if [[ -d "env" ]]; then
        echo "Removing existing virtual environment..." >&2
        rm -rf env
    fi

    echo "Creating virtual environment using: $python_bin" >&2
    cd "$ROOT" || exit 1
    "$python_bin" -m venv "$ROOT/env" || exit 1
    source "$ROOT/env/bin/activate" || exit 1
    pip install --upgrade pip
    pip install -r requirements.txt || exit 1
    deactivate
}

main() {
    if [[ "$PYTHONVERSION" == "system" ]]; then
        echo "Using system Python..." >&2
        PYTHON_BIN=$(which python3)
    else
        install_python "$PYTHONVERSION"
    fi

    setup_env "$PYTHON_BIN"
}

main
