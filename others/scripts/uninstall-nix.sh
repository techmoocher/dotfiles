#!/usr/bin/env bash

set -euo pipefail

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

info()  { echo -e "${BLUE}[INFO]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }
ok()    { echo -e "${GREEN}[OK]${RESET} $1"; }

run_cmd() {
    local cmd="$1"
    local use_sudo="${2:-false}"

    echo -e "${CYAN}---- ${use_sudo:+sudo }execution ------------------------------------------------------------${RESET}"
    echo -e "I am executing:\n"
    echo -e "    $cmd\n"

    if [ "$use_sudo" = true ]; then
        sudo bash -c "$cmd"
    else
        bash -c "$cmd"
    fi
}


check_sudo() {
    if ! sudo -v; then
        error "This script requires sudo privileges."
        exit 1
    fi
}

check_systemd() {
    command -v systemctl >/dev/null 2>&1
}

safe_rm() {
    for path in "$@"; do
        if [ -e "$path" ]; then
            run_cmd "rm -rf \"$path\"" true
            ok "Removed $path"
        else
            warn "Skipping $path (not found)"
        fi
    done
}

remove_nix_users() {
    info "Removing nixbld users..."

    for i in $(seq 1 32); do
        if id "nixbld$i" &>/dev/null; then
            run_cmd "userdel nixbld$i" true || warn "Failed to remove nixbld$i"
        else
            warn "User nixbld$i does not exist"
        fi
    done

    if getent group nixbld >/dev/null; then
        run_cmd "groupdel nixbld" true || warn "Failed to remove nixbld group"
    else
        warn "Group nixbld does not exist"
    fi
}

remove_systemd() {
    if check_systemd; then
        info "Stopping and disabling nix-daemon..."

        run_cmd "systemctl stop nix-daemon.service" true || warn "Failed to stop service"
        run_cmd "systemctl disable nix-daemon.socket nix-daemon.service" true || warn "Disable failed"
        run_cmd "systemctl daemon-reload" true

        ok "Systemd cleanup done"
    else
        warn "Systemd not found, skipping service removal"
    fi
}

main() {
    echo -e "${GREEN}=== Complete Nix Uninstallation ===${RESET}"

    check_sudo

    read -rp "Proceed with uninstalling Nix? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "Aborted."
        exit 0
    fi

    remove_systemd

    info "Removing Nix files..."

    safe_rm \
        /etc/nix \
        /etc/profile.d/nix.sh \
        /etc/tmpfiles.d/nix-daemon.conf \
        /nix \
        "$HOME/.local/share/nix" \
        "$HOME/.local/state/nix" \
        "$HOME/.cache/nix" \
        "$HOME/.nix-defexpr" \
        "$HOME/.nix-profile" \
        "$HOME/.nix-channels" \
        /root/.nix-channels \
        /root/.nix-defexpr \
        /root/.nix-profile \
        /root/.cache/nix

    remove_nix_users

    ok "Nix has been fully removed 🎉"
}

main "$@"
