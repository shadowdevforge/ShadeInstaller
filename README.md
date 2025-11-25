# ShadeInstaller

```

        ▄█████ ▄▄ ▄▄  ▄▄▄  ▄▄▄▄  ▄▄▄▄▄    
        ▀▀▀▄▄▄ ██▄██ ██▀██ ██▀██ ██▄▄     
        █████▀ ██ ██ ██▀██ ████▀ ██▄▄▄    
                                                                                             
██ ▄▄  ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄  ▄▄    ▄▄    ▄▄▄▄▄ ▄▄▄▄ 
██ ███▄██ ███▄▄   ██  ██▀██ ██    ██    ██▄▄  ██▄█▄
██ ██ ▀██ ▄▄██▀   ██  ██▀██ ██▄▄▄ ██▄▄▄ ██▄▄▄ ██ ██

```

> **A beautiful, intelligent, cross-distribution Linux setup wizard that actually respects your time.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/Lua-5.1+-purple.svg)](https://www.lua.org/)
[![Distros](https://img.shields.io/badge/Supports-Arch%20%7C%20Debian%20%7C%20Fedora-green.svg)]()

---

## 🎯 What is ShadeInstaller?

ShadeInstaller is a **terminal-based installation wizard** that transforms the painful process of setting up a fresh Linux system into an elegant, interactive experience. Choose your shell, select packages from curated domains, configure Neovim, and let ShadeInstaller handle the rest—across Arch, Debian/Ubuntu, and Fedora.

### Why ShadeInstaller?

- 🎨 **Gorgeous UI** — Catppuccin Mocha theming with color-coded interactions
- 🔀 **Cross-Distribution** — One script, three major Linux families
- 🛡️ **Safe & Transparent** — Dry-run mode, error recovery, full logging
- 🎛️ **Domain-Based Selection** — Organized categories prevent overwhelm
- 🔧 **Smart Package Resolution** — Automatically maps packages to your distro
- 📝 **Neovim Configs** — Pre-configured setups (NvShade, LazyVim, NvChad, etc.)
- ✨ **Professional Error Handling** — Retry, skip, or abort on failures
- 🎓 **Educational** — Learn package manager commands via dry-run

---

## 🚀 Quick Start

### Prerequisites

You only need **Lua** or **LuaJIT** installed:

```bash
# Arch
sudo pacman -S lua

# Debian/Ubuntu
sudo apt install lua5.4

# Fedora
sudo dnf install lua
```

### Installation

#### Option 1: Direct Execution (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/shadowdevforge/ShadeInstaller/main/install.lua | lua
```

#### Option 2: Preview Mode (Dry-Run)

Want to see what commands will run before executing? Use dry-run:

```bash
curl -fsSL https://raw.githubusercontent.com/shadowdevforge/ShadeInstaller/main/install.lua | lua --dry-run
```

#### Option 3: Download & Inspect

```bash
curl -O https://raw.githubusercontent.com/shadowdevforge/ShadeInstaller/main/install.lua
less install.lua  # Review the code
lua install.lua
```

---

## 📦 What Can ShadeInstaller Install?

### 64 Curated Packages Across 8 Domains

| Domain | Examples |
|--------|----------|
| **Browsers** | Firefox, Chromium, Brave, LibreWolf, Tor, Qutebrowser |
| **Multimedia** | VLC, MPV, OBS Studio, GIMP, Inkscape, Blender |
| **Dev Tools** | Git, Docker, VS Code, LazyGit, CMake, Ninja |
| **System Utils** | Htop, Btop, Neofetch, Curl, Wget, GParted |
| **Social** | Discord, Telegram, Slack, Signal, Zoom, Element |
| **Gaming** | Steam, Lutris, Wine, GameMode, MangoHud, RetroArch |
| **Terminal** | FZF, RipGrep, Bat, Tmux, Zoxide, Eza, Yazi |
| **Languages** | Python, Node.js, Go, Rust, GCC, Lua, Ruby, PHP |

### Plus Core System Setup

- **Shell Configuration** — Zsh (recommended), Fish, or Bash
- **Neovim Distributions** — NvShade★, LazyVim, NvChad, AstroNvim, Kickstart
- **Git Global Config** — Name and email setup with validation

---

## 🎮 Usage Guide

### Step-by-Step Walkthrough

1. **Shell Selection**
   ```
   :: Select Shell
   ----------------------------------------
    1. Zsh (Recommended)
    2. Fish
    3. Bash (Default)
   
   Choice? [1]: 
   ```

2. **Package Domain Navigation**
   ```
   :: Package Domains
   ----------------------------------------
    1. Browsers
    2. Multimedia          [3 selected]
    3. Dev Tools           [5 selected]
    ...
   
   Enter ID to open domain, (d)one to proceed.
   ```

3. **Domain-Level Selection**
   ```
   :: Domain: Dev Tools
   ----------------------------------------
    1. [x] Base Tools
    2. [x] Git
    3. [ ] Docker
    4. [x] VS Code
   
   (ID) Toggle, (a) All, (n) None, (b) Back
   ```

4. **Neovim Setup**
   ```
   :: Neovim Setup
   ----------------------------------------
   Install Neovim & Config? [y]: y
   
   Choose Distribution:
    ★ 1. NvShade
      2. LazyVim
      3. NvChad
   ```

5. **Summary & Confirmation**
   ```
   :: Manifest Summary
   ----------------------------------------
    Distro:     ARCH
    Shell:      Zsh (Recommended)
    Neovim:     NvShade
    Git:        user@example.com
    Packages:   12 queued
    Preview:    firefox, git, docker, vlc, mpv...
   
   Options:
    (p) Proceed with Install
    (e) Edit Selections
    (q) Quit
   ```

6. **Installation Progress**
   ```
   :: Installation Progress
   ----------------------------------------
   [1/8] Update System Repos
   [2/8] Install Shell: Zsh
   [3/8] Install User Packages
   ...
   
   ✔ Installation Complete!
     Log: ~/ShadeInstaller.log
   ```

---

## 🛡️ Safety Features

### Dry-Run Mode

Preview all commands before execution:

```bash
lua install.lua --dry-run
```

**Output Example:**
```
[1/8] Update System Repos
  [DRY] sudo pacman -Syu --noconfirm

[2/8] Install Shell: Zsh  
  [DRY] sudo pacman -S --noconfirm zsh

[3/8] Install User Packages
  [DRY] sudo pacman -S --noconfirm firefox git docker neovim
```

### Error Recovery System

If a command fails, you get three options:

```
[!] Command failed: sudo pacman -S brave-bin

Select action:
 (r) Retry
 (s) Skip this step
 (a) Abort installation

Action? [r]: 
```

### Edit-Before-Commit

Changed your mind? Hit `(e)` in the summary screen to go back and modify selections without restarting.

### Transparent Package Resolution

See exactly what package names will be used for your distro:

```
Packages:   5 queued
Preview:    firefox-esr, build-essential, python3, nodejs, code
            ^^^^^^^^^^   ^^^^^^^^^^^^^^^  ^^^^^^^
            Debian-specific mappings shown
```

---

## 🎨 Features in Detail

### 1. Cross-Distribution Intelligence

ShadeInstaller automatically resolves package names:

```lua
-- You select: "Base Tools"
-- ShadeInstaller installs:
--   • base-devel         (Arch)
--   • build-essential    (Debian/Ubuntu)  
--   • @development-tools (Fedora)
```

### 2. Smart Shell Management

- Installs your chosen shell
- Changes default shell safely
- Provides post-install instructions
- Backs up existing configs

### 3. Neovim Ecosystem Integration

- Backs up `~/.config/nvim` to `~/.config/nvim.bak`
- Clones your chosen distro directly
- Installs Neovim itself if needed
- Works with: NvShade, LazyVim, NvChad, AstroNvim, Kickstart

### 4. Git Configuration Validation

- Validates email format (must contain `@`)
- Sets global user.name and user.email
- Skippable if you prefer manual setup

### 5. Comprehensive Logging

Everything is logged to `~/ShadeInstaller.log`:

```
--- ShadeInstaller Log ---
Distro: arch
Mode: Live
Date: Fri Nov 26 15:34:12 2025

[TASK] Update System Repos
[CMD]  sudo pacman -Syu --noconfirm
[SUCCESS] Exit code: 0
...
```

---

## 🔧 Advanced Usage

### Package Selection Shortcuts

| Key | Action |
|-----|--------|
| `1-8` | Open domain / Toggle package |
| `a` | Select all in domain |
| `n` | Deselect all in domain |
| `b` | Go back |
| `d` | Done / Proceed |
| `e` | Edit from summary |
| `p` | Proceed with install |
| `q` | Quit |

### Supported Distributions

| Distribution | Package Manager | Status |
|--------------|----------------|--------|
| Arch Linux | Pacman | ✅ Full Support |
| Manjaro | Pacman | ✅ Full Support |
| Debian | APT | ✅ Full Support |
| Ubuntu | APT | ✅ Full Support |
| Linux Mint | APT | ✅ Full Support |
| Fedora | DNF | ✅ Full Support |

### Custom Modifications

Edit `install.lua` to add your own packages:

```lua
Data.domains = {
    ...
    { 
        name = "My Custom Tools",
        items = {
            { n="MyApp", p="myapp" },
            { n="Another", p={ arch="pkg1", deb="pkg2", default="pkg3" } }
        }
    }
}
```

---

## 📋 Known Limitations

### AUR Packages (Arch)

Some packages like `brave-bin` and `visual-studio-code-bin` require an AUR helper (yay, paru). ShadeInstaller will attempt installation via pacman, which will fail. Use the error recovery to skip, then install manually:

```bash
yay -S brave-bin visual-studio-code-bin
```

### Repository Availability

- **Brave Browser**: Requires brave repository on Debian/Ubuntu
- **VS Code**: Requires Microsoft repository on Debian/Ubuntu
- Packages not in default repos will fail gracefully

### Post-Install Steps

Some packages require additional configuration:

- **Docker**: Enable service with `sudo systemctl enable --now docker`
- **Shell Change**: Log out and back in for changes to take effect
- **Neovim**: Run `nvim` to trigger plugin installation

---

## 🐛 Troubleshooting

### Installation Failed

1. Check `~/ShadeInstaller.log` for detailed errors
2. Verify internet connection
3. Ensure package repositories are up to date
4. Run with `--dry-run` to preview commands

### Package Not Found

Some packages have different names across distros. Check your distribution's package search:

```bash
# Arch
pacman -Ss package-name

# Debian/Ubuntu
apt search package-name

# Fedora
dnf search package-name
```

### Permission Errors

Ensure your user has sudo privileges:

```bash
sudo -v
```

### Shell Not Changing

After installation, you must log out and back in (or restart) for shell changes to apply.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Adding Package Support

1. Fork the repository
2. Edit `Data.domains` to add packages
3. Use the resolution pattern:
   ```lua
   { n="Package Name", p={ arch="pkg-arch", deb="pkg-deb", default="pkg-name" } }
   ```
4. Test on multiple distros
5. Submit a pull request

### Reporting Issues

- Use dry-run mode to capture command output
- Include `~/ShadeInstaller.log` content
- Specify your distribution and version
- Describe expected vs actual behavior

### Feature Requests

Open an issue with the `enhancement` label and describe:
- The use case
- Proposed implementation
- Why it benefits users

---

## 📜 License

ShadeInstaller is released under the **MIT License**.

```
MIT License

Copyright (c) 2025 ShadowDevForge

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[Full license text at LICENSE file]
```

---

## 🙏 Acknowledgments

- **Catppuccin** — For the beautiful Mocha color palette
- **Neovim Community** — For the amazing distributions (LazyVim, NvChad, AstroNvim)
- **Linux Community** — For making cross-distro tooling possible

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/shadowdevforge/ShadeInstaller/issues)
- **Discussions**: [GitHub Discussions](https://github.com/shadowdevforge/ShadeInstaller/discussions)
- **Author**: ShadowDevForge

---

<div align="center">

**Made with love for the amazing Linux community**

*"Because your fresh install deserves better than copy-pasting random commands from StackOverflow."*

[⬆ Back to Top](#shadeinstaller)

</div>
