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

- **Development**: [Composer](https://getcomposer.org/), [PHP](https://www.php.net/), [PostgreSQL](https://www.postgresql.org/), [fnm](https://github.com/Schniz/fnm)  
- **Shell Prompt**: [Starship](https://starship.rs/)  
- **zsh Tools**: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)  
- **System Utilities**: [Atuin](https://atuin.sh/), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [fd](https://github.com/sharkdp/fd), [stow](https://www.gnu.org/software/stow/), [tlrc](https://tldr.sh/tlrc/), [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree), [wget](https://www.gnu.org/software/wget/)  
- **Fonts**: [JetBrains Mono](https://www.jetbrains.com/fr-fr/lp/mono/), [JetBrains Mono Nerd Font](https://www.nerdfonts.com/), [Monaspace](https://monaspace.githubnext.com/)  
- **Terminal-based Text Editor**: [micro](https://micro-editor.github.io/)  

### `git-user-signingkey.sh` – Git SSH Signing with 1Password  
✅ Retrieves your SSH public key from 1Password
✅ Configures git config --global user.signingkey

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
### Git global user.signingkey script (`git-user-signingkey.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/git-user-signingkey.sh | /bin/bash
```

### Laravel Valet installation script (`valet.sh`)  
```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/refs/heads/main/valet.sh | /bin/bash
```
