#!/bin/bash

# ==============================================================================
# COLORS
# ==============================================================================

if [[ -z "${MAGENTA:-}" ]]; then
    readonly WHITE=$'\033[38;5;255m'
    readonly CYAN=$'\033[38;5;51m'
    readonly BLUE=$'\033[38;5;33m'
    readonly GREEN=$'\033[38;5;42m'
    readonly YELLOW=$'\033[38;5;214m'
    readonly LIGHTRED=$'\033[38;5;203m'
    readonly RED=$'\033[38;5;196m'
    readonly MAGENTA=$'\033[38;5;212m'
    readonly SILVER=$'\033[38;5;250m'
    readonly GRAY=$'\033[38;5;240m'
    readonly BOLD=$'\033[1m'
    readonly RESET=$'\033[0m'
fi

# ==============================================================================
# LOGGING
# ==============================================================================

log_header() {
    echo
    echo -e "${CYAN}=== $1 ===${RESET}"
    echo
}

log_info() {
    echo -e "${BLUE}${BOLD}INFO${RESET}  ${SILVER}$*${RESET}"
}

log_success() {
    echo -e "${GREEN}${BOLD}DONE${RESET}  ${SILVER}$*${RESET}"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}WARN${RESET}  ${SILVER}$*${RESET}"
}

log_error() {
    echo -e "${RED}${BOLD}FAIL${RESET}  ${LIGHTRED}$*${RESET}" >&2
    exit 1
}

# ==============================================================================
# HELPERS
# ==============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run a command, abort with a uniform message if it fails.
# Usage: execute brew install php
execute() {
    if ! "$@"; then
        log_error "Failed during: $*"
    fi
}

# Retry a command with exponential backoff before giving up.
# Usage: retry 5 curl -fsSL -o file.zip https://example.com/file.zip
retry() {
    local tries="$1" n="$1" pause=2
    shift
    local preview="$*"
    [[ ${#preview} -gt 80 ]] && preview="${preview:0:77}..."

    if "$@"; then
        return 0
    fi

    while ((--n > 0)); do
        log_warn "Retrying in ${pause}s: ${preview}"
        sleep "${pause}"
        pause=$((pause * 2))
        if "$@"; then
            return 0
        fi
    done

    log_error "Failed ${tries} times: ${preview}"
}

# ==============================================================================
# INTERACTION
# ==============================================================================

# Usage: prompt "Message" [variable_name]
prompt() {
    local message="$1"
    local var_name="$2"

    read -r -p "$(echo -e "${MAGENTA}${BOLD}USER${RESET}  ${WHITE}${message}${RESET} ")" response

    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$response"
    else
        echo "$response"
    fi
}

# Usage: confirm "Question" [Y|N]
confirm() {
    local msg="$1"
    local default="${2:-}"
    local response
    local suffix

    case "$default" in
        [Yy]) suffix="(${MAGENTA}${BOLD}Y${RESET}/n)" ;;
        [Nn]) suffix="(y/${MAGENTA}${BOLD}N${RESET})" ;;
        *) suffix="(y/n)" ;;
    esac

    while true; do
        read -r -p "$(echo -e "${MAGENTA}${BOLD}USER${RESET}  ${SILVER}${msg} ${suffix}:${RESET} ")" response
        [[ -z "$response" && -n "$default" ]] && response="$default"

        case "$response" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "      ${YELLOW}${BOLD}Please answer y or n${RESET}" ;;
        esac
    done
}
