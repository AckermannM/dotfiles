# ============================================================================
# asdf dotnet plugin environment, if available
# ============================================================================
if command -v asdf >/dev/null 2>&1; then
  if asdf plugin list 2>/dev/null | grep -q "^dotnet-core$"; then
    plugin_path="${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/dotnet-core/set-dotnet-home.zsh"
    if [ -f "$plugin_path" ]; then
      . "$plugin_path"
    fi
  fi
fi
