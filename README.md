# macOS Development Setup

Installation and configuration scripts for my macOS environment.

See my related dotfiles configuration: [macOS Dotfiles](https://github.com/lionelhenne/dotfiles).

## Features

### `setup.sh` – Interactive Setup Assistant

An interactive TUI-based installer that lets you choose which components to install:

**Module 1: Core System** (Default: Yes)
- ✅ Installs Xcode Command Line Tools
- ✅ Sets up Homebrew and installs development packages
- ✅ Configures SSH for 1Password, GitHub, Hostinger, and IONOS
- ✅ Installs Node.js (LTS) via fnm
- ✅ Clones and applies [my dotfiles](https://github.com/lionelhenne/dotfiles) using GNU Stow
- ✅ Starts Atuin service
- ✅ Creates `Sites` and `Developer` directories

**Module 2: GUI Applications** (Default: Yes)
- ✅ Installs Homebrew casks (applications and fonts)

**Module 3: Web Development (Valet)** (Default: Yes)
- ✅ Adds Homebrew taps for PHP (shivammathur)
- ✅ Installs and configures [Laravel Valet](https://laravel.com/docs/12.x/valet)
- ✅ Installs [Laravel Installer](https://laravel.com/docs/12.x/installation)
- ✅ Sets up Valet in the `~/Sites` directory
- ✅ Installs [PHP Monitor](https://phpmon.app/) with integrity verification
- ✅ Creates a `phpinfo` directory with SSL certificate
- ✅ Opens PHP Monitor and phpinfo.test in browser

**Module 4: MySQL** (Default: Yes)
- ✅ Installs MySQL
- ✅ Starts MySQL service
- ✅ Secures MySQL installation automatically (root password: root)

**Module 5: PostgreSQL** (Default: No)
- ✅ Installs PostgreSQL 18
- ✅ Starts PostgreSQL service

**Module 6: macOS System Defaults** (Default: No)
- ✅ Configures general system settings (file extensions, natural scrolling, keyboard access, save/print panels)
- ✅ Sets up Finder preferences (path bar, search scope, desktop items visibility)
- ✅ Configures Dock settings (auto-hide, icon size, minimize behavior, recent apps)
- ✅ Enables trackpad tap-to-click and drag lock
- ✅ Applies changes by restarting affected system services

#### Homebrew Packages Installed

The following packages are installed via [Homebrew](https://brew.sh/):

**Development Tools**
- [Composer](https://getcomposer.org/) – PHP dependency manager
- [fnm](https://github.com/Schniz/fnm) – Fast Node.js version manager

**Shell & Terminal**
- [Starship](https://starship.rs/) – Cross-shell prompt
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) – Fish-like autosuggestions for zsh
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) – Syntax highlighting for zsh

**System Utilities**
- [Atuin](https://atuin.sh/) – Magical shell history
- [bat](https://github.com/sharkdp/bat) – A cat clone with wings
- [duf](https://github.com/muesli/duf) – Disk Usage/Free Utility
- [eza](https://github.com/eza-community/eza) – A modern replacement for 'ls'
- [fd](https://github.com/sharkdp/fd) – A simple, fast and user-friendly alternative to 'find'
- [GNU Tar](https://www.gnu.org/software/tar/) – Archiving utility
- [mkcert](https://github.com/FiloSottile/mkcert) – A simple tool for making locally-trusted development certificates
- [nss](https://firefox-source-docs.mozilla.org/security/nss/index.html) – Network Security Services
- [ripgrep](https://github.com/BurntSushi/ripgrep) – Line-oriented search tool that recursively searches directories
- [rsync](https://rsync.samba.org/) – File synchronization tool
- [stow](https://www.gnu.org/software/stow/) – Symlink farm manager
- [tlrc](https://tldr.sh/tlrc/) – Official tldr client written in Rust
- [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) – Display directories as trees
- [wget](https://www.gnu.org/software/wget/) – Internet file retriever

**Text Editor**
- [micro](https://micro-editor.github.io/) – A modern and intuitive terminal-based text editor

#### Applications Installed via Homebrew Casks

**1Password**
- [1Password](https://1password.com/) & [1Password CLI](https://1password.com/downloads/command-line/)

**Productivity & Communication**
- [Discord](https://discord.com/)
- [LocalSend](https://localsend.org/)

**Browsers**
- [Google Chrome](https://www.google.com/chrome/)
- [Firefox](https://www.mozilla.org/firefox/)
- [Microsoft Edge](https://www.microsoft.com/edge)
- [Vivaldi](https://vivaldi.com/)

**Creative**
- [Adobe Creative Cloud](https://www.adobe.com/creativecloud.html)
- [Affinity](https://affinity.serif.com/)

**Development Tools**
- [Ghostty](https://ghostty.org/)
- [Postman](https://www.postman.com/)
- [Transmit](https://panic.com/transmit/)
- [Visual Studio Code](https://code.visualstudio.com/)

**System Utilities**
- [AppCleaner](https://freemacsoft.net/appcleaner/)
- [BetterDisplay](https://github.com/waydabber/BetterDisplay)
- [CyberGhost VPN](https://www.cyberghostvpn.com/)
- [DaisyDisk](https://daisydiskapp.com/)
- [Setapp](https://setapp.com/)
- [Suspicious Package](https://www.mothersruin.com/software/SuspiciousPackage/)
- [VirtualBuddy](https://virtualbuddy.app/)

**Media**
- [HandBrake](https://handbrake.fr/)
- [IINA](https://iina.io/)
- [Spotify](https://www.spotify.com/)

**Entertainment**
- [OpenEmu](https://openemu.org/)
- [Steam](https://store.steampowered.com/)

**Utilities**
- [Transmission](https://transmissionbt.com/)

#### Typography Collection

Over 50 professional fonts including:
- **Monospace**: Cascadia Code, JetBrains Mono, JetBrains Mono Nerd Font, Monaspace, Roboto Mono
- **Sans Serif**: Alegreya Sans, Atkinson Hyperlegible Next, Inter, Inter Tight, Lato, Libre Franklin, Montserrat, Montserrat Alternates, Montserrat Underline, Nunito, Nunito Sans, Open Sans, Outfit, Raleway, Raleway Dots, Roboto, Roboto Condensed, Roboto Flex, Roboto Slab
- **Serif**: Alegreya, Alegreya Sans SC, Alegreya SC, Biorhyme, Biorhyme Expanded, Bree Serif, Crimson Pro, Crimson Text, Libre Baskerville, Libre Bodoni, Libre Caslon Display, Libre Caslon Text, Lora, Merriweather, Merriweather Sans, Playfair, Playfair Display, Playfair Display SC, Vollkorn, Vollkorn SC
- **Display**: Alfa Slab One, Gilbert, Licorice, Redacted Script, Unica One, Yeseva One
- **Emoji & Symbols**: Noto Color Emoji, Noto Emoji, Noto Sans, Noto Sans Display, Noto Sans JP, Noto Sans Mono, Noto Sans Symbols, Noto Serif, Noto Serif Display, Noto Serif Hentaigana, Noto Serif JP

## Installation

### Quick Install (Recommended)

Clone and run the interactive installer:

```bash
git clone https://github.com/lionelhenne/macossetup.git
cd macossetup
chmod +x setup.sh
./setup.sh
```

### Remote Install (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/setup.sh | /bin/bash
```

## Features

- **Interactive TUI**: Navigate with arrow keys and select modules with Enter
- **Idempotent**: Safe to run multiple times, won't reinstall existing packages
- **Smart detection**: Checks for existing installations before proceeding
- **Error handling**: Validates critical installations (Homebrew, MySQL security, PHP Monitor integrity)
- **Visual feedback**: Color-coded logs and installation history
- **Sleep prevention**: Keeps your Mac awake during installation