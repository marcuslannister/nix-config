#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
flake_ref=$repo_root
home_dir=$(nix eval --raw "$flake_ref#darwinConfigurations.default.config.home-manager.users.user.home.homeDirectory")
config_key="$home_dir/.config/zellij/config.kdl"
plugin_key="$home_dir/.config/zellij/plugins/zellij-smart-tabs.wasm"
config_source=$(nix build --no-link --print-out-paths --impure --expr '
  (builtins.getFlake "'"$repo_root"'")
    .darwinConfigurations.default.config.home-manager.users.user.home.file
    ."'"$config_key"'".source
')
actual_config=$(<"$config_source")
expected_location='file:~/.config/zellij/plugins/zellij-smart-tabs.wasm'
actual_location=$(print -r -- "$actual_config" | rg -o 'smart-tabs[[:space:]]+location="[^"]+' | head -1 || true)
actual_location=${actual_location#*\"}

if [[ $actual_location != $expected_location ]]; then
  print -u2 -- "expected Smart Tabs local location: $expected_location"
  print -u2 -- "actual Smart Tabs location: $actual_location"
  exit 1
fi

if ! print -r -- "$actual_config" | rg -Uq 'load_plugins[[:space:]]*\{[^}]*smart-tabs'; then
  print -u2 -- 'Smart Tabs is not loaded at startup'
  exit 1
fi

plugin_source=$(nix eval --raw "$flake_ref#darwinConfigurations.default.config.home-manager.users.user.home.file.\"$plugin_key\".source")
expected_hash='sha256-CUSSxJWAZLejW4uGwoVpudHCRD1gqHLanyamHmjF3y0='
actual_hash=$(nix hash file --sri "$plugin_source")

if [[ $actual_hash != $expected_hash ]]; then
  print -u2 -- "expected Smart Tabs v0.2.4 hash: $expected_hash"
  print -u2 -- "actual Smart Tabs hash: $actual_hash"
  exit 1
fi

print -- "Smart Tabs uses local plugin: $expected_location"
print -- "Smart Tabs v0.2.4 hash verified: $expected_hash"
