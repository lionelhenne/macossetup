#!/bin/bash
set -u
# ==============================================================================
# CONFIGURATION & COLORS
# ==============================================================================
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
WHITE=$'\033[0;97m'
BOLD=$'\033[1m'
RESET=$'\033[0m'
readonly WIDTH=65
readonly SSH_HOSTS_ITEM_NAME="SSH_HOSTS_CONFIG"
# ==============================================================================
# LOGGING UTILS
# ==============================================================================
log_header() { printf "\n${BOLD}${BLUE}=== %s ===${RESET}\n" "$1"; }
log_info()   { printf "ℹ️  %s${RESET}\n" "$1" >&2; }
log_success(){ printf "${GREEN}✅ [SUCCESS] %s${RESET}\n" "$1" >&2; }
log_error()  { printf "${RED}❌ [ERROR] %s${RESET}\n" "$1" >&2; exit 1; }
log_warning(){ printf "${YELLOW}⚠️  [WARNING] %s${RESET}\n" "$1" >&2; }
# ==============================================================================
# UI ENGINE
# ==============================================================================
print_intro() {
    echo -e "🔐 ${BOLD}${BLUE}MACOS POST-INSTALL SECRETS ASSISTANT ${RESET}\n" >/dev/tty
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
    [ $line_len -lt 0 ] && line_len=0
    local line=$(printf '%*s' "$line_len" '' | tr ' ' '─')
    echo -e "${GRAY}┌ ${WHITE}${text} ${GRAY}${line}┐${RESET}" >/dev/tty
}
draw_frame_row() {
    local content="$1"
    local width="$2"
    local visible_len=$(get_visible_length "$content")
    local padding_len=$((width - visible_len - 3))
    [ $padding_len -lt 0 ] && padding_len=0
    local padding=$(printf '%*s' "$padding_len" '')
    echo -e "${GRAY}│ ${RESET}${content}${padding}${GRAY}│${RESET}" >/dev/tty
}
draw_frame_bottom() {
    local width="$1"
    local line_len=$((width - 2))
    local line=$(printf '%*s' "$line_len" '' | tr ' ' '─')
    echo -e "${GRAY}└${line}┘${RESET}" >/dev/tty
}
ask_visual_choice() {
    local question="$1"
    shift 1
    local options=("$@")
    local selected=0
    local key
    tput civis >/dev/tty
    while true; do
        tput clear >/dev/tty
        print_intro

        draw_frame_top "$question" "$WIDTH"
        for i in "${!options[@]}"; do
            local symbol="○"
            local label="${options[$i]}"
            local formatted_row=""

            if [ ${#label} -gt $((WIDTH - 6)) ]; then
                label="${label:0:$((WIDTH - 7))}…"
            fi
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
    tput cnorm >/dev/tty
    echo "$selected"
}
ask_visual_bool() {
    local question="$1"
    local selected="${2:-0}"
    local options=("Yes" "No")
    local key
    tput civis >/dev/tty
    while true; do
        tput clear >/dev/tty
        print_intro

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
    tput cnorm >/dev/tty
    if [ $selected -eq 0 ]; then return 0; else return 1; fi
}
# ==============================================================================
# CORE & INJECTION FUNCTIONS
# ==============================================================================
check_and_start() {
    if ! command -v op &>/dev/null; then
        log_error "1Password CLI (op) not found. Please install it first."
    fi

    if ! op whoami &>/dev/null; then
        log_info "Session inactive. Attempting to sign in..."
        if ! op signin; then
            log_error "Failed to sign in to 1Password."
        fi
    fi
}
inject_ssh_hosts() {
    local target_path="$HOME/.ssh/config.local"
    if [ -f "$target_path" ]; then
        log_warning "$target_path already exists. Backing up to ${target_path}.bak"
        mv "$target_path" "${target_path}.bak"
    fi

    if op item get "$SSH_HOSTS_ITEM_NAME" --fields notesPlain 2>/dev/null | tr -d '"' > "$target_path"; then
        if [ -s "$target_path" ]; then
            chmod 600 "$target_path"
        else
            log_error "File is empty. Check if item '$SSH_HOSTS_ITEM_NAME' has content in notes."
        fi
    else
        log_error "Failed to retrieve '$SSH_HOSTS_ITEM_NAME'."
    fi
}
# ==============================================================================
# MAIN EXECUTION FLOW
# ==============================================================================
main() {
    check_and_start

    # Vérifie et crée le dossier .ssh si nécessaire
    if [ ! -d "$HOME/.ssh" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    # --- VARIABLES DE STOCKAGE ---
    local -a ALL_IDS
    local -a ALL_VAULTS
    local -a ALL_TITLES

    # 1. SCAN DES CLÉS SSH
    while IFS=: read -r item_id vault_id title; do
        ALL_IDS+=("$item_id")
        ALL_VAULTS+=("$vault_id")
        ALL_TITLES+=("$title")
    done < <(op item list --categories "SSH Key" --format json | awk -F '"' '
        /"id":/ {
            if (item_id == "") item_id=$4
            else {
                print item_id ":" $4 ":" title
                item_id=""
                title=""
            }
        }
        /"title":/ { title=$4 }
    ')

    if [ ${#ALL_IDS[@]} -eq 0 ]; then
        log_error "No SSH Key found."
    fi

    # 2. SÉLECTION UTILISATEUR
    local chosen_idx
    chosen_idx=$(ask_visual_choice "Select Git signing key" "${ALL_TITLES[@]}")
    local FINAL_ITEM_ID="${ALL_IDS[$chosen_idx]}"
    local FINAL_VAULT_ID="${ALL_VAULTS[$chosen_idx]}"
    local FINAL_TITLE="${ALL_TITLES[$chosen_idx]}"

    # 3. SSH HOSTS CONFIG (Optionnel)
    local DO_SSH_HOSTS=false
    if op item get "$SSH_HOSTS_ITEM_NAME" &>/dev/null; then
        if ask_visual_bool "Install custom SSH Hosts?" 0; then
            DO_SSH_HOSTS=true
        fi
    fi

    # --- A. GIT CONFIG ---
    local GIT_CONFIG_PATH="$HOME/.gitconfig.local"
    local PUB_KEY
    PUB_KEY=$(op read "op://${FINAL_VAULT_ID}/${FINAL_ITEM_ID}/public key" 2>/dev/null)
    if [ -z "$PUB_KEY" ]; then
        log_error "Could not read public key from 1Password."
    fi

    # Vérifie si le fichier existe déjà
    if [ -f "$GIT_CONFIG_PATH" ]; then
        log_warning "$GIT_CONFIG_PATH already exists. Backing up to ${GIT_CONFIG_PATH}.bak"
        mv "$GIT_CONFIG_PATH" "${GIT_CONFIG_PATH}.bak"
    fi

    cat <<EOF > "$GIT_CONFIG_PATH"
[user]
  signingkey = $PUB_KEY
EOF

    # --- B. SSH HOSTS ---
    if [ "$DO_SSH_HOSTS" = true ]; then
        inject_ssh_hosts
    fi

    echo
    log_success "All done."
}
main
