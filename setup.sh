#!/bin/bash
#
# macOS bootstrap. Must run standalone (curl-pipeable): nothing else is on
# disk yet — neither this repo nor the dotfiles that provide
# ~/.local/lib/_common.sh — so this file never sources it and never prompts
# for input. Command Line Tools are installed by us, not left to Homebrew's
# own installer, specifically so this works with no TTY (see
# ensure_command_line_tools below). Once this finishes, the real repo is
# cloned locally and ./install.sh takes over for anything interactive.

set -u

abort() {
    printf "%s\n" "$@" >&2
    exit 1
}

[[ -z "${BASH_VERSION:-}" ]] && abort "Bash is required to interpret this script."

# ==============================================================================
# COLORS & LOGGING (inline copy of ~/.local/lib/_common.sh — see header note above)
# ==============================================================================

readonly CYAN=$'\033[38;5;51m'
readonly BLUE=$'\033[38;5;33m'
readonly GREEN=$'\033[38;5;42m'
readonly YELLOW=$'\033[38;5;214m'
readonly LIGHTRED=$'\033[38;5;203m'
readonly RED=$'\033[38;5;196m'
readonly SILVER=$'\033[38;5;250m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

log_header() { echo; echo -e "${CYAN}=== $1 ===${RESET}"; echo; }
log_info()    { echo -e "${BLUE}${BOLD}INFO${RESET}  ${SILVER}$*${RESET}"; }
log_success() { echo -e "${GREEN}${BOLD}DONE${RESET}  ${SILVER}$*${RESET}"; }
log_warn()    { echo -e "${YELLOW}${BOLD}WARN${RESET}  ${SILVER}$*${RESET}"; }
log_error()   { echo -e "${RED}${BOLD}FAIL${RESET}  ${LIGHTRED}$*${RESET}" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

execute() {
    if ! "$@"; then
        log_error "Failed during: $*"
    fi
}

retry() {
    local tries="$1" n="$1" pause=2
    shift
    local preview="$*"
    [[ ${#preview} -gt 80 ]] && preview="${preview:0:77}..."

    if "$@"; then return 0; fi
    while ((--n > 0)); do
        log_warn "Retrying in ${pause}s: ${preview}"
        sleep "${pause}"
        pause=$((pause * 2))
        if "$@"; then return 0; fi
    done
    log_error "Failed ${tries} times: ${preview}"
}

# ==============================================================================
# CONFIGURATION
# ==============================================================================

readonly REPO_URL="https://github.com/lionelhenne/macossetup.git"
readonly REPO_DIR="${MACOSSETUP_DIR:-$HOME/Developer/macossetup}"

# ==============================================================================
# CLEANUP
# ==============================================================================

cleanup() {
    if [[ -n "${CAFFEINATE_PID:-}" ]]; then
        kill "${CAFFEINATE_PID}" 2>/dev/null || true
    fi
    if [[ "${SUDO_WAS_ACTIVE:-0}" -eq 0 ]]; then
        sudo -k 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

prevent_sleep() {
    if command_exists caffeinate; then
        caffeinate -dims -t 3600 &
        CAFFEINATE_PID=$!
        log_info "Sleep prevention enabled"
    fi
}

ensure_sudo() {
    log_info "Requesting sudo access..."
    sudo -n true 2>/dev/null
    SUDO_WAS_ACTIVE=$?

    if ! sudo -v; then
        log_error "Sudo access required"
    fi
    log_success "Sudo access granted"
}

readonly CLT_GIT="/Library/Developer/CommandLineTools/usr/bin/git"

# Installs the Xcode Command Line Tools ourselves instead of leaving it to
# Homebrew's installer, which only waits for the GUI install when stdin is a
# TTY (via a blocking keypress read) — useless under `curl | bash`. We try
# the same silent softwareupdate path Homebrew uses internally, and if that
# fails, trigger the GUI installer and poll the filesystem for completion
# instead of reading a keypress, so it works with no TTY at all.
ensure_command_line_tools() {
    log_header "Xcode Command Line Tools"

    if [[ -e "${CLT_GIT}" ]]; then
        log_warn "Already installed"
        return 0
    fi

    log_info "Attempting silent install via softwareupdate..."
    local placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "${placeholder}"

    local clt_label
    clt_label="$(softwareupdate -l 2>/dev/null \
        | grep -B 1 -E "Command Line Tools" \
        | awk -F'*' '/^ *\*/ {print $2}' \
        | sed -e 's/^ *Label: //' -e 's/^ *//' \
        | sort -V \
        | tail -n1)"

    if [[ -n "${clt_label}" ]]; then
        log_info "Installing ${clt_label}..."
        sudo softwareupdate -i "${clt_label}"
    fi
    sudo rm -f "${placeholder}"

    if [[ -e "${CLT_GIT}" ]]; then
        sudo xcode-select --switch /Library/Developer/CommandLineTools
        log_success "Command Line Tools installed"
        return 0
    fi

    log_warn "Silent install unavailable on this Mac — triggering the GUI installer"
    log_info "A system dialog should appear; complete it whenever you're ready, this will wait for it"
    xcode-select --install 2>/dev/null || true

    local waited=0
    while [[ ! -e "${CLT_GIT}" ]]; do
        sleep 10
        waited=$((waited + 10))
        log_info "Still waiting for Command Line Tools (${waited}s)..."
        if ((waited >= 1800)); then
            log_error "Timed out after 30 minutes waiting for Command Line Tools. Finish the install manually and re-run this script."
        fi
    done

    sudo xcode-select --switch /Library/Developer/CommandLineTools
    log_success "Command Line Tools installed"
}

# ==============================================================================
# INSTALLATION STEPS
# ==============================================================================

install_homebrew() {
    log_header "Homebrew"

    if command_exists brew; then
        log_warn "Homebrew already installed"
        return 0
    fi

    log_info "Fetching Homebrew installer..."
    local installer
    installer="$(mktemp)"
    retry 3 curl -fsSL -o "${installer}" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

    log_info "Running Homebrew installer..."
    NONINTERACTIVE=1 execute /bin/bash "${installer}"
    rm -f "${installer}"

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    command_exists brew || log_error "Homebrew install finished but 'brew' is not on PATH"
    log_success "Homebrew installed"
}

clone_or_update_repo() {
    log_header "macossetup repository"

    if [[ -d "${REPO_DIR}/.git" ]]; then
        log_warn "Already cloned at ${REPO_DIR}"
        log_info "Pulling latest changes..."
        retry 3 git -C "${REPO_DIR}" pull --ff-only
        log_success "Repository up to date"
        return 0
    fi

    if [[ -e "${REPO_DIR}" ]]; then
        log_error "${REPO_DIR} already exists and is not a git clone of ${REPO_URL} — move it aside and re-run"
    fi

    log_info "Cloning ${REPO_URL}..."
    retry 3 git clone "${REPO_URL}" "${REPO_DIR}"
    log_success "Repository cloned to ${REPO_DIR}"
}

install_essentials() {
    log_header "Essential packages"

    local brewfile="${REPO_DIR}/inventory/Brewfile"
    [[ -f "${brewfile}" ]] || log_error "Brewfile not found at ${brewfile}"

    log_info "Installing core formulae, casks and fonts..."
    retry 3 brew bundle --file="${brewfile}"
    log_success "Core packages installed"
}

clone_dotfiles() {
    log_header "Dotfiles"
    local dotfiles_dir="$HOME/.dotfiles"
    
    if [[ -d "$dotfiles_dir" ]]; then
        log_warn "Dotfiles already cloned at $dotfiles_dir"
        return 0
    fi
    
    log_info "Cloning dotfiles repository..."
    if git clone https://github.com/lionelhenne/dotfiles.git "$dotfiles_dir"; then
        log_success "Dotfiles cloned to $dotfiles_dir"
        
        log_info "Installing GNU Stow..."
        brew install stow
        
        log_info "Applying dotfiles with Stow..."
        # Sécurité : on s'assure que ces dossiers existent pour éviter que stow ne crée un lien global foireux
        # (ex: ~/.local entier symlinké vers le repo si ~/.local/bin et ~/.local/lib n'existent pas encore)
        mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/lib"
        
        cd "$dotfiles_dir"
        if stow .; then
            log_success "Dotfiles applied"
        else
            log_error "Failed to apply dotfiles"
        fi
    else
        log_error "Failed to clone dotfiles"
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    log_header "macOS Bootstrap Setup"
    log_info "This installs Homebrew and the core toolset, then clones the"
    log_info "macossetup repo locally for further setup via ./install.sh"

    prevent_sleep
    ensure_sudo

    ensure_command_line_tools
    install_homebrew
    clone_or_update_repo
    clone_dotfiles
    install_essentials

    echo
    log_success "Bootstrap completed successfully!"
    echo
    log_info "Next steps:"
    echo
    echo -e "  ${BOLD}1. Configure 1Password${RESET}"
    echo -e "     ${SILVER}• Open 1Password app and sign in${RESET}"
    echo -e "     ${SILVER}• Settings > Developer > Enable CLI integration${RESET}"
    echo -e "     ${SILVER}• Settings > Developer > Enable SSH Agent${RESET}"
    echo
    echo -e "  ${BOLD}2. Restart your terminal${RESET}"
    echo
    echo -e "  ${BOLD}3. Run the module installer:${RESET}"
    echo -e "     ${CYAN}cd ${REPO_DIR} && ./install.sh${RESET}"
    echo
}

main "$@"
