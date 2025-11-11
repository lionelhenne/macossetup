#!/bin/bash
set -euo pipefail

readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[0;33m'
readonly BLUE=$'\033[0;34m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

log_error() { printf "${RED}[ERROR] %s${RESET}\n" "$1" >&2; exit 1; }
log_header() { printf "\n${BOLD}${GREEN}=== %s ===${RESET}\n" "$1"; }
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

check_sudo() {
    if ! sudo -v; then
        log_error "Administrateur privileges required but not available. Installation aborted."
    fi
    while true; do sudo -n true; sleep 60; done 2>/dev/null &
    SUDO_REFRESH_PID=$!
    trap 'kill "$SUDO_REFRESH_PID" &>/dev/null 2>&1 || true' EXIT
}

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.config/composer/vendor/bin:$PATH"

formulae='atuin bat composer duf eza fd fnm gnu-tar micro mkcert mysql nss postgresql@18 ripgrep rsync starship stow tlrc tree wget zsh-autosuggestions zsh-syntax-highlighting'

apps='1password 1password-cli adobe-creative-cloud affinity appcleaner betterdisplay cyberghost-vpn daisydisk discord firefox ghostty google-chrome handbrake iina localsend microsoft-edge openemu postman setapp spotify steam suspicious-package transmission transmit tuxera-ntfs virtualbuddy visual-studio-code vivaldi'

fonts='font-alegreya font-alegreya-sans font-alegreya-sans-sc font-alegreya-sc font-alfa-slab-one font-atkinson-hyperlegible-next font-biorhyme font-biorhyme-expanded font-bree-serif font-cascadia-code font-crimson-pro font-crimson-text font-gilbert font-inter font-inter-tight font-jetbrains-mono font-jetbrains-mono-nerd-font font-lato font-libre-baskerville font-libre-bodoni font-libre-caslon-display font-libre-caslon-text font-libre-franklin font-licorice font-lora font-merriweather font-merriweather-sans font-monaspace font-montserrat font-montserrat-alternates font-montserrat-underline font-noto-color-emoji font-noto-emoji font-noto-sans font-noto-sans-display font-noto-sans-jp font-noto-sans-mono font-noto-sans-symbols font-noto-serif font-noto-serif-display font-noto-serif-hentaigana font-noto-serif-jp font-nunito font-nunito-sans font-open-sans font-outfit font-playfair font-playfair-display font-playfair-display-sc font-raleway font-raleway-dots font-redacted-script font-roboto font-roboto-condensed font-roboto-flex font-roboto-mono font-roboto-serif font-roboto-slab font-unica-one font-vollkorn font-vollkorn-sc font-yeseva-one'

casks="${apps} ${fonts}"

install_xcode_command_line_tools() {
    log_header "INSTALLING XCODE COMMAND LINE TOOLS."
    if ! command -v /usr/bin/xcode-select &>/dev/null; then
        /usr/bin/xcode-select --install || log_error "Failed to install Xcode Command Line Tools."
    else
        log_info "Xcode Command Line Tools already installed."
    fi
}

install_homebrew() {
    log_header "INSTALLING HOMEBREW AND FORMULAE."
    if ! command -v /opt/homebrew/bin/brew &>/dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && /opt/homebrew/bin/brew update || log_error "Failed to install Homebrew."
    else
        log_info "Homebrew already installed."
    fi
    /opt/homebrew/bin/brew install ${formulae} || log_error "Failed to install Homebrew formulae."
}

setup_ssh_config() {
    log_header "CONFIGURING SSH FOR 1PASSWORD AND GITHUB"
    local ssh_dir="$HOME/.ssh"
    local ssh_config_file="$ssh_dir/config"

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    if [ ! -f "$ssh_config_file" ]; then
        log_info "Creating SSH config file for 1Password Agent..."
        cat <<EOF > "$ssh_config_file"
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

Host github.com
    HostName github.com
    User git

Host hostinger
    HostName 147.93.92.46
    User u520650353
    Port 65002
EOF
        chmod 600 "$ssh_config_file"
        log_success "SSH config created successfully."
    else
        log_info "SSH config file already exists. Skipping creation."
    fi
}

launch_brew_services() {
    log_header "LAUNCHING HOMEBREW SERVICES."
    /opt/homebrew/bin/brew services start atuin
    /opt/homebrew/bin/brew services start mysql
    /opt/homebrew/bin/brew services start postgresql
}

secure_mysql() {
    log_header "SECURING MYSQL INSTALLATION"
    sleep 5
    log_info "Setting up MySQL root password and security..."
    /opt/homebrew/bin/mysql -u root -e "
        ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
    " || log_warning "MySQL security setup failed. You may need to run mysql_secure_installation manually."
    log_success "MySQL secured successfully."
}

install_node_with_fnm() {
    log_header "INSTALLING NODE.JS WITH FNM."
    /opt/homebrew/bin/fnm install --lts
}

backup_zprofile() {
    log_header "BACKING UP .zprofile."
    cd "$HOME" || log_error "Error changing directory to $HOME."
    if [ -e "$HOME/.zprofile" ]; then
        mv $HOME/.zprofile $HOME/.zprofile.bak || log_error "Error backing up .zprofile."
    fi
}

atuin_config() {
    log_header "ATUIN CONFIGURATION."
    if [ -d "$HOME/.config/atuin" ]; then
        /opt/homebrew/bin/atuin import auto
        export ATUIN_CONFIG_DIR="$HOME/.dotfiles/.config/atuin"
        rm -rf "$HOME/.config/atuin/config.toml"
    else
        log_warning "Atuin configuration directory does not exist. Skipping import."
    fi
}

install_dotfiles() {
    log_header "INSTALLING DOTFILES."
    cd "$HOME"
    if [ ! -d ".dotfiles" ]; then
        /usr/bin/git clone https://github.com/lionelhenne/dotfiles.git .dotfiles || log_error "Failed to clone dotfiles repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || log_error "Failed to stow dotfiles."
    elif [ -z "$(ls -A .dotfiles)" ]; then
        /usr/bin/git clone https://github.com/lionelhenne/dotfiles.git .dotfiles || log_error "Failed to clone dotfiles repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || log_error "Failed to stow dotfiles."
    elif [ -d ".dotfiles/.git" ]; then
        log_info "Dotfiles repository already exists and is a git repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || log_error "Failed to stow dotfiles."
    else
        log_warning ".dotfiles directory exists but is not a git repository. Skipping stow."
    fi
}

create_sites_and_developer_folders() {
    log_header "CREATING SITES AND DEVELOPER FOLDERS."
    if [ ! -d "$HOME/Sites" ]; then
        mkdir -p "$HOME/Sites" || log_error "Failed to create directory $HOME/Sites."
    fi
    if [ ! -d "$HOME/Developer" ]; then
        mkdir -p "$HOME/Developer" || log_error "Failed to create directory $HOME/Developer."
    fi
}

install_homebrew_casks() {
    log_header "INSTALLING HOMEBREW CASKS."
    /opt/homebrew/bin/brew install --cask ${casks} || log_error "Failed to install Homebrew casks."
}

install_mbu() {
    log_header "INSTALLING MBU SCRIPT."
    local bin_dir="$HOME/.local/bin"
    
    mkdir -p "$bin_dir"
    
    curl -fsSL https://raw.githubusercontent.com/lionelhenne/mbu/refs/heads/main/mbu -o "$bin_dir/mbu" || log_error "Failed to download mbu."
    chmod +x "$bin_dir/mbu"
    
    log_success "mbu installed in $bin_dir"
}

main() {
    prevent_sleep
    check_sudo
    install_xcode_command_line_tools
    install_homebrew
    setup_ssh_config
    launch_brew_services
    secure_mysql
    install_node_with_fnm
    backup_zprofile
    atuin_config
    install_dotfiles
    install_mbu
    create_sites_and_developer_folders
    install_homebrew_casks
}

main && log_success "Installation completed successfully!" || log_error "Installation failed."
