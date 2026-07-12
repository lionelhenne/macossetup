#!/bin/bash
#
# Module dispatcher. Only ever run locally from a cloned checkout — never
# curl-piped, since modules prompt for input (SSH key choice, confirmations)
# and need sibling files on disk.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"

# Shared with cockpit-tool and laravel-tool — managed in the dotfiles repo,
# stowed to ~/.local/lib. log_error() there does `return 1` (not `exit 1`,
# safe to source into an interactive shell), which is why this script runs
# under `set -e`: a bare `log_error "..."` still halts execution.
readonly COMMON_LIB="$HOME/.local/lib/_common.sh"
if [[ ! -f "$COMMON_LIB" ]]; then
    echo "Missing ${COMMON_LIB} — run ./setup.sh first (it clones dotfiles via stow)." >&2
    exit 1
fi
source "$COMMON_LIB"

if [[ ! -t 0 ]]; then
    log_error "install.sh needs an interactive terminal. Clone the repo and run it locally: cd ${SCRIPT_DIR} && ./install.sh"
fi

run_module() {
    local module="$1"
    local module_path="${MODULES_DIR}/${module}.sh"

    [[ -f "${module_path}" ]] || log_error "Module not found: ${module}"

    source "${module_path}"
    run
}

show_menu() {
    log_header "macossetup"

    echo "1) Identity (Git/SSH)"
    echo "2) Web Development"
    echo "3) Databases"
    echo "4) Applications (Casks)"
    echo "5) Mac App Store"
    echo "6) Fonts"
    echo "0) Exit"
    echo

    read -r -p "$(echo -e "${MAGENTA}${BOLD}USER${RESET}  ${SILVER}Select module (0-6):${RESET} ")" choice

    case "$choice" in
        1) run_module "identity" ;;
        2) run_module "webdev" ;;
        3) run_module "databases" ;;
        4) run_module "casks" ;;
        5) run_module "mas" ;;
        6) run_module "fonts" ;;
        0) log_info "Exiting"; exit 0 ;;
        *) log_error "Invalid choice: $choice" ;;
    esac
}

if [[ $# -gt 0 ]]; then
    run_module "$1"
else
    show_menu
fi
