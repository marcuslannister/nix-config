#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
flake_ref=$repo_root
home_dir=$(nix eval --raw "$flake_ref#darwinConfigurations.default.config.home-manager.users.user.home.homeDirectory")
layout_attr="darwinConfigurations.default.config.home-manager.users.user.home.file.\"$home_dir/.config/zellij/layouts/default.kdl\".text"
actual_layout=$(nix eval --raw "$flake_ref#$layout_attr")
upstream_path=$(nix eval --impure --raw --expr '
  let
    flake = builtins.getFlake "'"$repo_root"'";
    system = flake.darwinConfigurations.default.pkgs.stdenv.hostPlatform.system;
  in
    (builtins.getAttr system flake.inputs.zjstatus.packages).default.outPath
')
expected_location="file:$upstream_path/bin/zjstatus.wasm"
actual_location=$(print -r -- "$actual_layout" | rg -o 'file:[^" ]+/bin/zjstatus\.wasm' | head -1)

if [[ $actual_location != $expected_location ]]; then
  print -u2 -- "expected upstream local plugin: $expected_location"
  print -u2 -- "actual plugin: $actual_location"
  exit 1
fi

if print -r -- "$actual_layout" | rg -q 'plugin location="https://'; then
  print -u2 -- 'generated layout still uses a remote plugin URL'
  exit 1
fi

print -- "generated layout uses upstream local plugin: $expected_location"
