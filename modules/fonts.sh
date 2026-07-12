#!/bin/bash
# fonts.sh
# Fonts Installation

run() {
    log_header "Fonts Setup"

    local brewfile="${SCRIPT_DIR}/inventory/Brewfile.fonts"
    [[ -f "$brewfile" ]] || log_error "Brewfile not found: $brewfile"

    log_info "Installing fonts (this may take a few minutes)..."

    if brew bundle --file="$brewfile"; then
        echo
        log_success "All fonts installed"
    else
        echo
        log_warn "Some fonts may have failed or were already installed"
    fi
}
