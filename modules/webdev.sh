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

    # Install MySQL
    if brew list mysql &>/dev/null; then
        log_warn "MySQL already installed"
    else
        log_info "Installing MySQL..."
        if brew install mysql; then
            log_success "MySQL installed"
        else
            log_error "Failed to install MySQL"
        fi
    fi

    # Configure MySQL
    if brew services list | grep -q "mysql.*started"; then
        log_warn "MySQL service already running"
    else
        log_info "Starting MySQL service..."
        brew services start mysql
        sleep 3
    fi

    log_info "Configuring MySQL (root/root)..."

    # Check if already configured with password 'root'
    if mysql -u root -proot -e "SELECT 1" >/dev/null 2>&1; then
        log_success "MySQL already configured with root/root"
    else
        log_info "Setting MySQL root password to 'root'..."
        if mysql -u root <<EOF >/dev/null 2>&1
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF
        then
            log_success "MySQL configured with root/root"
        else
            log_warn "MySQL configuration failed (may already have a different password)"
        fi
    fi

    # PostgreSQL (optional)
    echo

    # Check if PostgreSQL is already installed
    if brew list postgresql@18 &>/dev/null; then
        log_warn "PostgreSQL already installed"

        # Check if running
        if ! brew services list | grep -q "postgresql@18.*started"; then
            log_info "Starting PostgreSQL service..."
            brew services start postgresql@18
        fi
    else
        if confirm "Install PostgreSQL?" N; then
            log_info "Installing PostgreSQL..."
            if brew install postgresql@18; then
                log_success "PostgreSQL installed"
            else
                log_error "Failed to install PostgreSQL"
            fi

            log_info "Starting PostgreSQL service..."
            brew link --force postgresql@18
            brew services start postgresql@18
            sleep 3

            log_info "Creating postgres user (postgres/postgres)..."
            if psql postgres -c "SELECT 1" -U postgres >/dev/null 2>&1; then
                log_warn "PostgreSQL already configured"
            else
                if createuser -s postgres 2>/dev/null; then
                    if psql postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';" 2>/dev/null; then
                        log_success "PostgreSQL configured"
                    else
                        log_warn "Failed to set PostgreSQL password"
                    fi
                else
                    log_warn "PostgreSQL user may already exist"
                fi
            fi
        else
            log_info "PostgreSQL installation skipped"
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
    echo -e "  ${BOLD}Databases:${RESET}"
    echo -e "    ${SILVER}• MySQL:${RESET} running (root/root)"

    if brew services list | grep -q "postgresql@18.*started"; then
        echo -e "    ${SILVER}• PostgreSQL:${RESET} running (postgres/postgres)"
    fi
}