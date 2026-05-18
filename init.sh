#!/usr/bin/env bash
set -euo pipefail

# ── WASUP Banner ──────────────────────────────────────────────
echo ' ▄     ▄ ▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄    ▄▄▄ ▄▄    ▄ ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄ ▄▄▄▄▄▄ ▄▄▄     ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   '
echo '█ █ ▄ █ █      █       █  █ █  █       █  █   █  █  █ █   █       █   █      █   █   █   █       █       █   ▄  █  '
echo '█ ██ ██ █  ▄   █  ▄▄▄▄▄█  █ █  █    ▄  █  █   █   █▄█ █   █▄     ▄█   █  ▄   █   █   █   █▄▄▄▄   █    ▄▄▄█  █ █ █  '
echo '█       █ █▄█  █ █▄▄▄▄▄█  █▄█  █   █▄█ █  █   █       █   █ █   █ █   █ █▄█  █   █   █   █▄▄▄▄█  █   █▄▄▄█   █▄▄█▄ '
echo '█       █      █▄▄▄▄▄  █       █    ▄▄▄█  █   █  ▄    █   █ █   █ █   █      █   █▄▄▄█   █ ▄▄▄▄▄▄█    ▄▄▄█    ▄▄  █'
echo '█   ▄   █  ▄   █▄▄▄▄▄█ █       █   █      █   █ █ █   █   █ █   █ █   █  ▄   █       █   █ █▄▄▄▄▄█   █▄▄▄█   █  █ █'
echo '█▄▄█ █▄▄█▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄█      █▄▄▄█▄█  █▄▄█▄▄▄█ █▄▄▄█ █▄▄▄█▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄█  █▄█'
echo ""
echo "                                 wasup — structured dev workflow"
echo ""

# ── Install ──────────────────────────────────────────────────
echo "Choose install type:"
echo "  1) Project skill install  (current project only)"
echo "  2) Global skill install   (all projects)"
echo "  3) Already installed      (skip install)"
echo ""
read -r -p "Enter choice [1/2/3]: " choice

case "$choice" in
  1)
    echo ""
    echo "Installing Wasup as project skill..."
    pnpx skills add EdwardJoke/wasup
    echo "Project install complete."
    ;;
  2)
    echo ""
    echo "Installing Wasup as global skill..."
    pnpx skills add -g EdwardJoke/wasup
    echo "Global install complete, continue install for the current project."
    exit 0
    ;;
  3)
    echo "Skipping install — already installed."
    ;;
  *)
    echo "Invalid choice, continue install for the current project."
    ;;
esac

# ── Prerequisites ────────────────────────────────────────────
echo ""
echo "Generating wasup config..."

REPO_NAME=$(basename "$(pwd)")
CONFIG_DIR=".wasup"
CONFIG_FILE="$CONFIG_DIR/wasup.toml"

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  echo "  $CONFIG_FILE already exists — skipping."
else
  cat > "$CONFIG_FILE" <<TOML
[repo]
name = "$REPO_NAME"
current_version = "v0.1.0"
next_version = "v0.1.0"

[repo.branches]
dev = "dev"
main = "master"
TOML
  echo "  Created $CONFIG_FILE"
fi

echo ""
echo "wsp-opt installed successfully."
echo "Next: run 'wsp-opt' to start your first workflow."
