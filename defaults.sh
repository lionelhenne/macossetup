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
    # --- PARAMÈTRES GÉNÉRAUX (NSGlobalDomain)
    # --------------------------------------------------
    # Affiche toutes les extensions de fichiers
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

    # Désactive le défilement "naturel" (le contenu suit le doigt)
    defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool "false"

    # Active la "Full Keyboard Access" pour naviguer dans les fenêtres avec Tab
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "2"

    # Taille par défaut des barres latérales des fenêtres (Normal)
    defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2"

    # Ligne commentée : force la fermeture des fenêtres d'une app quand on la quitte, au lieu de les restaurer.
    # defaults write NSGlobalDomain "NSQuitAlwaysKeepsWindow" -bool "false"

    # --------------------------------------------------
    # --- TRACKPAD
    # --------------------------------------------------
    # Active le "Tap to click"
    defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool "true"

    # Active le verrouillage du glissement
    defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"

    # Désactive le glissement à trois doigts (conflit potentiel avec Mission Control)
    defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "false"

    # --------------------------------------------------
    # --- DOCK
    # --------------------------------------------------
    # Masque automatiquement le Dock
    defaults write com.apple.dock "autohide" -bool "true"

    # Définit la taille des icônes du Dock à 32 pixels
    defaults write com.apple.dock "tilesize" -int "32"

    # Réduit les fenêtres dans l'icône de l'application
    defaults write com.apple.dock "minimize-to-application" -bool "true"

    # Ne pas afficher les applications récentes dans le Dock
    defaults write com.apple.dock "show-recents" -bool "false"

    # Ne pas réorganiser les Spaces en fonction de l'utilisation récente
    defaults write com.apple.dock "mru-spaces" -bool "false"

    # Regroupe les fenêtres par application dans Mission Control
    defaults write com.apple.dock "expose-group-apps" -bool "true"

    # Désactive le geste "pincer avec le pouce et 3 doigts" pour le Launchpad
    defaults write com.apple.dock "showLaunchpadGestureEnabled" -bool "false"

    # --------------------------------------------------
    # --- FINDER
    # --------------------------------------------------
    # Vue par icônes par défaut (icnv: Icon, Nlsv: List, clmv: Column, Flwv: Cover Flow)
    defaults write com.apple.finder "FXPreferredViewStyle" -string "icnv"

    # Affiche la barre de chemin d'accès en bas des fenêtres
    defaults write com.apple.finder "ShowPathbar" -bool "true"

    # Recherche dans le dossier actuel par défaut (SCcf: Search Current Folder)
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"

    # Affiche un avertissement lors du changement d'extension d'un fichier
    defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "true"

    # Ne pas afficher les tags récents dans la barre latérale
    defaults write com.apple.finder "ShowRecentTags" -bool "false"

    # Ouvre les nouveaux dossiers dans une nouvelle fenêtre plutôt qu'un onglet
    defaults write com.apple.finder "FinderSpawnTab" -bool "false"

    # Masque le panneau de prévisualisation par défaut
    defaults write com.apple.finder "ShowPreviewPane" -bool "false"

    # Masque les disques durs, externes et serveurs sur le bureau pour un look plus propre
    defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "false"
    defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"

    # --------------------------------------------------
    # --- GESTION DES FENÊTRES (WindowManager)
    # --------------------------------------------------
    # Désactive "Cliquer sur le fond d'écran pour afficher le bureau" (Stage Manager)
    defaults write com.apple.WindowManager "EnableStandardClickToShowDesktop" -bool "false"

    # Désactive les marges pour les fenêtres en mode "Tiled"
    defaults write com.apple.WindowManager "EnableTiledWindowMargins" -bool "false"

    # --------------------------------------------------
    # --- ACCESSIBILITÉ
    # --------------------------------------------------
    # Configure le zoom avec la molette de la souris + la touche Ctrl
    defaults write com.apple.universalaccess "closeViewScrollWheelToggle" -bool "true"

    # 262144 correspond à la touche Ctrl (^)
    defaults write com.apple.universalaccess "closeViewScrollWheelModifiersInt" -int "262144"

    # --------------------------------------------------
    # --- APPLICATIONS SPÉCIFIQUES
    # --------------------------------------------------
    # Safari: Affiche l'URL complète dans la barre de recherche
    defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true"

    # TextEdit: Utilise le format texte brut (.txt) par défaut au lieu du RTF et désactive les guillemets intelligents
    defaults write com.apple.TextEdit "RichText" -bool "false"
    defaults write com.apple.TextEdit "SmartQuotes" -bool "false"

    # Ligne commentée : Forcerait l'utilisation des touches F1, F2, etc. comme des touches de fonction standard.
    # defaults write com.apple.HIToolbox "AppleFnUsageType" -int "2"

    log_info "Applying changes (rebooting services)…"

    # Boucle pour redémarrer les applications et appliquer les réglages
    for app in "Dock" "Finder" "SystemUIServer"; do
        killall "${app}" >/dev/null 2>&1 || true
    done
}

main() {
    prevent_sleep && \
    configure_system_defaults
}

main && log_success "Defaults configured successfully!" || log_error "Defaults configuration failed."
