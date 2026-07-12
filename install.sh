#!/bin/bash
#
# Module dispatcher. Only ever run locally from a cloned checkout — never
# curl-piped, since modules prompt for input (SSH key choice, cask profile,
# confirmations) and need sibling files on disk.

set -u

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"

source "${SCRIPT_DIR}/lib/_common.sh"

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
    echo "3) Applications (Casks)"
    echo "4) Fonts"
    echo "0) Exit"
    echo

    read -r -p "$(echo -e "${MAGENTA}${BOLD}USER${RESET}  ${SILVER}Select module (0-4):${RESET} ")" choice

    case "$choice" in
        1) run_module "identity" ;;
        2) run_module "webdev" ;;
        3) run_module "casks" ;;
        4) run_module "fonts" ;;
        0) log_info "Exiting"; exit 0 ;;
        *) log_error "Invalid choice: $choice" ;;
    esac
}

if [[ $# -gt 0 ]]; then
    run_module "$1"
else
    show_menu
fi
