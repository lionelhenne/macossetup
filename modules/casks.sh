run() {
    log_header "Applications Setup"

    local brewfile="${SCRIPT_DIR}/inventory/Brewfile.casks"
    [[ -f "$brewfile" ]] || log_error "Brewfile not found: $brewfile"

    log_info "Installing applications (this may take a few minutes)..."

    if brew bundle --file="$brewfile"; then
        echo
        log_success "All applications installed"
    else
        echo
        log_warn "Some applications may have failed or were already installed"
    fi

    echo
    log_success "Applications setup completed!"
}
