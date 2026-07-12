#!/bin/bash
# webdev.sh
# Web Development Environment Setup

run() {
    log_header "Web Development Setup"

    # Create folders
    log_info "Creating project directories..."
    mkdir -p ~/Sites ~/Developer
    log_success "Directories created"

    # Install PHP, Composer, Laravel Valet
    if command -v php >/dev/null 2>&1; then
        log_warn "PHP already installed"
    else
        log_info "Installing PHP..."
        if brew install php; then
            log_success "PHP installed"
        else
            log_error "Failed to install PHP"
        fi
    fi

    if command -v composer >/dev/null 2>&1; then
        log_warn "Composer already installed"
    else
        log_info "Installing Composer..."
        if brew install composer; then
            log_success "Composer installed"
        else
            log_error "Failed to install Composer"
        fi
    fi

    # Install Laravel Installer and Valet
    log_info "Installing Laravel Installer and Valet..."
    if composer global require laravel/installer laravel/valet >/dev/null 2>&1; then
        log_success "Laravel tools installed"
    else
        log_error "Failed to install Laravel tools"
    fi

    # Get Composer global bin directory
    local composer_bin
    composer_bin=$(composer global config bin-dir --absolute 2>/dev/null)

    if [[ -z "$composer_bin" ]]; then
        log_error "Failed to detect Composer global bin directory"
    fi

    # Add Composer global bin to PATH for this session
    export PATH="$composer_bin:$PATH"

    # Check if Valet is configured
    if valet --version >/dev/null 2>&1 && [[ -f "$HOME/.config/valet/dnsmasq.d/tld-test.conf" ]]; then
        log_warn "Valet already configured"
    else
        log_info "Setting up Valet..."
        if valet install; then
            log_success "Valet installed"
        else
            log_error "Failed to install Valet"
        fi

        if valet trust >/dev/null 2>&1; then
            log_success "Valet trusted"
        else
            log_warn "Valet trust failed (may need manual intervention)"
        fi
    fi

    if valet paths | grep -q "$HOME/Sites"; then
        log_warn "Sites directory already parked"
    else
        log_info "Parking ~/Sites directory..."
        cd ~/Sites && valet park
        log_success "Sites directory parked"
    fi

    # Install PHP Monitor via Homebrew Cask
    if brew list --cask phpmon &>/dev/null || [ -d "/Applications/PHP Monitor.app" ]; then
        log_warn "PHP Monitor already installed"
    else
        log_info "Installing PHP Monitor via Homebrew..."
        if brew tap nicoverbruggen/cask && brew install --cask nicoverbruggen/cask/phpmon; then
            log_success "PHP Monitor installed via Cask"
        else
            log_error "Failed to install PHP Monitor"
        fi
    fi

    if [ -d "/Applications/PHP Monitor.app" ]; then
        log_info "Launching PHP Monitor..."
        open -a "PHP Monitor" 2>/dev/null || log_warn "Failed to launch PHP Monitor (launch manually)"
    fi

    # Install Node.js directly via Homebrew
    if command -v node >/dev/null 2>&1; then
        log_warn "Node.js already installed"
    else
        log_info "Installing Node.js..."
        if brew install node; then
            log_success "Node.js installed"
        else
            log_error "Failed to install Node.js"
        fi
    fi

    echo
    log_success "Web development environment ready!"
    echo

    # Display summary
    log_info "Installation summary:"
    echo
    echo -e "  ${BOLD}Development Stack:${RESET}"
    echo -e "    ${SILVER}• PHP:${RESET} $(php -v 2>/dev/null | head -n 1 | cut -d' ' -f2)"
    echo -e "    ${SILVER}• Composer:${RESET} $(composer -V 2>/dev/null | awk '{print $3}')"
    echo -e "    ${SILVER}• Laravel Valet:${RESET} $(composer global show laravel/valet 2>/dev/null | grep 'versions' | awk '{print $NF}')"

    if command -v node >/dev/null 2>&1; then
        echo -e "    ${SILVER}• Node.js:${RESET} $(node -v 2>/dev/null)"
        echo -e "    ${SILVER}• npm:${RESET} $(npm -v 2>/dev/null)"
    else
        echo -e "    ${SILVER}• Node.js:${RESET} not installed"
    fi

    if [[ -d "/Applications/PHP Monitor.app" ]]; then
        echo -e "    ${SILVER}• PHP Monitor:${RESET} installed"
    fi
    echo
}