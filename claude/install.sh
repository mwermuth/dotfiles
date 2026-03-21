#!/usr/bin/env bash
#
# Install Claude Code configuration files

set -e

CLAUDE_DIR="$HOME/.claude"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$CLAUDE_DIR"

for file in settings.json statusline.sh; do
  src="$SOURCE_DIR/$file"
  dst="$CLAUDE_DIR/$file"

  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    echo "  backing up $dst to ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi

  ln -sf "$src" "$dst"
  echo "  linked $src → $dst"
done

chmod +x "$CLAUDE_DIR/statusline.sh"
