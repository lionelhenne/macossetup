#!/bin/bash

set -euo pipefail

formulae='1password-cli atuin bat composer eza fd font-jetbrains-mono font-jetbrains-mono-nerd-font font-monaspace micro fnm php@8.3 postgresql starship stow tlrc tree wget zsh-autosuggestions zsh-syntax-highlighting'

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
reset='\033[0m'

d_error() {
    printf "${red}[ERROR] %s${reset}\n" "$1"
    exit 1
}

d_header() {
    printf "\n${green}%s${reset}\n" "$1"
}

d_success() {
    printf "${green}[SUCCESS] %s${reset}\n" "$1"
}

d_warning() {
    printf "${yellow}[WARNING] %s${reset}\n" "$1"
}

d_info() {
    printf "${blue}[INFO] %s${reset}\n" "$1"
}

if ! sudo -v; then
    d_error "Cannot acquire sudo privileges. Exiting."
fi

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.config/composer/vendor/bin:$PATH"

install_xcode_command_line_tools() {
    d_header "INSTALLING XCODE COMMAND LINE TOOLS."
    if ! command -v /usr/bin/xcode-select &>/dev/null; then
        /usr/bin/xcode-select --install || d_error "Failed to install Xcode Command Line Tools."
    else
        d_info "Xcode Command Line Tools already installed."
    fi
}

install_homebrew() {
    d_header "INSTALLING HOMEBREW AND FORMULAE."
    if ! command -v /opt/homebrew/bin/brew &>/dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && /opt/homebrew/bin/brew update || d_error "Failed to install Homebrew."
    else
        d_info "Homebrew already installed."
    fi
    /opt/homebrew/bin/brew install ${formulae} || d_error "Failed to install Homebrew formulae."
}

lauch_brew_services() {
    d_header "LAUNCHING HOMEBREW SERVICES."
    /opt/homebrew/bin/brew services start atuin
    /opt/homebrew/bin/brew services start postgresql
}

install_node_with_fnm() {
    d_header "INSTALLING NODE.JS WITH FNM."
    /opt/homebrew/bin/fnm install --lts
}

backup_zprofile() {
    d_header "BACKING UP .zprofile."
    cd "$HOME" || d_error "Error changing directory to $HOME."
    if [ -e $HOME/.zprofile ]; then
        mv $HOME/.zprofile $HOME/.zprofile.bak || d_error "Error backing up .zprofile."
    fi
}

atuin_config() {
    d_header "ATUIN CONFIGURATION."
    if [ -d "$HOME/.config/atuin" ]; then
        /opt/homebrew/bin/atuin import auto
        export ATUIN_CONFIG_DIR="$HOME/.dotfiles/.config/atuin" && rm -rf "$HOME/.config/atuin/config.toml"
    else
        d_warning "Atuin configuration directory does not exist. Skipping import."
    fi
}

install_dotfiles() {
    d_header "INSTALLING DOTFILES."
    cd "$HOME"
    if [ ! -d ".dotfiles" ]; then
        /usr/bin/git clone https://github.com/lionelhenne/dotfiles.git .dotfiles || d_error "Failed to clone dotfiles repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || d_error "Failed to stow dotfiles."
    elif [ -z "$(ls -A .dotfiles)" ]; then
        /usr/bin/git clone https://github.com/lionelhenne/dotfiles.git .dotfiles || d_error "Failed to clone dotfiles repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || d_error "Failed to stow dotfiles."
    elif [ -d ".dotfiles/.git" ]; then
        d_info "Dotfiles repository already exists and is a git repository."
        cd $HOME/.dotfiles
        /opt/homebrew/bin/stow . || d_error "Failed to stow dotfiles."
    else
        d_warning ".dotfiles directory exists but is not a git repository. Skipping stow."
    fi
}

create_sites_and_developer_folders() {
    d_header "CREATING SITES AND DEVELOPER FOLDERS."
    if [ ! -d "$HOME/Sites" ]; then
        mkdir -p "$HOME/Sites" || d_error "Failed to create directory $HOME/Sites."
    fi
    if [ ! -d "$HOME/Developer" ]; then
        mkdir -p "$HOME/Developer" || d_error "Failed to create directory $HOME/Developer."
    fi
}

main() {
    install_xcode_command_line_tools && \
    install_homebrew && \
    lauch_brew_services && \
    install_node_with_fnm && \
    backup_zprofile && \
    atuin_config && \
    install_dotfiles && \
    create_sites_and_developer_folders
}

main && d_success "Installation completed successfully!" || d_error "Installation failed."