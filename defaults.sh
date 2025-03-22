#!/bin/bash

set -euo pipefail

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

configure_system_defaults() {
    d_header "CONFIGURING SYSTEM DEFAULTS"
    defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool "true"
    defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"
    defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "false"
    defaults write com.apple.dock "autohide" -bool "true"
    defaults write com.apple.dock "expose-group-apps" -bool "true"
    defaults write com.apple.dock "minimize-to-application" -bool "true"
    defaults write com.apple.dock "mru-spaces" -bool "false"
    defaults write com.apple.dock "show-recents" -bool "false"
    defaults write com.apple.dock "showLaunchpadGestureEnabled" -bool "false"
    defaults write com.apple.dock "tilesize" -int "32"
    defaults write com.apple.finder "FinderSpawnTab" -bool "false"
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
    defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "true"
    defaults write com.apple.finder "FXPreferredViewStyle" -string "icnv"
    defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowPathbar" -bool "true"
    defaults write com.apple.finder "ShowPreviewPane" -bool "false"
    defaults write com.apple.finder "ShowRecentTags" -bool "false"
    defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"
    # defaults write com.apple.HIToolbox "AppleFnUsageType" -int "2"
    defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true"
    defaults write com.apple.TextEdit "RichText" -bool "false"
    defaults write com.apple.TextEdit "SmartQuotes" -bool "false"
    defaults write com.apple.universalaccess "closeViewScrollWheelModifiersInt" -int "262144"
    defaults write com.apple.universalaccess "closeViewScrollWheelToggle" -bool "true"
    defaults write com.apple.WindowManager "EnableStandardClickToShowDesktop" -bool "false"
    defaults write com.apple.WindowManager "EnableTiledWindowMargins" -bool "false"
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "2"
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
    # defaults write NSGlobalDomain "NSQuitAlwaysKeepsWindow" -bool "false"
    defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2"
    defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool "false"
}

configure_system_defaults && d_success "Defaults configured successfully!" || d_error "Configuration failed."