#!/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/color.sh"

async_ansii

getsizesf() {
  local cols
  cols=$(tput cols)

  while IFS= read -r line; do
    local clean
    clean=$(sed 's/\x1b\[[0-9;]*m//g' <<< "$line")

    local len=${#clean}
    local pad=$(( (cols - len) / 2 ))
    (( pad < 0 )) && pad=0

    printf "%*s%s\n" "$pad" "" "$line"
  done
}

download_banner_lay() {
  printf "%s\n" "${RED}"
  cat << 'EOF' | getsizesf
                                                                                                
 █     █░ ██░ ██  ▄▄▄       ██▓    ▓█████ 
▓█░ █ ░█░▓██░ ██▒▒████▄    ▓██▒    ▓█   ▀ 
▒█░ █ ░█ ▒██▀▀██░▒██  ▀█▄  ▒██░    ▒███   
░█░ █ ░█ ░▓█ ░██ ░██▄▄▄▄██ ▒██░    ▒▓█  ▄ 
░░██▒██▓ ░▓█▒░██▓ ▓█   ▓██▒░██████▒░▒████▒
░ ▓░▒ ▒   ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░▓  ░░░ ▒░ ░
  ▒ ░ ░   ▒ ░▒░ ░  ▒   ▒▒ ░░ ░ ▒  ░ ░ ░  ░
  ░   ░   ░  ░░ ░  ░   ▒     ░ ░      ░   
    ░     ░  ░  ░      ░  ░    ░  ░   ░  ░
                                          
                                                
                                                    
EOF
  printf "%s\n" "${RESETBG}"
}

export download_banner_lay
