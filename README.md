# macOS Setup

Bootstrap + modular post-install for a fresh macOS installation, in one repo.

## How it works

Two entry points, two different jobs:

- **`setup.sh`** — bootstrap. Non-interactive, safe to run via `curl | bash`
  on a brand new Mac (no git yet). Installs the Xcode Command Line Tools
  itself (polling for completion rather than relying on a TTY), then
  Homebrew, the core package set ([`inventory/Brewfile`](inventory/Brewfile)),
  and clones this repo locally.
- **`install.sh`** — module installer. Only runs locally, once the repo is
  cloned. Interactive: `./install.sh` for a menu, or `./install.sh <module>`
  to run one directly.

## Usage

### On a fresh Mac

```bash
curl -fsSL https://raw.githubusercontent.com/lionelhenne/macossetup/main/setup.sh | bash
cd ~/Developer/macossetup
./install.sh
```

If the Xcode Command Line Tools aren't already on the Mac, the script tries
a silent install first; if that's not available (e.g. some beta macOS
builds), it triggers the GUI installer and waits for it to finish by
polling, not by reading a keypress — so this works even with no terminal
attached to the process, as is the case with `curl | bash`.

### On a machine that already has the repo

```bash
./setup.sh          # re-run bootstrap (idempotent)
./install.sh webdev  # run a specific module directly
```

## Modules

| Module | What it does |
|---|---|
| `identity` | Git signing key + SSH config, sourced from 1Password |
| `webdev` | PHP, Composer, Laravel Valet, Node.js (fnm), MySQL, PostgreSQL |
| `casks` | GUI applications ([`inventory/Brewfile.casks`](inventory/Brewfile.casks)) |
| `fonts` | Font collection ([`inventory/Brewfile.fonts`](inventory/Brewfile.fonts)) |

See my related dotfiles: [macOS Dotfiles](https://github.com/lionelhenne/dotfiles)

## License

MIT License - see [LICENSE](LICENSE) file for details.
