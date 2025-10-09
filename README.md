# macOS Development Setup  

Installation and configuration scripts for my macOS environment.  

See my related dotfiles configuration: [macOS Dotfiles](https://github.com/lionelhenne/dotfiles).  

## Features  

### `setup.sh` – Base Configuration  
✅ Installs Xcode Command Line Tools  
✅ Sets up Homebrew and installs a selection of packages  
✅ Configures SSH for 1Password, GitHub, and Hostinger  
✅ Starts Atuin, MySQL, and PostgreSQL services  
✅ Secures MySQL installation automatically  
✅ Installs Node.js (LTS) via fnm  
✅ Clones and applies [my dotfiles](https://github.com/lionelhenne/dotfiles) using GNU Stow  
✅ Configures Atuin  
✅ Creates the `Sites` and `Developer` directories  
✅ Installs Homebrew casks (applications and fonts)  
✅ Creates a file with remaining apps to install manually 

#### Homebrew Packages Installed  
The following packages are installed via [Homebrew](https://brew.sh/):  

**Development Tools**  
- [Composer](https://getcomposer.org/) – PHP dependency manager  
- [fnm](https://github.com/Schniz/fnm) – Fast Node.js version manager  
- [MySQL](https://www.mysql.com/) – Open source relational database  
- [PostgreSQL](https://www.postgresql.org/) – Advanced open source database  

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
- [1Password](https://1password.com/) & [1Password CLI](https://1password.com/downloads/command-line/).   

**Productivity & Communication**  
- [Discord](https://discord.com/)  
- [LocalSend](https://localsend.org/)  

**Browsers**  
- [Google Chrome](https://www.google.com/chrome/)  
- [Firefox](https://www.mozilla.org/firefox/)  
- [Microsoft Edge](https://www.microsoft.com/edge)  
- [Vivaldi](https://vivaldi.com/)  

**Affinity**  
- [Affinity Designer](https://affinity.serif.com/designer/)  
- [Affinity Photo](https://affinity.serif.com/photo/)  
- [Affinity Publisher](https://affinity.serif.com/publisher/)  

**Development Tools**  
- [Ghostty](https://ghostty.org/)  
- [Postman](https://www.postman.com/)  
- [Transmit](https://panic.com/transmit/)  
- [Visual Studio Code](https://code.visualstudio.com/)  

**System Utilities**  
- [AppCleaner](https://freemacsoft.net/appcleaner/)  
- [BetterDisplay](https://github.com/waydabber/BetterDisplay)  
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

**Utilities**  
- [Transmission](https://transmissionbt.com/)  

#### Typography Collection  
Over 50 professional fonts including:  
- **Monospace**: Cascadia Code, JetBrains Mono, JetBrains Mono Nerd Font, Monaspace, Roboto Mono  
- **Sans Serif**: Alegreya Sans, Atkinson Hyperlegible Next, Inter, Inter Tight, Lato, Libre Franklin, Montserrat, Nunito, Nunito Sans, Open Sans, Outfit, Raleway, Roboto, Roboto Condensed, Roboto Flex, Roboto Slab  
- **Serif**: Alegreya, Alegreya Sans SC, Alegreya SC, Biorhyme, Biorhyme Expanded, Bree Serif, Crimson Pro, Crimson Text, Libre Baskerville, Libre Bodoni, Libre Caslon Display, Libre Caslon Text, Lora, Merriweather, Merriweather Sans, Playfair, Playfair Display, Playfair Display SC, Vollkorn, Vollkorn SC  
- **Display**: Alfa Slab One, Gilbert, Licorice, Redacted Script, Unica One, Yeseva One  
- **Emoji & Symbols**: Noto Color Emoji, Noto Emoji, Noto Sans, Noto Sans Display, Noto Sans JP, Noto Sans Mono, Noto Sans Symbols, Noto Serif, Noto Serif Display, Noto Serif Hentaigana, Noto Serif JP  

### `defaults.sh` – System Preferences Configuration  
✅ Configures macOS system defaults and preferences  
✅ Sets up general system settings (file extensions, natural scrolling, keyboard access, save/print panels)  
✅ Configures Finder preferences (path bar, search scope, desktop items visibility)  
✅ Sets up Dock settings (auto-hide, icon size, minimize behavior, recent apps, Spaces arrangement)  
✅ Enables trackpad tap-to-click and drag lock  
✅ Configures window management preferences (Stage Manager, tiled windows margins)  
✅ Sets up accessibility features (zoom with scroll wheel + Control key)  
✅ Customizes Safari (full URL display) and TextEdit (plain text mode, smart quotes)  
✅ Applies changes by restarting affected system services  

### `valet.sh` – Laravel Valet Configuration  
✅ Installs and configures [Laravel Valet](https://laravel.com/docs/12.x/valet)  
✅ Sets up Valet in the `~/Sites` directory  
✅ Installs [PHP Monitor](https://phpmon.app/) for managing PHP versions  
✅ Creates a `phpinfo` directory with SSL certificate  
✅ Links and secures phpinfo.test domain  
✅ Opens PHP Monitor and phpinfo.test in browser  

## Installation  

### Main script (`setup.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/setup.sh | /bin/bash
```

### System defaults configuration (`defaults.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/defaults.sh | /bin/bash
```

### Laravel Valet installation script (`valet.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/valet.sh | /bin/bash
```

## Manual Installation Required  

After running the main setup script, a file `remaining_apps.txt` will be created on the Desktop with links to applications that need to be installed manually.  