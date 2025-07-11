#!/bin/bash
set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

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

install_valet() {
    log_header "INSTALLING LARAVEL VALET."
    if ! command -v $HOME/.config/composer/vendor/bin/valet &>/dev/null; then
        /opt/homebrew/bin/composer global require laravel/valet || log_error "Error installing Laravel Valet."
        $HOME/.config/composer/vendor/bin/valet install || log_error "Error running valet install."
        $HOME/.config/composer/vendor/bin/valet trust || log_error "Error running valet trust."
        if [ ! -d "$HOME/Sites" ]; then
            mkdir -p "$HOME/Sites" || log_error "Failed to create directory $HOME/Sites."
        fi
        cd "$HOME/Sites" || log_error "Directory $HOME/Sites does not exist."
        $HOME/.config/composer/vendor/bin/valet park || log_error "Error running valet park."
    else
        log_info "Laravel Valet already installed."
    fi
}

# update_php_fpm_for_php83() {
#     log_header "UPDATING PHP FPM FOR PHP@8.3."
#     if /opt/homebrew/bin/brew list --versions php@8.3 > /dev/null 2>&1; then
#         $HOME/.config/composer/vendor/bin/valet use php@8.3 || log_error "Error running valet use php@8.3." && \
#         $HOME/.config/composer/vendor/bin/valet install || log_error "Error running valet install."
#     fi
#     log_success "Valet updated for php@8.3. Switching back to latest php version."
#     $HOME/.config/composer/vendor/bin/valet use php || log_error "Error running valet use php"
# }

install_phpmon() {
    log_header "INSTALLING PHP MONITOR."
    if [ -d "/Applications/PHP Monitor.app" ]; then
        log_info "PHP Monitor already installed."
        exit 0
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

    $HOME/.config/composer/vendor/bin/valet link phpinfo || log_error "Failed to link phpinfo."

    $HOME/.config/composer/vendor/bin/valet secure phpinfo || log_error "Failed to link phpinfo."
}

main() {
    prevent_sleep && \
    install_valet && \
    # update_php_fpm_for_php83 && \
    install_phpmon && \
    create_phpinfo_folder && \
    open -a "PHP Monitor" && \
    open -a "Google Chrome" "https://phpinfo.test/"
}

main && log_success "Valet installation completed successfully!" || log_error "Valet installation failed."