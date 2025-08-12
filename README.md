# macOS Development Setup  

Installation and configuration scripts for my macOS environment.  

See my related dotfiles configuration: [macOS Dotfiles](https://github.com/lionelhenne/dotfiles).  

## Features  

### `setup.sh` – Base Configuration  
✅ Installs Xcode Command Line Tools  
✅ Sets up Homebrew and installs a selection of packages  
✅ Configures SSH for 1Password and GitHub  
✅ Starts Atuin and PostgreSQL services  
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
- [Mimestream](https://mimestream.com/)  
- [Todoist App](https://todoist.com/)  

**Browsers**  
- [Google Chrome](https://www.google.com/chrome/)  
- [Firefox](https://www.mozilla.org/firefox/)  
- [Microsoft Edge](https://www.microsoft.com/edge)  
- [Vivaldi](https://vivaldi.com/)  

**Adobe Creative Cloud**  
- [Adobe Creative Cloud](https://creativecloud.adobe.com/)  

**Affinity**  
- [Affinity Designer](https://affinity.serif.com/designer/)  
- [Affinity Photo](https://affinity.serif.com/photo/)  
- [Affinity Publisher](https://affinity.serif.com/publisher/)  

**Microsoft Office Suite**  
- [Microsoft Auto Update, Excel, PowerPoint, Word](https://m365.cloud.microsoft/apps/?auth=1)  

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
- [Transmission](https://transmissionbt.com/)  

**Entertainment**  
- [OpenEmu](https://openemu.org/)  

#### Typography Collection  
Over 50 professional fonts including:  
- **Monospace**: Cascadia Code, JetBrains Mono, JetBrains Mono Nerd Font, Monaspace, Roboto Mono  
- **Sans Serif**: Inter, Inter Tight, Lato, Montserrat, Nunito, Open Sans, Roboto  
- **Serif**: Crimson Pro, Libre Baskerville, Lora, Merriweather, Playfair Display  
- **Display**: Alfa Slab One, Outfit, Unica One  
- **Emoji & Symbols**: Noto Color Emoji, Noto Emoji, Noto Sans Symbols  

### `defaults.sh` – System Preferences Configuration  
✅ Configures macOS system defaults and preferences  
✅ Sets up Finder preferences (view styles, search scope, path display)  
✅ Configures Dock settings (auto-hide, icon size, recent apps)  
✅ Enables trackpad tap-to-click and drag lock  
✅ Sets up window management preferences  
✅ Configures accessibility features (zoom with scroll wheel)  
✅ Customizes Safari and TextEdit default behaviors  
✅ Applies changes by restarting affected system services  

### `dock.sh` – Dock Configuration  
✅ Completely customizes the macOS Dock layout  
✅ Removes all existing Dock items  
✅ Adds applications in organized groups with spacers  
✅ Adds useful folders (Applications, Setapp, Pictures, Music, Developer, Sites, Downloads)  
✅ Configures Dock size and auto-hide behavior  

### `git-user-signingkey.sh` – Git SSH Signing with 1Password  
✅ Retrieves SSH public key from 1Password  
✅ Configures `git config --global user.signingkey`  

### `valet.sh` – Laravel Valet Configuration  
✅ Installs and configures [Laravel Valet](https://laravel.com/docs/12.x/valet)  
✅ Sets up Valet in the `~/Sites` directory  
✅ Installs [PHP Monitor](https://phpmon.app/) for managing PHP versions  
✅ Creates a `phpinfo` directory with SSL certificate  
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

### Dock configuration (`dock.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/dock.sh | /bin/bash
```

### Git global user.signingkey script (`git-user-signingkey.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/git-user-signingkey.sh | /bin/bash
```

### Laravel Valet installation script (`valet.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/valet.sh | /bin/bash
```

## Manual Installation Required  

After running the main setup script, a file `remaining_apps.html` will be created on your Desktop with links to applications that need to be installed manually:  
- [CyberGhost VPN](https://www.cyberghostvpn.com/)  
- [Silicon](https://github.com/DigiDNA/Silicon)  
- [Steam](https://store.steampowered.com/)  
- [Tuxera NTFS](https://ntfsformac.tuxera.com/)