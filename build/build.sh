#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDIR="$SCRIPT_DIR/bin"
LOGS_FILE="$BINDIR/logs"
REPORTS_FILE="$BINDIR/reports"
LOG_FILE="$BINDIR/setup.log"

PACKAGES=(git make nmap gcc kurcina)
DRY_RUN=false

source "$SCRIPT_DIR/../assets/color.sh"
source "$SCRIPT_DIR/../assets/banners.sh"

async_ansii
clear
echo -ne "${RED}"
download_banner_lay
echo -ne "${RESETBG}"
sleep 2

SYMBOL_OK="[${GREEN}+${RESETBG}]"
SYMBOL_WARN="[${YELLOW}!${RESETBG}]"
SYMBOL_ERR="[${RED}x${RESETBG}]"

strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') | $*" | strip_ansi >> "$LOG_FILE"
}

status_line() {
    local symbol="$1"
    local message="$2"
    local status="$3"
    local color="$4"
    local cols clean len status_len dots padding dots_str
    cols=$(tput cols)
    clean=$(sed 's/\x1b\[[0-9;]*m//g' <<< "$message")
    status_len=$(( ${#status} + 2 ))
    len=$(( ${#symbol} + 1 + ${#clean} ))
    dots=$(( (cols / 2) - len ))
    (( dots < 2 )) && dots=2
    dots_str=""
    for ((i=0;i<dots;i++)); do dots_str+="."; done
    padding=$(( (cols - (len + ${#dots_str} + status_len)) / 2 ))
    (( padding < 0 )) && padding=0
    printf "%*s%b %s %s %b[%s]%b\n" \
        "$padding" "" \
        "$symbol" "$message" \
        "$dots_str" \
        "$color" "$status" "$RESETBG"

    sleep_time=$(awk -v min=0.6 -v max=4 'BEGIN{srand(); print min+rand()*(max-min)}')
    sleep "$sleep_time"
    echo "$message [$status]" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

ok()    { status_line "$SYMBOL_OK"   "$1" "OK"    "$GREEN"; }
warnf() { status_line "$SYMBOL_WARN" "$1" "WARN"  "$YELLOW"; }
errf()  { status_line "$SYMBOL_ERR"  "$1" "ERROR" "$RED"; }

run() {
    if $DRY_RUN; then
        warnf "[dry-run] $*"
    else
        eval "$@"
    fi
}

trap 'errf "Script failed at line $LINENO"' ERR

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --help)
            echo "Usage: $0 [--dry-run]"
            exit 0
            ;;
    esac
done

detect_pm() {
    if command -v apt-get &>/dev/null; then
        INSTALL_CMD="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
        PM="apt"
    elif command -v dnf &>/dev/null; then
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf makecache"
        PM="dnf"
    elif command -v pacman &>/dev/null; then
        INSTALL_CMD="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Sy"
        PM="pacman"
    else
        errf "No supported package manager found"
        exit 1
    fi
    ok "Detected package manager: $PM"
}

main() {
    mkdir -p "$BINDIR" "$LOGS_FILE" "$REPORTS_FILE" \
        && ok "Creating directories" \
        || errf "Creating directories"

    detect_pm

    local pending=()
    local pids=()
    local pending_pkgs=()

    for pkg in "${PACKAGES[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            ok "Package '$pkg' already installed"
        else
            if apt-cache show "$pkg" &>/dev/null; then
                warnf "Installing $pkg..."
                run "$INSTALL_CMD $pkg" >> "$LOG_FILE" 2>&1 &
                pids+=($!)
                pending_pkgs+=("$pkg")
            else
                errf "Package '$pkg' not found in repository"
            fi
        fi
    done

    for i in "${!pending_pkgs[@]}"; do
        pkg="${pending_pkgs[i]}"
        pid="${pids[i]}"
        if wait "$pid"; then
            ok "Installed $pkg"
        else
            errf "Failed to install $pkg"
        fi
    done

    ok "All missing packages installed"
    ok "System preparation complete"
}

main "$@"
