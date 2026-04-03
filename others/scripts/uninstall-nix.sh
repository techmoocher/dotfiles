#!/usr/bin/env bash

set -euo pipefail

trap 'echo -e "\033[1;31m[ERROR]\033[0m Failed to uninstall Nix. Check out line $LINENO"; exit 1' ERR

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

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

    echo -e "${CYAN}------ ${use_sudo:+sudo }execution ------${RESET}"
    echo -e "The following command will be executed:\n"
    echo -e "    $cmd\n"

    if [ "$DRY_RUN" = true ]; then
        info "[DRY RUN] Skipping execution"
        return 0
    fi

    set +e
    if [ "$use_sudo" = true ]; then
        sudo bash -c "$cmd"
    else
        bash -c "$cmd"
    fi
    local status=$?
    set -e

    echo

    return $status
}


check_sudo() {
    if ! sudo -v; then
        error "sudo privileges are required."
        exit 1
    fi
}

check_systemd() {
    command -v systemctl >/dev/null 2>&1
}

check_install_type() {
    if check_systemd && systemctl list-unit-files | grep -q '^nix-daemon\.service'; then
        echo "multi"
        return
    fi

    if getent group nixbld >/dev/null 2>&1; then
        echo "multi"
        return
    fi

    if [ -d /nix ]; then
        echo "single"
        return
    fi

    echo "none"
}

remove_nix_files() {
    for path in "$@"; do
        if [ -e "$path" ]; then
            if run_cmd "rm -rf \"$path\"" true; then
                ok "Removed $path"
            else
                warn "Failed to remove $path"
            fi
        else
            warn "$path cannot be found. Skipping..."
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
        run_cmd "systemctl disable nix-daemon.socket nix-daemon.service" true || warn "Failed to disable service"
        run_cmd "systemctl daemon-reload" true

        ok "Systemd cleanup done"
    else
        warn "Systemd not found, skipping service removal"
    fi
}

main() {
    echo -e "${GREEN}=== Complete Nix Uninstallation ===${RESET}"

    if [ "$DRY_RUN" = false ]; then
        check_sudo
    else
        info "Running in DRY RUN mode. No changes will be made..."
    fi

    TYPE=$(check_install_type)

    info "Detected installation type: $TYPE"

    read -rp "Proceed with uninstalling Nix? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "Aborted."
        exit 0
    fi

    case "$TYPE" in
        multi)
            info "Running multi-user uninstallation process..."

            remove_systemd

            remove_nix_files \
                /etc/nix \
                /etc/profile.d/nix.sh \
                /etc/tmpfiles.d/nix-daemon.conf \
                /nix \
                /root/.nix-channels \
                /root/.nix-defexpr \
                /root/.nix-profile \
                /root/.cache/nix \
                "$HOME/.local/share/nix" \
                "$HOME/.local/state/nix" \
                "$HOME/.cache/nix" \
                "$HOME/.nix-defexpr" \
                "$HOME/.nix-profile" \
                "$HOME/.nix-channels"

            remove_nix_users
            ;;

        single)
            info "Running single-user uninstallation process..."

            run_cmd "rm -rf /nix" true

            remove_nix_files \
                "$HOME/.nix-channels" \
                "$HOME/.nix-defexpr" \
                "$HOME/.nix-profile" \
                "$HOME/.local/share/nix" \
                "$HOME/.local/state/nix" \
                "$HOME/.cache/nix"
          ;;

        none)
            warn "Nix not found. Terminating..."
            exit 0
            ;;
    esac

    if [ "$DRY_RUN" = true ]; then
        ok "Dry run completed. No changes were made."
    else
        ok "Nix has been uninstalled successfully!"
    fi
}

main "$@"
