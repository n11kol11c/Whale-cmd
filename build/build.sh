#!/usr/bin/bash

# author: matija
# license: MIT license
# This script provides requirements and packages that are necessary
# for running and using `Whale-cmd`
# You will manualy need to give admin permissions to this script
# so it can run on root level
# If you are having trouble downloading packages that have constant updates
# you can reach me out on my linkedin, discord
# links will be on my github page at github.com/n11kol11c
# This script provides cross-compilers requried for C that is core lang
# for running this little cmd-cover

# chmod auto-set
# dont touch this unless you know what are you doing :)
chmod +x $0

# script dependencies
# these are script dependencies that will be our little macro
# so we dont repeat paths using slashes
BIN="BIN"
ERROR_LOG="$BIN/error.log"

packages=("gcc", "make")
pending=()

# function that will check for that boring package downloading
check_packages() {
    local pkg
    local apt_cmd=(sudo apt-get install -y) # Macro for apt install

    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            echo "No package found: $pkg" >> "$ERROR_LOG"
            pending+=("$pkg")
        fi
    done

    if (( ${#pending[@]} > 0 )); then
        echo "Installing missing packages: ${pending[*]}"
        "${apt_cmd[@]}" "${pending[@]}"
    else
        echo "All required packages are already installed."
    fi
}
