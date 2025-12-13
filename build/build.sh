#!/usr/bin/env bash


set -Eeuo pipefail

BINDIR="bin"
BOOT_FILE="$BINDIR/boot"
LOGS_FILE="$BINDIR/logs"
REPORTS_FILE="$BINDIR/reports"

PACKAGES=(git make nmap gcc)
DRY_RUN=false
LOG_FILE="setup.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') | $*" | tee -a "$BINDIR/$LOG_FILE"
}

info()    { log "${BLUE}[INFO]${NC} $*"; }
success() { log "${GREEN}[OK]${NC}   $*"; }
warn()    { log "${YELLOW}[WARN]${NC} $*"; }
error()   { log "${RED}[ERR]${NC}  $*"; }

run() {
  if $DRY_RUN; then
    info "[dry-run] $*"
  else
    eval "$@"
  fi
}

trap 'error "Script failed at line $LINENO"' ERR

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
    PM="apt"
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
  elif command -v dnf &>/dev/null; then
    PM="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf makecache"
  elif command -v pacman &>/dev/null; then
    PM="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    UPDATE_CMD="sudo pacman -Sy"
  else
    error "No supported package manager found"
    exit 1
  fi

  success "Detected package manager: $PM"
}

main() {
  mkdir -p "$BINDIR" "$LOGS_FILE" "$REPORTS_FILE"

  info "Starting system preparation"
  detect_pm

  local pending=()

  for pkg in "${PACKAGES[@]}"; do
    if command -v "$pkg" &>/dev/null; then
      success "Package '$pkg' already installed"
    else
      warn "Package '$pkg' missing"
      pending+=("$pkg")
    fi
  done

  if (( ${#pending[@]} == 0 )); then
    success "All packages already installed"
  else
    info "Updating package index"
    run "$UPDATE_CMD"

    info "Installing missing packages: ${pending[*]}"
    for p in "${pending[@]}"; do
      run "$INSTALL_CMD $p"
    done
  fi

  success "System is fully prepared"
}

main "$@"
