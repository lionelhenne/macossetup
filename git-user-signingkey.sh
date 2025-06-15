#!/bin/bash

set -euo pipefail

caffeinate -dims &
CAFFEINATE_PID=$!

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
reset='\033[0m'

d_error() {
    printf "${red}[ERROR] %s${reset}\n" "$1"
    exit 1
}

d_header() {
    printf "\n${green}%s${reset}\n" "$1"
}

d_success() {
    printf "${green}[SUCCESS] %s${reset}\n" "$1"
}

d_warning() {
    printf "${yellow}[WARNING] %s${reset}\n" "$1"
}

d_info() {
    printf "${blue}[INFO] %s${reset}\n" "$1"
}

if ! sudo -v; then
    d_error "Cannot acquire sudo privileges. Exiting."
fi

setup_git() {
    d_header "CONFIGURING GIT user.signingkey."

    local current_signing_key
    current_signing_key=$(git config --global user.signingkey || echo "")

    if [[ -n "$current_signing_key" ]]; then
        d_info "Git signingkey already set to: $current_signing_key"
    else
        if ! command -v op &>/dev/null; then
            d_warning "'op' (1Password CLI) is not installed. Skipping Git signing key setup."
            return
        fi

        local pubkey
        pubkey=$(op item get "id_rsa" --field public_key 2>/dev/null)

        if [[ -z "$pubkey" ]]; then
            d_warning "Unable to retrieve public key from 1Password. Skipping Git signing key setup."
            return
        fi

        git config --global user.signingkey "$pubkey" || d_warning "Failed to set Git signing key."
        d_success "Git user.signingkey configured."
    fi
}

setup_git && d_success "Installation completed successfully!" || d_error "Installation failed."

kill $CAFFEINATE_PID
