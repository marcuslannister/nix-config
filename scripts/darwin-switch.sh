#!/usr/bin/env bash
# Apply this flake's Nix Darwin configuration (the refresh-mac skill, step 3).
# Agents run this script, not `sudo darwin-rebuild`: the Claude Code ask rule
# Bash(sudo:*) matches before any allow rule and stops the agent at a dialog.
# rebuildSudoModule in flake.nix lets this exact path run without a password.
set -euo pipefail
cd "$(dirname "$0")/.."
exec sudo /run/current-system/sw/bin/darwin-rebuild switch --flake . --impure "$@"
