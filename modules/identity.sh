#!/bin/bash

run() {
    # Check 1Password CLI
    if ! command -v op >/dev/null 2>&1; then
        log_error "1Password CLI not found (install via: brew install 1password-cli)"
    fi

    # Check 1Password Desktop integration
    log_info "Checking 1Password Desktop integration..."

    if ! op account list &>/dev/null; then
        echo
        log_warn "1Password CLI integration not active"
        echo
        echo "Please configure 1Password Desktop app:"
        echo "  1. Open 1Password app"
        echo "  2. Sign in to your account"
        echo "  3. Go to Settings > Developer"
        echo "  4. Enable 'Connect with 1Password CLI'"
        echo "  5. Enable 'SSH Agent'"
        echo

        while true; do
            if confirm "Ready to continue?"; then
                if op account list &>/dev/null; then
                    log_success "1Password CLI connected"
                    break
                else
                    log_warn "Still not detected, check Developer settings"
                fi
            else
                log_info "Setup cancelled"
                return 0
            fi
        done
    else
        log_success "1Password CLI connected"
    fi

    # ==============================================================================
    # GIT CONFIGURATION
    # ==============================================================================

    log_header "Git Configuration"

    local gitconfig_local="$HOME/.gitconfig.local"

    if [[ -f "$gitconfig_local" ]]; then
        log_warn "Git config.local already exists"
        echo
        echo -e "${SILVER}"
        cat "$gitconfig_local"
        echo -e "${RESET}"

        if confirm "Backup and replace?" N; then
            cp "$gitconfig_local" "${gitconfig_local}.backup"
            log_success "Backed up to ${gitconfig_local}.backup"
        else
            log_info "Git configuration skipped"
            # Skip to SSH section
            log_header "SSH Configuration"
            configure_ssh
            return 0
        fi
    fi

    # Git config doesn't exist or user chose to replace
    log_info "Searching for SSH keys in 1Password..."

    local keys_json
    keys_json=$(op item list --categories "SSH Key" --format=json 2>/dev/null)

    if [[ -z "$keys_json" ]] || [[ "$keys_json" == "[]" ]]; then
        log_warn "No SSH keys found in 1Password"
        log_info "Create an SSH key in 1Password first"
        # Skip to SSH section
        log_header "SSH Configuration"
        configure_ssh
        return 0
    fi

    # Count keys
    local count
    count=$(jq 'length' <<<"$keys_json")

    if [[ -z "$count" ]] || [[ "$count" -eq 0 ]]; then
        log_warn "No SSH keys found"
        log_header "SSH Configuration"
        configure_ssh
        return 0
    fi

    log_success "Found $count SSH key(s)"

    # Display keys menu
    echo
    echo "Available SSH keys:"
    echo

    jq -r 'to_entries[] | "\(.key+1)) \(.value.title) (\(.value.vault.name // "Unknown"))"' <<<"$keys_json"

    # Select key
    echo
    while true; do
        read -p "$(echo -e "${MAGENTA}${BOLD}USER${RESET}  ${SILVER}Select key (1-$count):${RESET} ")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
            break
        fi
        echo -e "      ${YELLOW}${BOLD}Invalid choice${RESET}"
    done

    # Extract key details
    local key_id key_title key_vault
    IFS=$'\t' read -r key_id key_title key_vault < <(
        jq -r ".[$((choice-1))] | [.id, .title, .vault.name] | @tsv" <<<"$keys_json"
    )

    if [[ -z "$key_id" || -z "$key_title" || -z "$key_vault" ]]; then
        log_error "Failed to extract key details"
    fi

    log_success "Key selected: $key_title"

    # Get public key
    log_info "Reading public key..."

    local public_key=$(op read "op://$key_vault/$key_id/public key" 2>/dev/null)

    if [[ -z "$public_key" ]]; then
        log_error "Failed to read public key"
    fi

    log_success "Public key retrieved"

    # Create .gitconfig.local
    log_info "Creating .gitconfig.local..."

    cat <<EOF > "$gitconfig_local"
[user]
    signingkey = $public_key
EOF

    log_success "Git signing key configured"

    # ==============================================================================
    # SSH CONFIGURATION
    # ==============================================================================

    log_header "SSH Configuration"

    configure_ssh
}

# ==============================================================================
# SSH CONFIGURATION FUNCTION
# ==============================================================================

configure_ssh() {
    local ssh_dir="$HOME/.ssh"
    local ssh_config="$ssh_dir/config"
    local ssh_config_local="$ssh_dir/config.local"

    # Check .ssh directory
    if [[ ! -d "$ssh_dir" ]]; then
        log_warn ".ssh directory doesn't exist"
        echo
        echo "Please enable SSH Agent in 1Password:"
        echo "  Settings > Developer > Enable SSH Agent"
        echo

        if confirm "Create .ssh directory anyway?" N; then
            mkdir -p "$ssh_dir"
            chmod 700 "$ssh_dir"
            log_success ".ssh directory created"
        else
            log_info "SSH configuration skipped"
            echo
            log_success "Identity setup completed!"
            return 0
        fi
    fi

    # Check .ssh/config
    if [[ -f "$ssh_config" ]]; then
        log_warn "SSH config already exists"
        echo
        echo -e "${SILVER}"
        cat "$ssh_config"
        echo -e "${RESET}"

        if confirm "Backup and replace?" N; then
            cp "$ssh_config" "${ssh_config}.backup"
            log_success "Backed up to ${ssh_config}.backup"
        else
            log_info "SSH config skipped"
            # Continue to config.local check
            check_ssh_config_local
            return 0
        fi
    fi

    # Create .ssh/config
    log_info "Creating .ssh/config..."

    cat <<'EOF' > "$ssh_config"
Include ~/.ssh/config.local

Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

Host github.com
    HostName github.com
    User git
EOF

    chmod 600 "$ssh_config"
    log_success "SSH config created"

    # Check config.local
    check_ssh_config_local
}

check_ssh_config_local() {
    local ssh_config_local="$HOME/.ssh/config.local"

    if [[ -f "$ssh_config_local" ]]; then
        log_warn "SSH config.local already exists"
        echo
        echo -e "${SILVER}"
        cat "$ssh_config_local"
        echo -e "${RESET}"

        if confirm "Backup and replace?" N; then
            cp "$ssh_config_local" "${ssh_config_local}.backup"
            log_success "Backed up to ${ssh_config_local}.backup"
        else
            log_info "SSH config.local skipped"
            echo
            log_success "Identity setup completed!"
            return 0
        fi
    fi

    # Create .ssh/config.local from 1Password
    log_info "Fetching SSH hosts config from 1Password..."

    local ssh_hosts_content=$(op item get "SSH_HOSTS_CONFIG" --fields label=notesPlain 2>/dev/null | tr -d '"')

    if [[ -z "$ssh_hosts_content" ]]; then
        log_warn "SSH_HOSTS_CONFIG note not found in 1Password"
        log_info "Create a secure note named 'SSH_HOSTS_CONFIG' for custom hosts"

        # Create empty config.local
        touch "$ssh_config_local"
        chmod 600 "$ssh_config_local"
        log_success "Empty config.local created"
    else
        # Write content to config.local
        echo "$ssh_hosts_content" > "$ssh_config_local"
        chmod 600 "$ssh_config_local"
        log_success "SSH hosts config written to config.local"
    fi

    echo
    log_success "Identity setup completed!"
}
