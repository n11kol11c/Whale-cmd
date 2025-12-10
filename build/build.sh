#!/usr/bin/bash

# author: matija
# license: MIT license
# This script provides requrements and packages that are necessary
# for running and using `Whale-cmd`
# You will manualy need to give admin permissions to this script
# so it can run on root level
# If you are having trouble downloading packages that have constant updates
# you can reach me out on my linkedin, discord
# links will be on my github page at github.com/n11kol11c
# This script provides cross-compilers requried for C that is core lang
# for running this little cmd-cover

# chmod auto-set
# auto-give root permissions
# dont touch this unless you know what are you doing :)
chmod +x $0

# script dependencies
# these are script dependencies that will be our little macro
# so we dont repeat paths using slashes
BIN="BIN"
ERROR_FILE="error.log"
ERROR_LOG="$BIN/error.log"

# list of build packages
# created pending packages for those that are missing on system
packages=("gcc", "make", "")
pending=()

check_dirs() {
    local bin_dir="$BIN"
    local error_file="$BIN/$ERROR_FILE"

    if [[ ! -d "$bin_dir" ]]; then
        mkdir -p "$bin_dir"
    fi

    if [[ ! -f "$ERROR_FILE" ]]; then
        touch "$error_file"
    fi
}

# function that will check for that boring package downloading
check_packages() {
    local pkg
    local apt_cmd=(sudo apt-get install -y) # Macro for apt install

    # loop through packages to check if there is missing-package
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            # every package that has not been found 
            # will be dumped to bin directory
            echo "No package found: $pkg" >> "$BIN/$ERROR_FILE"
            pending+=("$pkg") # add package to pending
        fi
    done

    # check if there is pending packages
    # if pending number is gt 0 it means some packages are
    # missing from the system
    if (( ${#pending[@]} > 0 )); then
        echo "Installing missing packages: ${pending[*]}"
        "${apt_cmd[@]}" "${pending[@]}"
    else
        echo "All required packages are already installed."
    fi
}
