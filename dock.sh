#!/bin/bash
set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

log_error() { printf "${RED}[ERROR] %s${RESET}\n" "$1" >&2; exit 1; }
log_header() { printf "\n${BOLD}${GREEN}=== %s ===%s\n" "$1" "${RESET}"; }
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

find_app_by_bundle_id() {
    local bundle_id="$1"
    mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" | head -1
}

add_app_to_dock() {
    local app_path="$1"
    local app_name=$(basename "$app_path" .app)
    
    if [ -d "$app_path" ]; then
        log_info "Adding $app_name to the Dock"
        defaults write com.apple.dock persistent-apps -array-add "<dict>
            <key>tile-data</key>
            <dict>
                <key>file-data</key>
                <dict>
                    <key>_CFURLString</key>
                    <string>$app_path</string>
                    <key>_CFURLStringType</key>
                    <integer>0</integer>
                </dict>
            </dict>
        </dict>"
    else
        log_warning "Application $app_name not found at: $app_path"
    fi
}

add_folder_to_dock() {
    local folder_path="$1"
    local folder_name=$(basename "$folder_path")
    
    if [ -d "$folder_path" ]; then
        log_info "Adding folder $folder_name to the Dock."
        defaults write com.apple.dock persistent-others -array-add "<dict>
            <key>tile-data</key>
            <dict>
                <key>arrangement</key>
                <integer>1</integer>
                <key>displayas</key>
                <integer>1</integer>
                <key>file-data</key>
                <dict>
                    <key>_CFURLString</key>
                    <string>file://$folder_path</string>
                    <key>_CFURLStringType</key>
                    <integer>15</integer>
                </dict>
                <key>file-type</key>
                <integer>2</integer>
                <key>showas</key>
                <integer>2</integer>
            </dict>
            <key>tile-type</key>
            <string>directory-tile</string>
        </dict>"
    else
        log_warning "Folder $folder_name not found at: $folder_path"
    fi
}

add_small_spacer() {
    defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
}

configure_dock() {
    log_header "SETTING UP DOCK."

    defaults delete com.apple.dock persistent-apps
    defaults delete com.apple.dock persistent-others
    
    add_app_to_dock "/Applications/Ghostty.app"

    add_small_spacer

    add_app_to_dock "/Applications/Google Chrome.app"
    add_app_to_dock "/Applications/Firefox.app"
    add_app_to_dock "/Applications/Mimestream.app"
    add_app_to_dock "/Applications/Discord.app"

    add_small_spacer

    add_app_to_dock "/System/Applications/TextEdit.app"
    add_app_to_dock "/Applications/Visual Studio Code.app"
    add_app_to_dock "/Applications/Xcode.app/Contents/Applications/FileMerge.app"
    add_app_to_dock "/Applications/Postman.app"
    add_app_to_dock "/Applications/Setapp/TablePlus.app"
	add_app_to_dock "/Applications/Transmit.app"
    if photoshop_path=$(find_app_by_bundle_id "com.adobe.Photoshop"); then
        add_app_to_dock "$photoshop_path"
    else
        log_warning "Adobe Photoshop not found"
    fi

    add_small_spacer

    add_app_to_dock "/Applications/Spotify.app"
    add_app_to_dock "/System/Applications/Music.app"
    add_app_to_dock "/Applications/DaftCloud.app"
    add_app_to_dock "/Applications/GarageBand.app"
    add_app_to_dock "/Applications/Setapp/Meta.app"
    add_app_to_dock "/Applications/djay Pro.app"
    add_app_to_dock "/Applications/Serato DJ Pro.app"
    
    add_folder_to_dock "/Applications"
    add_folder_to_dock "/Applications/Setapp"
    add_folder_to_dock "$HOME/Pictures"
    add_folder_to_dock "$HOME/Music"
    add_folder_to_dock "$HOME/Developer"
    add_folder_to_dock "$HOME/Sites"
    add_folder_to_dock "$HOME/Downloads"
    
    log_info "Restarting Dock to apply changes."
    killall Dock
}

main() {
    prevent_sleep && \
    configure_dock
}

main && log_success "Dock configured successfully!" || log_error "Dock configuration failed."