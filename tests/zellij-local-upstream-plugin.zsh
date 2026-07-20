#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
flake_ref=$repo_root
home_dir=$(nix eval --raw "$flake_ref#darwinConfigurations.default.config.home-manager.users.user.home.homeDirectory")
layout_key="$home_dir/.config/zellij/layouts/default.kdl"
plugin_key="$home_dir/.config/zellij/plugins/zjstatus.wasm"
layout_source=$(nix build --no-link --print-out-paths --impure --expr '
  (builtins.getFlake "'"$repo_root"'")
    .darwinConfigurations.default.config.home-manager.users.user.home.file
    ."'"$layout_key"'".source
')
plugin_source=$(nix eval --raw "$flake_ref#darwinConfigurations.default.config.home-manager.users.user.home.file.\"$plugin_key\".source")
actual_layout=$(<"$layout_source")
upstream_path=$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake "'"$repo_root"'";
    system = flake.darwinConfigurations.default.pkgs.stdenv.hostPlatform.system;
  in
    (builtins.getAttr system flake.inputs.zjstatus.packages).default.outPath
')
expected_source="$upstream_path/bin/zjstatus.wasm"
expected_location='file:~/.config/zellij/plugins/zjstatus.wasm'
actual_location=$(print -r -- "$actual_layout" | rg -o 'plugin location="[^"]+' | head -1)
actual_location=${actual_location#*\"}

if [[ $actual_location != $expected_location ]]; then
  print -u2 -- "expected stable local plugin location: $expected_location"
  print -u2 -- "actual plugin location: $actual_location"
  exit 1
fi

if [[ $plugin_source != $expected_source ]]; then
  print -u2 -- "expected upstream plugin source: $expected_source"
  print -u2 -- "actual plugin source: $plugin_source"
  exit 1
fi

print -- "layout uses stable local plugin: $expected_location"
print -- "plugin source is upstream artifact: $expected_source"
