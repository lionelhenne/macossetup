#!/bin/bash
set -euo pipefail
caffeinate -dims &
CAFFEINATE_PID=$!
trap 'kill "$CAFFEINATE_PID" &>/dev/null' EXIT
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
reset='\033[0m'
d_error() { printf "${red}[ERROR] %s${reset}\n" "$1" && exit 1 }
d_header() { printf "\n${green}%s${reset}\n" "$1" }
d_success() { printf "${green}[SUCCESS] %s${reset}\n" "$1" }
d_warning() { printf "${yellow}[WARNING] %s${reset}\n" "$1" }
d_info() { printf "${blue}[INFO] %s${reset}\n" "$1" }
sudo -v || d_error "Cannot acquire sudo privileges. Exiting."

install_valet() {
    d_header "INSTALLING LARAVEL VALET."
    if ! command -v $HOME/.config/composer/vendor/bin/valet &>/dev/null; then
        /opt/homebrew/bin/composer global require laravel/valet || d_error "Error installing Laravel Valet."
        $HOME/.config/composer/vendor/bin/valet install || d_error "Error running valet install."
        $HOME/.config/composer/vendor/bin/valet trust || d_error "Error running valet trust."
        if [ ! -d "$HOME/Sites" ]; then
            mkdir -p "$HOME/Sites" || d_error "Failed to create directory $HOME/Sites."
        fi
        cd "$HOME/Sites" || d_error "Directory $HOME/Sites does not exist."
        $HOME/.config/composer/vendor/bin/valet park || d_error "Error running valet park."
    else
        d_info "Laravel Valet already installed."
    fi
}

# update_php_fpm_for_php83() {
#     d_header "UPDATING PHP FPM FOR PHP@8.3."
#     if /opt/homebrew/bin/brew list --versions php@8.3 > /dev/null 2>&1; then
#         $HOME/.config/composer/vendor/bin/valet use php@8.3 || d_error "Error running valet use php@8.3." && \
#         $HOME/.config/composer/vendor/bin/valet install || d_error "Error running valet install."
#     fi
#     d_success "Valet updated for php@8.3. Switching back to latest php version."
#     $HOME/.config/composer/vendor/bin/valet use php || d_error "Error running valet use php"
# }

install_phpmon() {
    d_header "INSTALLING PHP MONITOR."
    if [ -d "/Applications/PHP Monitor.app" ]; then
        d_info "PHP Monitor already installed."
        exit 0
    fi

    curl -L -o "/tmp/phpmon.zip" "https://github.com/nicoverbruggen/phpmon/releases/download/v7.1/phpmon.zip" || d_error "PHP Monitor download failed."

    unzip -q "/tmp/phpmon.zip" -d "/Applications" && rm -rf /tmp/phpmon.zip || d_error "Failed to unzip PHP Monitor."
}

create_phpinfo_folder() {
    d_header "CREATING PHPINFO FOLDER."

    if [ ! -d "$HOME/Sites/phpinfo" ]; then
        mkdir -p "$HOME/Sites/phpinfo" || d_error "Failed to create directory $HOME/Sites/phpinfo."
    fi

    echo "<?php phpinfo();" > "$HOME/Sites/phpinfo/index.php" || d_error "Failed to create phpinfo file."

    cd "$HOME/Sites/phpinfo" || d_error "Directory $HOME/Sites/phpinfo does not exist."

    $HOME/.config/composer/vendor/bin/valet link phpinfo || d_error "Failed to link phpinfo."

    $HOME/.config/composer/vendor/bin/valet secure phpinfo || d_error "Failed to link phpinfo."
}

main() {
    install_valet && \
    # update_php_fpm_for_php83 && \
    install_phpmon && \
    create_phpinfo_folder && \
    open -a "PHP Monitor" && \
    open -a "Google Chrome" "https://phpinfo.test/"
}

main && d_success "Installation completed successfully!" || d_error "Installation failed."