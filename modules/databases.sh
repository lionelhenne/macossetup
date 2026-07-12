#!/bin/bash
# databases.sh
# Database Servers Setup

run() {
    log_header "Databases Setup"

    install_mysql
    echo
    install_postgresql

    echo
    log_success "Databases setup completed!"
    echo

    # Display summary
    log_info "Installation summary:"
    echo
    echo -e "  ${BOLD}Databases:${RESET}"

    if brew services list | grep -q "mysql.*started"; then
        echo -e "    ${SILVER}• MySQL:${RESET} running (root/root)"
    else
        echo -e "    ${SILVER}• MySQL:${RESET} not installed"
    fi

    if brew services list | grep -q "postgresql@18.*started"; then
        echo -e "    ${SILVER}• PostgreSQL:${RESET} running (postgres/postgres)"
    else
        echo -e "    ${SILVER}• PostgreSQL:${RESET} not installed"
    fi
}

install_mysql() {
    log_header "MySQL"

    if brew list mysql &>/dev/null; then
        log_warn "MySQL already installed"
    else
        if ! confirm "Install MySQL?" N; then
            log_info "MySQL installation skipped"
            return 0
        fi

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
}

install_postgresql() {
    log_header "PostgreSQL"

    if brew list postgresql@18 &>/dev/null; then
        log_warn "PostgreSQL already installed"

        if ! brew services list | grep -q "postgresql@18.*started"; then
            log_info "Starting PostgreSQL service..."
            brew services start postgresql@18
        fi
    else
        if ! confirm "Install PostgreSQL?" N; then
            log_info "PostgreSQL installation skipped"
            return 0
        fi

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
    fi

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
}
