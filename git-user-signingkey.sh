#!/bin/bash
set -euo pipefail

readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[0;33m'
readonly BLUE=$'\033[0;34m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

log_error() { printf "${RED}[ERROR] %s${RESET}\n" "$1" >&2; exit 1; }
log_header() { printf "\n${BOLD}${GREEN}=== %s ===%s\n" "$1" "${RESET}"; }
log_success() { printf "${GREEN}[SUCCESS] %s${RESET}\n" "$1"; }
log_warning() { printf "${YELLOW}[WARNING] %s${RESET}\n" "$1"; }
log_info() { printf "${BLUE}[INFO] %s${RESET}\n" "$1"; }

prevent_sleep() {
    if command -v caffeinate >/dev/null 2>&1; then
        caffeinate -dims &
        CAFFEINATE_PID=$!
        trap 'kill "$CAFFEINATE_PID" &>/dev/null 2>&1 || true' EXIT
        log_info "Sleep prevention activated."
    else
        log_warning "caffeinate command not found, sleep prevention disabled."
    fi
}

setup_git() {
    log_header "CONFIGURING GIT user.signingkey."

    local current_signing_key
    current_signing_key=$(git config --global user.signingkey || echo "")

    if [[ -n "$current_signing_key" ]]; then
        log_info "Git signingkey already set to: $current_signing_key"
    else
        if ! command -v op &>/dev/null; then
            log_warning "'op' (1Password CLI) is not installed. Skipping Git signing key setup."
            return
        fi

        local pubkey
        pubkey=$(op item get "id_rsa" --field public_key 2>/dev/null)

        if [[ -z "$pubkey" ]]; then
            log_warning "Unable to retrieve public key from 1Password. Skipping Git signing key setup."
            return
        fi

        git config --global user.signingkey "$pubkey" || log_warning "Failed to set Git signing key."
        log_success "Git user.signingkey configured."
    fi
}

main() {
    prevent_sleep
    setup_git
}

main && log_success "Git User Signin Key installation completed successfully!" || log_error "Git User Signin Key  installation failed."
