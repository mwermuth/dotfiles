# Dotfiles

Personal dotfiles for macOS development environment.

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./script/bootstrap
```

## What's Included

- **Shell**: Zsh configuration with custom prompt and aliases
- **Git**: Global git configuration with credential helpers
- **Terminal**: Ghostty terminal configuration with Catppuccin theme
- **macOS**: System defaults and preferences
- **Apps**: Homebrew packages and applications via Brewfile

## Structure

- `zsh/` - Zsh configuration files
- `git/` - Git configuration and templates
- `ghostty/` - Terminal configuration
- `macos/` - macOS system defaults
- `script/` - Installation and setup scripts
- `Brewfile` - Homebrew packages and applications

## Features

- **Automatic Setup**: One-command installation via `bootstrap` script
- **XDG Compliance**: Config files organized in `~/.config/`
- **Conflict Resolution**: Smart handling of existing files
- **macOS Optimized**: Tailored for macOS development workflow

## Manual Installation

If you prefer manual setup:

```bash
# Install Homebrew packages
brew bundle

# Apply macOS defaults
./macos/set-defaults.sh

# Link dotfiles manually
./script/install
```
