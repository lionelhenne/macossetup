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

readonly COMPOSER_BIN_DIR="$(composer config --global home)/vendor/bin"

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

add_php_taps() {
    log_header "ADDING PHP HOMEBREW TAPS."
    /opt/homebrew/bin/brew tap shivammathur/php
    /opt/homebrew/bin/brew tap shivammathur/extensions
}

install_valet() {
    log_header "INSTALLING LARAVEL VALET."
    if ! command -v "$COMPOSER_BIN_DIR/valet" &>/dev/null; then
        /opt/homebrew/bin/composer global require laravel/valet || log_error "Error installing Laravel Valet."
        "$COMPOSER_BIN_DIR/valet" install || log_error "Error running valet install."
        "$COMPOSER_BIN_DIR/valet" trust || log_error "Error running valet trust."
        if [ ! -d "$HOME/Sites" ]; then
            mkdir -p "$HOME/Sites" || log_error "Failed to create directory $HOME/Sites."
        fi
        cd "$HOME/Sites" || log_error "Directory $HOME/Sites does not exist."
        "$COMPOSER_BIN_DIR/valet" park || log_error "Error running valet park."
    else
        log_info "Laravel Valet already installed."
    fi
}

install_phpmon() {
    log_header "INSTALLING PHP MONITOR."
    if [ -d "/Applications/PHP Monitor.app" ]; then
        log_info "PHP Monitor already installed."
        return 0
    fi

    curl -L -o "/tmp/phpmon.zip" "https://github.com/nicoverbruggen/phpmon/releases/download/v7.1/phpmon.zip" || log_error "PHP Monitor download failed."

    unzip -q "/tmp/phpmon.zip" -d "/Applications" && rm -rf /tmp/phpmon.zip || log_error "Failed to unzip PHP Monitor."
}

create_phpinfo_folder() {
    log_header "CREATING PHPINFO FOLDER."

    if [ ! -d "$HOME/Sites/phpinfo" ]; then
        mkdir -p "$HOME/Sites/phpinfo" || log_error "Failed to create directory $HOME/Sites/phpinfo."
    fi

    echo "<?php phpinfo();" > "$HOME/Sites/phpinfo/index.php" || log_error "Failed to create phpinfo file."

    cd "$HOME/Sites/phpinfo" || log_error "Directory $HOME/Sites/phpinfo does not exist."

    "$COMPOSER_BIN_DIR/valet" link phpinfo || log_error "Failed to link phpinfo."

    "$COMPOSER_BIN_DIR/valet" secure phpinfo || log_error "Failed to link phpinfo."
}

main() {
    prevent_sleep
    add_php_taps
    install_valet
    install_phpmon
    create_phpinfo_folder
    open -a "PHP Monitor"
    open -a "Google Chrome" "https://phpinfo.test/"
}

main && log_success "Valet installation completed successfully!" || log_error "Valet installation failed."
