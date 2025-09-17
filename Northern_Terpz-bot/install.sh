cat > install.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="$HOME/terpz-tools"
REPO_URL="https://github.com/NorthernTerpz/northern_terpz_bot.git"
BASHRC="$HOME/.bashrc"

if [ -d "$TOOLS_DIR/.git" ]; then
  echo "🔄 Updating existing terpz-tools..."
  git -C "$TOOLS_DIR" pull --ff-only
else
  echo "📥 Cloning terpz-tools to $TOOLS_DIR..."
  git clone "$REPO_URL" "$TOOLS_DIR"
fi

chmod +x "$TOOLS_DIR"/*.sh
echo "✅ Scripts are now executable."

add_alias() {
  local name="$1" cmd="$2"
  if ! grep -qxF "alias $name=\"$cmd\"" "$BASHRC"; then
    echo "alias $name=\"$cmd\"" >> "$BASHRC"
    echo "🔖 Added alias '$name'."
  fi
}

add_alias terpz        "$TOOLS_DIR/terpz.sh"
add_alias terpzstatus  "$TOOLS_DIR/terpzstatus.sh"
add_alias terpzlog     "tail -f \$HOME/Northern_Terpz-bot/bot.log"
add_alias terpzclean   "$TOOLS_DIR/terpzclean.sh"
add_alias terpzmenu    "$TOOLS_DIR/terpzmenu.sh"
add_alias terpzhelp    "$TOOLS_DIR/terpzhelp.sh"

echo "♻️ Reloading $BASHRC..."
source "$BASHRC"

echo -e "\n🚀 Installation complete! Run 'terpzmenu' to see available commands."
EOF
