#!/bin/bash
set -u

# ==============================================================================
# CONFIGURATION & COLORS
# ==============================================================================
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[0;33m'
readonly BLUE=$'\033[0;34m'
readonly CYAN=$'\033[0;36m'
readonly GRAY=$'\033[0;90m'
readonly WHITE=$'\033[0;97m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

readonly WIDTH=65

# State Variables (Defaults as requested)
DO_CORE=true       # Default: YES
DO_GUI=true        # Default: YES
DO_DEFAULTS=false  # Default: NO
DO_WEB=true        # Default: YES
DO_MYSQL=true      # Default: YES
DO_PGSQL=false     # Default: NO

VISUAL_HISTORY=""

# ==============================================================================
# DEFINITIONS (PACKAGES & APPS)
# ==============================================================================

# Core formulae (Excluding databases and php which have their own steps)
readonly CORE_FORMULAE='atuin bat composer duf eza fd fnm gnu-tar micro mkcert nss ripgrep rsync starship stow tlrc tree wget zsh-autosuggestions zsh-syntax-highlighting'

readonly CASKS_APPS='1password 1password-cli adobe-creative-cloud affinity appcleaner betterdisplay cyberghost-vpn daisydisk discord firefox ghostty google-chrome handbrake iina localsend microsoft-edge openemu postman setapp spotify steam suspicious-package transmission transmit tuxera-ntfs virtualbuddy visual-studio-code vivaldi'

readonly CASKS_FONTS='font-alegreya font-alegreya-sans font-alegreya-sans-sc font-alegreya-sc font-alfa-slab-one font-atkinson-hyperlegible-next font-biorhyme font-biorhyme-expanded font-bree-serif font-cascadia-code font-crimson-pro font-crimson-text font-gilbert font-inter font-inter-tight font-jetbrains-mono font-jetbrains-mono-nerd-font font-lato font-libre-baskerville font-libre-bodoni font-libre-caslon-display font-libre-caslon-text font-libre-franklin font-licorice font-lora font-merriweather font-merriweather-sans font-monaspace font-montserrat font-montserrat-alternates font-montserrat-underline font-noto-color-emoji font-noto-emoji font-noto-sans font-noto-sans-display font-noto-sans-jp font-noto-sans-mono font-noto-sans-symbols font-noto-serif font-noto-serif-display font-noto-serif-hentaigana font-noto-serif-jp font-nunito font-nunito-sans font-open-sans font-outfit font-playfair font-playfair-display font-playfair-display-sc font-raleway font-raleway-dots font-redacted-script font-roboto font-roboto-condensed font-roboto-flex font-roboto-mono font-roboto-serif font-roboto-slab font-unica-one font-vollkorn font-vollkorn-sc font-yeseva-one'

# ==============================================================================
# UI ENGINE
# ==============================================================================

print_intro() {
    echo
    echo -e "🍎 ${BOLD}${BLUE}MACOS SETUP ASSISTANT ${RESET}"
    echo
}

get_visible_length() {
    local content="$1"
    local clean_content=$(echo -e "$content" | sed "s/\x1B\[[0-9;]*[a-zA-Z]//g")
    echo ${#clean_content}
}

draw_frame_top() {
    local text="$1"
    local width="$2"
    local text_len=$(get_visible_length "$text")
    local line_len=$((width - text_len - 4)) 
    if [ $line_len -lt 0 ]; then line_len=0; fi
    local line=$(printf '%*s' "$line_len" '' | tr ' ' '─')
    echo -e "${GRAY}┌ ${WHITE}${text} ${GRAY}${line}┐${RESET}"
}

draw_frame_row() {
    local content="$1" 
    local width="$2"
    local visible_len=$(get_visible_length "$content")
    local padding_len=$((width - visible_len - 3))
    if [ $padding_len -lt 0 ]; then padding_len=0; fi
    local padding=$(printf '%*s' "$padding_len" '')
    echo -e "${GRAY}│ ${RESET}${content}${padding}${GRAY}│${RESET}"
}

draw_frame_bottom() {
    local width="$1"
    local line_len=$((width - 2))
    local line=$(printf '%*s' "$line_len" '' | tr ' ' '─')
    echo -e "${GRAY}└${line}┘${RESET}"
}

# Usage: ask_visual_bool "Question" default_index (0=Yes, 1=No)
ask_visual_bool() {
    local question="$1"
    local selected="${2:-0}"
    local options=("Yes" "No")
    local key

    tput civis 

    while true; do
        clear
        print_intro
        
        if [[ -n "$VISUAL_HISTORY" ]]; then
            echo -e "$VISUAL_HISTORY"
            echo
        fi
        
        draw_frame_top "$question" "$WIDTH"

        for i in "${!options[@]}"; do
            local symbol="○"
            local label="${options[$i]}"
            local formatted_row=""

            if [ $i -eq $selected ]; then
                symbol="●"
                formatted_row="${CYAN}${symbol} ${BOLD}${label}${RESET}"
            else
                formatted_row="${GRAY}${symbol} ${label}${RESET}"
            fi
            draw_frame_row "$formatted_row" "$WIDTH"
        done
        
        draw_frame_bottom "$WIDTH"

        read -rsn1 key < /dev/tty
        case $key in
            $'\x1b')
                read -rsn2 key < /dev/tty
                case $key in
                    '[A') ((selected--)); [ $selected -lt 0 ] && selected=$((${#options[@]}-1)) ;;
                    '[B') ((selected++)); [ $selected -ge ${#options[@]} ] && selected=0 ;;
                esac
                ;;
            '') break ;;
        esac
    done

    tput cnorm 
    if [ $selected -eq 0 ]; then return 0; else return 1; fi
}

add_to_history() {
    local question="$1"
    local answer_bool="$2"
    local text_ans
    
    if [ "$answer_bool" = true ]; then
        text_ans="${GREEN}Yes${RESET}"
    else
        text_ans="${GRAY}No${RESET}"
    fi
    VISUAL_HISTORY+="${GRAY}${question} ${GRAY}....................${RESET} ${text_ans}\n"
}

# ==============================================================================
# LOGGING UTILS
# ==============================================================================

log_header() { printf "\n${BOLD}${GREEN}=== %s ===${RESET}\n" "$1"; }
log_info()   { printf "${BLUE}[INFO] %s${RESET}\n" "$1"; }
log_warning(){ printf "${YELLOW}[WARNING] %s${RESET}\n" "$1"; }
log_error()  { printf "${RED}[ERROR] %s${RESET}\n" "$1" >&2; exit 1; }
log_success(){ printf "${GREEN}[SUCCESS] %s${RESET}\n" "$1"; }

prevent_sleep() {
    if command -v caffeinate >/dev/null 2>&1; then
        caffeinate -dims &
        CAFFEINATE_PID=$!
        trap 'kill "$CAFFEINATE_PID" &>/dev/null 2>&1 || true' EXIT
    fi
}

check_sudo() {
    if ! sudo -v; then
        log_error "Sudo required. Aborting."
    fi
    while true; do sudo -n true; sleep 60; done 2>/dev/null &
    SUDO_REFRESH_PID=$!
    trap 'kill "$SUDO_REFRESH_PID" &>/dev/null 2>&1 || true' EXIT
}

# ==============================================================================
# MODULE 1: CORE SYSTEM
# ==============================================================================
module_core() {
    log_header "1. CORE SYSTEM SETUP"
    
    # Xcode
    if ! command -v xcode-select &>/dev/null; then
        xcode-select --install || true
    else
        log_info "Xcode CLI tools already installed"
    fi

    # Homebrew
    if ! command -v brew &>/dev/null; then
        log_info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        
        # Vérifier que brew est dispo
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Vérifier que ça a marché
        if ! command -v brew &>/dev/null; then
            log_error "Homebrew installation failed. Cannot continue."
        fi
        log_success "Homebrew installed"
    else
        log_info "Homebrew already installed"
    fi
    
    # Brew Packages
    log_info "Installing Core Formulae..."
    brew install ${CORE_FORMULAE} || log_warning "Some formulae failed to install"

    # SSH
    if [ ! -f "$HOME/.ssh/config" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        cat <<EOF > "$HOME/.ssh/config"
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

Host github.com
    HostName github.com
    User git
EOF
        chmod 600 "$HOME/.ssh/config"
        log_success "SSH config created"
    else
        log_info "SSH config already exists"
    fi

    # Node/FNM
    if command -v fnm &>/dev/null; then
        eval "$(fnm env --shell bash)"
        if ! fnm list | grep -q "lts"; then
            fnm install --lts
        else
            log_info "Node LTS already installed"
        fi
    fi

    # Dotfiles (Stow)
    if [ ! -d "$HOME/.dotfiles" ]; then
        log_info "Cloning dotfiles..."
        cd "$HOME"
        git clone https://github.com/lionelhenne/dotfiles.git .dotfiles
    else
        log_info "Dotfiles already cloned"
    fi
    
    cd "$HOME/.dotfiles"
    stow . --restow || log_warning "Stow had some conflicts"

    # Folders
    mkdir -p "$HOME/Sites" "$HOME/Developer"
    
    # Services
    if ! brew services list | grep -q "atuin.*started"; then
        brew services start atuin
    else
        log_info "Atuin already running"
    fi
}

# ==============================================================================
# MODULE 2: GUI APPLICATIONS
# ==============================================================================
module_gui() {
    log_header "2. GUI APPLICATIONS"
    brew install --cask ${CASKS_APPS} ${CASKS_FONTS} || log_warning "Some casks failed"
}

# ==============================================================================
# MODULE 3: WEB DEVELOPMENT (VALET)
# ==============================================================================
module_web() {
    log_header "3. WEB DEVELOPMENT (VALET)"
    
    # PHP Taps
    brew tap shivammathur/php
    brew tap shivammathur/extensions
    
    local COMPOSER_HOME
    if command -v composer &>/dev/null; then
        COMPOSER_HOME=$(composer config --global home)
    else
        COMPOSER_HOME="$HOME/.composer"
    fi
    
    local VALET_BIN="$COMPOSER_HOME/vendor/bin/valet"
    local VALET_INSTALLED=false
    
    # Installation
    if [[ ! -f "$VALET_BIN" ]]; then
        log_info "Installing Laravel Valet via Composer..."
        composer global require laravel/valet
        VALET_INSTALLED=true
    else
        log_info "Valet package already present."
    fi

    # Configuration (seulement si nouvelle install)
    if [[ -f "$VALET_BIN" ]]; then
        if [ "$VALET_INSTALLED" = true ]; then
            log_info "Configuring Valet..."
            "$VALET_BIN" install
            "$VALET_BIN" trust
            
            mkdir -p "$HOME/Sites"
            cd "$HOME/Sites"
            "$VALET_BIN" park
            log_success "Valet installed and parked in ~/Sites"
        else
            log_info "Valet already configured"
        fi
    else
        log_error "Valet binary not found at $VALET_BIN after installation."
    fi

    # PHPMonitor
    if [ ! -d "/Applications/PHP Monitor.app" ]; then
        log_info "Downloading PHP Monitor..."
        
        local phpmon_url="https://github.com/nicoverbruggen/phpmon/releases/download/v7.1/phpmon.zip"
        local phpmon_zip="/tmp/phpmon.zip"
        
        if curl -fsSL -o "$phpmon_zip" "$phpmon_url"; then
            if unzip -tq "$phpmon_zip" &>/dev/null; then
                unzip -q "$phpmon_zip" -d "/Applications"
                rm -f "$phpmon_zip"
                log_success "PHP Monitor installed"
            else
                log_warning "PHP Monitor zip is corrupted, skipping."
                rm -f "$phpmon_zip"
            fi
        else
            log_warning "Failed to download PHP Monitor, skipping."
        fi
    fi

    # phpinfo
    if [ ! -d "$HOME/Sites/phpinfo" ]; then
        log_info "Setting up phpinfo..."
        mkdir -p "$HOME/Sites/phpinfo"
        echo "<?php phpinfo();" > "$HOME/Sites/phpinfo/index.php"
        cd "$HOME/Sites/phpinfo"
        
        if [[ -f "$VALET_BIN" ]]; then
            "$VALET_BIN" secure phpinfo
        fi
        
        # Ouverture seulement après création
        if [ -d "/Applications/PHP Monitor.app" ]; then
            log_info "Opening PHP Monitor..."
            open -a "PHP Monitor"
        fi
        
        log_info "Opening phpinfo in browser..."
        open -a "Google Chrome" "https://phpinfo.test/"
    else
        log_info "phpinfo site already exists"
    fi
}

# ==============================================================================
# MODULE 4: MYSQL
# ==============================================================================
module_mysql() {
    log_header "4. MYSQL SETUP"
    
    # Installation seulement si absent
    if ! brew list mysql &>/dev/null; then
        log_info "Installing MySQL..."
        brew install mysql
    else
        log_info "MySQL already installed"
    fi
    
    # Check si déjà lancé
    if ! brew services list | grep -q "mysql.*started"; then
        brew services start mysql
        sleep 5
    else
        log_info "MySQL already running"
    fi
    
    # Vérifier si déjà sécurisé
    if mysql -u root -proot -e "SELECT 1;" &>/dev/null; then
        log_info "MySQL already secured"
    else
        log_info "Securing MySQL..."
        if mysql -u root -e "
            ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
            DELETE FROM mysql.user WHERE User='';
            DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
            DROP DATABASE IF EXISTS test;
            FLUSH PRIVILEGES;
        "; then
            log_success "MySQL secured (root password: root)"
        else
            log_warning "MySQL security setup failed."
        fi
    fi
}

# ==============================================================================
# MODULE 5: POSTGRESQL
# ==============================================================================
module_postgresql() {
    log_header "5. POSTGRESQL SETUP"
    
    # Installation seulement si absent
    if ! brew list postgresql@18 &>/dev/null; then
        log_info "Installing PostgreSQL 18..."
        brew install postgresql@18
        brew link --force postgresql@18
    else
        log_info "PostgreSQL 18 already installed"
    fi
    
    if ! brew services list | grep -q "postgresql@18.*started"; then
        brew services start postgresql@18
        log_success "PostgreSQL 18 started"
    else
        log_info "PostgreSQL 18 already running"
    fi
}

# ==============================================================================
# MODULE 6: MACOS DEFAULTS
# ==============================================================================
module_defaults() {
    log_header "6. MACOS PREFERENCES"
    
    # General
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
    defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool "false"
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "2"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    
    # Trackpad
    defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool "true"
    defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"
    
    # Dock
    defaults write com.apple.dock "autohide" -bool "true"
    defaults write com.apple.dock "tilesize" -int "32"
    defaults write com.apple.dock "minimize-to-application" -bool "true"
    defaults write com.apple.dock "show-recents" -bool "false"
    
    # Finder
    defaults write com.apple.finder "ShowPathbar" -bool "true"
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
    defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"
    
    # Restart services
    for app in "Dock" "Finder" "SystemUIServer"; do
        killall "${app}" >/dev/null 2>&1 || true
    done
}

# ==============================================================================
# MAIN EXECUTION FLOW
# ==============================================================================

main() {
    prevent_sleep
    check_sudo

    # --- INTERACTIVE SELECTION ---
    
    # 1. Core System (Default: YES/0)
    if ask_visual_bool "1. Install Core System (Brew, Node, Dotfiles)?" 0; then
        DO_CORE=true
        add_to_history "Core System" true
    else
        DO_CORE=false
        add_to_history "Core System" false
    fi

    # 2. GUI Apps (Default: YES/0)
    if ask_visual_bool "2. Install GUI Applications (Casks & Fonts)?" 0; then
        DO_GUI=true
        add_to_history "GUI Apps" true
    else
        DO_GUI=false
        add_to_history "GUI Apps" false
    fi

    # 3. Web Dev (Default: YES/0)
    if ask_visual_bool "3. Install Web Dev (Valet, PHP, PHPMon)?" 0; then
        DO_WEB=true
        add_to_history "Web Dev" true
    else
        DO_WEB=false
        add_to_history "Web Dev" false
    fi

    # 4. MySQL (Default: YES/0)
    if ask_visual_bool "4. Install MySQL (and secure it)?" 0; then
        DO_MYSQL=true
        add_to_history "MySQL" true
    else
        DO_MYSQL=false
        add_to_history "MySQL" false
    fi

    # 5. PostgreSQL (Default: NO/1)
    if ask_visual_bool "5. Install PostgreSQL 18?" 1; then
        DO_PGSQL=true
        add_to_history "PostgreSQL" true
    else
        DO_PGSQL=false
        add_to_history "PostgreSQL" false
    fi

    # 6. Defaults (Default: NO/1)
    if ask_visual_bool "6. Apply macOS System Defaults?" 1; then
        DO_DEFAULTS=true
        add_to_history "macOS Defaults" true
    else
        DO_DEFAULTS=false
        add_to_history "macOS Defaults" false
    fi

    # --- SUMMARY & EXECUTION ---
    clear
    print_intro
    echo -e "$VISUAL_HISTORY"
    echo -e "${CYAN}Starting installation in 3 seconds...${RESET}"
    sleep 3

    if [ "$DO_CORE" = true ]; then module_core; fi
    if [ "$DO_GUI" = true ]; then module_gui; fi
    if [ "$DO_WEB" = true ]; then module_web; fi
    if [ "$DO_MYSQL" = true ]; then module_mysql; fi
    if [ "$DO_PGSQL" = true ]; then module_postgresql; fi
    if [ "$DO_DEFAULTS" = true ]; then module_defaults; fi

    echo
    log_success "Installation sequence completed! 🚀"
    echo -e "You can reload your shell with: ${BOLD}source ~/.zshrc${RESET}"
}

main