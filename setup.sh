#!/bin/bash

set -euo pipefail

caffeinate -dims &
CAFFEINATE_PID=$!

formulae='1password-cli atuin bat composer eza fd micro fnm php@8.3 postgresql starship stow tlrc tree wget zsh-autosuggestions zsh-syntax-highlighting'

apps='adobe-creative-cloud affinity-designer affinity-photo affinity-publisher appcleaner daisydisk discord firefox ghostty google-chrome handbrake iina localsend microsoft-auto-update microsoft-edge microsoft-excel microsoft-powerpoint microsoft-word openemu postman setapp spotify suspicious-package transmission transmit virtualbuddy visual-studio-code vivaldi vlc'

fonts='font-alegreya font-alegreya-sans font-alegreya-sans-sc font-alegreya-sc font-alfa-slab-one font-atkinson-hyperlegible-next font-biorhyme font-biorhyme-expanded font-bree-serif font-crimson-pro font-crimson-text font-gilbert font-inter font-inter-tight font-jetbrains-mono font-jetbrains-mono-nerd-font font-lato font-libre-baskerville font-libre-bodoni font-libre-caslon-display font-libre-caslon-text font-libre-franklin font-licorice font-lora font-merriweather font-merriweather-sans font-monaspace font-montserrat font-montserrat-alternates font-montserrat-underline font-noto-color-emoji font-noto-emoji font-noto-sans font-noto-sans-display font-noto-sans-jp font-noto-sans-mono font-noto-sans-symbols font-noto-serif font-noto-serif-display font-noto-serif-hentaigana font-noto-serif-jp font-nunito font-nunito-sans font-open-sans font-outfit font-playfair font-playfair-display font-playfair-display-sc font-raleway font-raleway-dots font-redacted-script font-roboto font-roboto-condensed font-roboto-flex font-roboto-mono font-roboto-serif font-roboto-slab font-unica-one font-vollkorn font-vollkorn-sc font-yeseva-one'

casks="${apps} ${fonts}"

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

setup_git() {
    d_header "CONFIGURING GIT."
    git config --global user.name "Lionel Henne"
    git config --global user.email "lionelhenne@gmail.com"
    git config --global core.editor "code --wait"
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

install_homebrew_casks() {
    d_header "INSTALLING HOMEBREW CASKS."
    /opt/homebrew/bin/brew install --cask ${casks} || d_error "Failed to install Homebrew casks."
}

create_file_with_remaining_apps() {
    cd $HOME/Desktop
    touch remaining_apps.html
    cat <<EOF > remaining_apps.html
<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body{background-color:#f0f0f0;color:#333;font-size:1rem;margin:0;padding:1rem;font-family:HelveticaNeue,Helvetica,Arial,sans-serif;p{margin:0;padding:0;line-height:1.6rem;a{color:#333;}}}</style><title>Remaining Apps</title></head><body>
    <p><a href="https://www.cyberghostvpn.com/" target="_blank">CyberGhost VPN</a></p>
    <p><a href="https://www.devontechnologies.com/apps/freeware" target="_blank">EasyFind</a></p>
    <p><a href="https://account.microsoft.com/services?lang=fr-FR#main-content-landing-react" target="_blank">Microsoft Office</a></p>
    <p><a href="https://www.titanium-software.fr/fr/onyx.html" target="_blank">OnyX</a></p>
    <p><a href="https://itsalin.com/appInfo/?id=pearcleaner" target="_blank">Pearcleaner</a></p>
    <p><a href="https://www.jetbrains.com/fr-fr/phpstorm/" target="_blank">PhpStorm</a></p>
    <p><a href="https://github.com/DigiDNA/Silicon" target="_blank">Silicon</a></p>
    <p><a href="https://store.steampowered.com/?l=french" target="_blank">Steam</a></p>
    <p><a href="https://www.thunderbird.net/fr/" target="_blank">Thunderbird</a></p>
    <p><a href="https://ntfsformac.tuxera.com/" target="_blank">Tuxera NTFS</a></p>
</body>
</html>
EOF
    open -a "Google Chrome" $HOME/Desktop/remaining_apps.html --args --make-default-browser
}

main() {
    install_xcode_command_line_tools && \
    setup_git && \
    install_homebrew && \
    lauch_brew_services && \
    install_node_with_fnm && \
    backup_zprofile && \
    atuin_config && \
    install_dotfiles && \
    create_sites_and_developer_folders && \
    install_homebrew_casks && \
    create_file_with_remaining_apps
}

main && d_success "Installation completed successfully!" || d_error "Installation failed."

kill $CAFFEINATE_PID
