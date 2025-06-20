# macOS Development Setup  

Installation and configuration scripts for my macOS environment.  

See my related dotfiles configuration: [macOS Dotfiles](https://github.com/lionelhenne/dotfiles).  

## Features  

### `setup.sh` – Base Configuration  
✅ Installs Xcode Command Line Tools  
✅ Sets up Homebrew and installs a selection of packages  
✅ Starts Atuin and PostgreSQL services  
✅ Installs Node.js (LTS) via fnm  
✅ Clones and applies [my dotfiles](https://github.com/lionelhenne/dotfiles) using GNU Stow  
✅ Configures Atuin  
✅ Creates the `Sites` and `Developer` directories  

#### Homebrew Packages Installed  
The following packages are installed via [Homebrew](https://brew.sh/):  

- **Development**: [Composer](https://getcomposer.org/), [PHP](https://www.php.net/), [PostgreSQL](https://www.postgresql.org/), [Node.js](https://nodejs.org/en) with [fnm](https://github.com/Schniz/fnm)  
- **Shell Prompt**: [Starship](https://starship.rs/)  
- **zsh Tools**: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)  
- **System Utilities**: [Atuin](https://atuin.sh/), [bat](https://github.com/sharkdp/bat), [duf](https://github.com/muesli/duf), [eza](https://github.com/eza-community/eza), [fd](https://github.com/sharkdp/fd), [mkcert](https://github.com/FiloSottile/mkcert), [nss](https://firefox-source-docs.mozilla.org/security/nss/index.html), [stow](https://www.gnu.org/software/stow/), [tlrc](https://tldr.sh/tlrc/), [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree), [wget](https://www.gnu.org/software/wget/)  
- **Fonts**: [Cascadia Code](https://github.com/microsoft/cascadia-code), [JetBrains Mono](https://www.jetbrains.com/fr-fr/lp/mono/), [JetBrains Mono Nerd Font](https://www.nerdfonts.com/), [Monaspace](https://monaspace.githubnext.com/)  
- **Terminal-based Text Editor**: [micro](https://micro-editor.github.io/)  

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
✅ Adds useful folders  
✅ Configures Dock size and auto-hide behavior  

### `git-user-signingkey.sh` – Git SSH Signing with 1Password  
✅ Retrieves SSH public key from 1Password  
✅ Configures `git config --global user.signingkey`  

### `valet.sh` – Laravel Valet Configuration  
✅ Installs and configures [Laravel Valet](https://laravel.com/docs/12.x/valet)  
✅ Sets up PHP-FPM for PHP 8.3 (if installed)  
✅ Installs [PHP Monitor](https://phpmon.app/) for managing PHP versions  
✅ Creates a `phpinfo` directory with an `index.php` file  

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