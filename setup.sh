#!/bin/bash
set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

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

formulae='1password-cli atuin bat composer duf eza fd fnm micro mkcert nss postgresql starship stow tlrc tree wget zsh-autosuggestions zsh-syntax-highlighting'

apps='1password adobe-creative-cloud affinity-designer affinity-photo affinity-publisher appcleaner betterdisplay daisydisk discord firefox ghostty google-chrome handbrake iina keka localsend microsoft-auto-update microsoft-edge microsoft-excel microsoft-powerpoint microsoft-word mimestream openemu opera postman setapp spotify suspicious-package transmission transmit virtualbuddy visual-studio-code vivaldi'

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
    /opt/homebrew/bin/brew services start postgresql
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

create_file_with_remaining_apps() {
    cd $HOME/Desktop
    touch remaining_apps.html
    cat <<EOF > remaining_apps.html
<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body{background-color:#f0f0f0;color:#333;font-size:1rem;margin:0;padding:1rem;font-family:HelveticaNeue,Helvetica,Arial,sans-serif;p{margin:0;padding:0;line-height:1.6rem;a{color:#333;}}}</style><title>Remaining Apps</title></head><body>
    <p><a href="https://www.cyberghostvpn.com/" target="_blank">CyberGhost VPN</a></p>
    <p><a href="https://github.com/DigiDNA/Silicon" target="_blank">Silicon</a></p>
    <p><a href="https://store.steampowered.com/?l=french" target="_blank">Steam</a></p>
    <p><a href="https://ntfsformac.tuxera.com/" target="_blank">Tuxera NTFS</a></p>
</body>
</html>
EOF
    open -a "Google Chrome" $HOME/Desktop/remaining_apps.html --args --make-default-browser
}

main() {
    prevent_sleep
    check_sudo
    install_xcode_command_line_tools
    install_homebrew
    setup_ssh_config
    launch_brew_services
    install_node_with_fnm
    backup_zprofile
    atuin_config
    install_dotfiles
    create_sites_and_developer_folders
    install_homebrew_casks
    create_file_with_remaining_apps
}

main && log_success "Installation completed successfully!" || log_error "Installation failed."
