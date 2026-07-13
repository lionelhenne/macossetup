#!/bin/bash
# defaults.sh
# macOS System Preferences (defaults write)

run() {
    log_header "macOS Defaults"

    log_info "Applying defaults..."

    # Add/remove one `defaults write` line per setting.

    # Expand the save panel by default instead of the collapsed one-line version
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    # Same as above, for the newer save panel used by some apps
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    # Expand the print panel by default instead of the collapsed one-line version
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    # Same as above, for the newer print panel used by some apps
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    # Open a blank untitled document on launch instead of an "Open" panel
    defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Full keyboard access: Tab moves focus between all controls, not just text fields and lists
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
    # Disable the two-finger swipe gesture for back/forward page navigation
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
    # Disable natural (reversed) scrolling direction
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    # Fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    # Short delay before key repeat kicks in
    defaults write NSGlobalDomain InitialKeyRepeat -int 25
    # Prompt to keep changes when closing a document instead of autosaving silently
    defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true
    # Use the "Funk" alert sound instead of the default
    defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Funk.aiff"
    # App Shortcuts (all applications): rebind "Save As..." to Shift+Cmd+S
    # (French and English menu item labels both need an entry)
    defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add "Enregistrer sous..." '@$s'
    defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add "Save As…" '@$s'

    # Accessibility > Zoom. com.apple.universalaccess is TCC-protected since macOS
    # Monterey: writes fail with "Could not write domain" until the terminal app
    # running this script is granted Full Disk Access (System Settings > Privacy
    # & Security > Full Disk Access). Non-fatal so the rest of the module still runs.
    # Use scroll gesture with modifier keys to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true || log_warn "Couldn't write com.apple.universalaccess — grant Full Disk Access to this terminal and re-run"
    # Zoom with Ctrl held while scrolling
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144 || log_warn "Couldn't write com.apple.universalaccess — grant Full Disk Access to this terminal and re-run"
    # Advanced...: after a zoom, image moves continuously with the pointer
    defaults write com.apple.universalaccess closeViewPanningMode -int 0 || log_warn "Couldn't write com.apple.universalaccess — grant Full Disk Access to this terminal and re-run"

    # Trackpad (built-in): enable tap to click
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    # Trackpad (built-in): enable tap to drag, with Drag Lock
    defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
    defaults write com.apple.AppleMultitouchTrackpad DragLock -bool true
    # Trackpad (built-in): three-finger tap triggers Look Up & data detectors
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
    # Trackpad (built-in): three-finger horizontal/vertical swipe gesture mode.
    # NOT FULLY CONFIRMED: sources disagree on what value 1 does here versus the
    # default 2 (page/full-screen-app swipe vs. Mission Control). Given Dragging
    # and DragLock are also on, this is believed to repurpose the three-finger
    # swipe for window dragging, but double-check in System Settings > Trackpad
    # after applying.
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 1

    # Trackpad (Bluetooth): same set of tweaks as the built-in trackpad above
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
    # See the "NOT FULLY CONFIRMED" note above (built-in trackpad section)
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 1

    # Dock: automatically hide and show
    defaults write com.apple.dock autohide -bool true
    # Dock: icon size in pixels
    defaults write com.apple.dock tilesize -int 36
    # Dock: group windows by application in Mission Control / App Exposé
    defaults write com.apple.dock expose-group-apps -bool true
    # Dock: minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    # Dock: don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false
    # Dock: don't show recently used applications
    defaults write com.apple.dock show-recents -bool false
    # Dock: disable the bottom-right hot corner
    defaults write com.apple.dock wvous-br-corner -int 1
    defaults write com.apple.dock wvous-br-modifier -int 0

    # Finder: default search scope is the current folder, not "This Mac"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # Finder: new windows open to the Home folder
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    # Finder: show the path bar
    defaults write com.apple.finder ShowPathbar -bool true
    # Finder: don't show external hard drives on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    # Finder: don't show removable media on the desktop
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
    # Finder: hide recent tags in the sidebar
    defaults write com.apple.finder ShowRecentTags -bool false
    # Finder: skip the confirmation warning when emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    # Desktop icon view: sort by grid, 64px icons, label below with info and preview
    defaults write com.apple.finder DesktopViewSettings -dict-add IconViewSettings '<dict><key>arrangeBy</key><string>grid</string><key>gridSpacing</key><integer>54</integer><key>iconSize</key><integer>64</integer><key>labelOnBottom</key><true/><key>showIconPreview</key><true/><key>showItemInfo</key><true/><key>textSize</key><integer>12</integer></dict>'
    # Show the ~/Library folder (Finder > Home folder view options > "Show Library Folder")
    chflags nohidden ~/Library

    # Desktop & Dock: no margins around tiled windows
    defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
    # Desktop & Dock: clicking the desktop wallpaper doesn't bring it to the front
    defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
    # Desktop & Dock: hide items on the desktop
    defaults write com.apple.WindowManager HideDesktop -bool true
    # Desktop & Dock: window grouping behavior for a single app's windows.
    # NOT FULLY CONFIRMED: exact user-facing effect of this key isn't documented
    # anywhere I could verify; observed as `1` on the source Mac. Verify after
    # applying.
    defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1

    # Menu bar clock: never show the date
    defaults write com.apple.menuextra.clock ShowDate -int 2
    # Menu bar clock: hide the day of the week
    defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false

    # Disable the built-in screenshot shortcuts so a third-party tool (e.g. CleanShot X)
    # can claim them instead. Cmd+Shift+3: save screen to a file
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>51</integer><integer>20</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>'
    # Cmd+Ctrl+Shift+3: copy screen to the clipboard
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 29 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>51</integer><integer>20</integer><integer>1441792</integer></array><key>type</key><string>standard</string></dict></dict>'
    # Cmd+Shift+4: save selected area to a file
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>52</integer><integer>21</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>'
    # Cmd+Ctrl+Shift+4: copy selected area to the clipboard
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>52</integer><integer>21</integer><integer>1441792</integer></array><key>type</key><string>standard</string></dict></dict>'

    log_success "Defaults applied"
    log_warn "Some changes require a restart (Finder, Dock, or logout) to take effect"
}
