#!/bin/bash
# mas.sh
# Mac App Store Applications

run() {
    log_header "Mac App Store Setup"

    if ! command -v mas >/dev/null 2>&1; then
        log_error "mas not found (install via: brew install mas)"
    fi

    # mas dropped account-status commands years ago (Apple restricted the
    # API), so there's no way to verify sign-in short of attempting an
    # install — unlike identity.sh's 1Password check, this is a one-shot
    # confirm, not a verify loop.
    echo "Please make sure you're signed in to the Mac App Store:"
    echo "  1. Open the App Store app"
    echo "  2. Sign in with your Apple ID"
    echo

    if ! confirm "Ready to continue?" Y; then
        log_info "Setup cancelled"
        return 0
    fi

    local brewfile="${SCRIPT_DIR}/inventory/Brewfile.mas"
    [[ -f "$brewfile" ]] || log_error "Brewfile not found: $brewfile"

    log_info "Installing Mac App Store applications (this may take a few minutes)..."

    if brew bundle --file="$brewfile"; then
        echo
        log_success "All applications installed"
    else
        echo
        log_warn "Some applications may have failed — check you're signed in to the Mac App Store"
    fi
}
