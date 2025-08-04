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

configure_system_defaults() {
    log_header "DEFAULTS CONFIGURATION"

    # --------------------------------------------------
    # --- GENERAL SETTINGS (NSGlobalDomain)
    # --------------------------------------------------
    # Show all file extensions
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

    # Disable "natural" scrolling (content follows finger direction)
    defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool "false"

    # Enable "Full Keyboard Access" to navigate windows with Tab
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "2"

    # Default size for window sidebars (Normal)
    defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2"

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Commented line: Force window closure when quitting an app, instead of restoring them
    # defaults write NSGlobalDomain "NSQuitAlwaysKeepsWindow" -bool "false"

    # --------------------------------------------------
    # --- TRACKPAD
    # --------------------------------------------------
    # Enable "Tap to click"
    defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool "true"

    # Enable drag lock
    defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"

    # Disable three-finger drag (potential conflict with Mission Control)
    defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "false"

    # --------------------------------------------------
    # --- DOCK
    # --------------------------------------------------
    # Automatically hide the Dock
    defaults write com.apple.dock "autohide" -bool "true"

    # Set Dock icon size to 32 pixels
    defaults write com.apple.dock "tilesize" -int "32"

    # Minimize windows into application icon
    defaults write com.apple.dock "minimize-to-application" -bool "true"

    # Don't show recent applications in Dock
    defaults write com.apple.dock "show-recents" -bool "false"

    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock "mru-spaces" -bool "false"

    # Group windows by application in Mission Control
    defaults write com.apple.dock "expose-group-apps" -bool "true"

    # Disable "pinch with thumb and three fingers" gesture for Launchpad
    defaults write com.apple.dock "showLaunchpadGestureEnabled" -bool "false"

    # --------------------------------------------------
    # --- FINDER
    # --------------------------------------------------
    # Default to icon view (icnv: Icon, Nlsv: List, clmv: Column, Flwv: Cover Flow)
    defaults write com.apple.finder "FXPreferredViewStyle" -string "icnv"

    # Show path bar at the bottom of windows
    defaults write com.apple.finder "ShowPathbar" -bool "true"

    # Search in current folder by default (SCcf: Search Current Folder)
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"

    # Show warning when changing a file extension
    defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "true"

    # Don't show recent tags in sidebar
    defaults write com.apple.finder "ShowRecentTags" -bool "false"

    # Open new folders in new window rather than tab
    defaults write com.apple.finder "FinderSpawnTab" -bool "false"

    # Hide preview pane by default
    defaults write com.apple.finder "ShowPreviewPane" -bool "false"

    # Hide hard drives, external drives, and servers on desktop for cleaner look
    defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"

    # --------------------------------------------------
    # --- WINDOW MANAGEMENT (WindowManager)
    # --------------------------------------------------
    # Disable "Click wallpaper to reveal desktop" (Stage Manager)
    defaults write com.apple.WindowManager "EnableStandardClickToShowDesktop" -bool "false"

    # Disable margins for tiled windows
    defaults write com.apple.WindowManager "EnableTiledWindowMargins" -bool "false"

    # --------------------------------------------------
    # --- ACCESSIBILITY
    # --------------------------------------------------
    # Configure zoom with mouse wheel + Control key
    defaults write com.apple.universalaccess "closeViewScrollWheelToggle" -bool "true"

    # 262144 corresponds to Control key (^)
    defaults write com.apple.universalaccess "closeViewScrollWheelModifiersInt" -int "262144"

    # --------------------------------------------------
    # --- SPECIFIC APPLICATIONS
    # --------------------------------------------------
    # Safari: Show full URL in smart search field
    defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true"

    # TextEdit: Use plain text format (.txt) by default instead of RTF
    defaults write com.apple.TextEdit "RichText" -bool "false"

    # TextEdit: Disable smart quotes
    defaults write com.apple.TextEdit "SmartQuotes" -bool "false"

    # TextEdit: Show open panel instead of untitled document on launch
    defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false 

    # Commented line: Would force F1, F2, etc. keys to function as standard function keys
    defaults write com.apple.HIToolbox "AppleFnUsageType" -int "2"

    log_info "Applying changes (rebooting services)…"

    # Loop to restart applications and apply settings
    for app in "Dock" "Finder" "SystemUIServer"; do
        killall "${app}" >/dev/null 2>&1 || true
    done
}

main() {
    prevent_sleep
    configure_system_defaults
}

main && log_success "Defaults configured successfully!" || log_error "Defaults configuration failed."