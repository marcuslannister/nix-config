# darwin/homebrew.nix
#
# What every Darwin host gets from Homebrew.  The rule (see CONTEXT.md): an
# `.app` bundle belongs to Homebrew, everything else belongs to Nix.  A
# command-line tool with no nixpkgs package is an Exception and carries a
# comment saying why.
#
# Emacs comes from the d12frosted/emacs-plus tap on every Mac, ARM and Intel
# alike.  emacs-plus@31 tracks the emacs-31 release series (31.1 as of
# 2026-08-24) and has no bottle, so every install compiles from source.
# upgrade = true lets every other Leaf upgrade on activation, but emacs-plus@31
# must stay pinned -- `brew pin emacs-plus@31` -- or an unrelated
# `darwin-rebuild switch` turns into a 30-minute build.  `brew bundle` skips
# pinned formulae when it upgrades, so the pin, not this file, is what holds
# Emacs back; `brew unpin emacs-plus@31` releases it again.
#
# cleanup = "none" is deliberate and not a placeholder.  Homebrew 6 refuses
# `brew bundle --cleanup` without `--force-cleanup`, and that flag also resets
# the global trust store to the Brewfile's values.  This module cannot declare
# trust, so a cleanup run would empty the store and every third-party tap below
# would stop loading.  Completeness is enforced by tests/homebrew-drift.zsh
# instead, so removal stays a deliberate act rather than a side effect of
# activation.
#
# Every tap here must be trusted or `brew bundle` refuses to load its formulae
# and the switch fails.  Trust lives in two files, and which one Homebrew reads
# depends on the environment: an interactive shell has XDG_CONFIG_HOME set and
# uses ~/.config/homebrew/trust.json, while activation runs without it and uses
# ~/.homebrew/trust.json -- the symlink into ~/dotfiles.  Trusting a tap for
# activation therefore needs `env -u XDG_CONFIG_HOME brew trust --taps ...`.
#
# Both trust.json links are (re)created below, in preActivation, rather than
# by home-manager: nix-darwin's generated activation script runs `homebrew`
# (which is where `brew bundle` and its trust-store write live) long before
# home-manager's own user activation gets a turn.  A Mac whose links still
# pointed into the old, home-manager-managed /nix/store path -- see the
# CHANGELOG entry for the trust-store fix -- would fail `homebrew` before
# home-manager could ever repair it.  preActivation runs first of all, as
# root, so every path it touches is chowned back to the account explicitly.
#
# brewPrefix follows the platform on its own: /opt/homebrew on ARM, /usr/local
# on Intel.  A Mac with no Homebrew logs an error and skips.
{ config, lib, username, ... }:

let
  emacsPrefix = "${lib.removeSuffix "/bin" config.homebrew.brewPrefix}/opt/emacs-plus@31";
  homebrewTrustHome = "/Users/${username}";
in
{
  system.activationScripts.preActivation.text = lib.mkAfter ''
    mkdir -p "${homebrewTrustHome}/.homebrew" "${homebrewTrustHome}/.config/homebrew"
    chown ${username} "${homebrewTrustHome}/.homebrew" "${homebrewTrustHome}/.config/homebrew"
    ln -sfn "${homebrewTrustHome}/dotfiles/.homebrew/trust.json" "${homebrewTrustHome}/.homebrew/trust.json"
    ln -sfn "${homebrewTrustHome}/dotfiles/.homebrew/trust.json" "${homebrewTrustHome}/.config/homebrew/trust.json"
    chown -h ${username} "${homebrewTrustHome}/.homebrew/trust.json" "${homebrewTrustHome}/.config/homebrew/trust.json"
  '';

  # Homebrew Bundle builds the app bundles inside the keg, where Finder and
  # Spotlight never look, so copy them into /Applications afterwards.  The
  # script stops on its own unless the keg holds a new build.  A failed copy
  # must not abort the switch: activation runs under `set -e`, and a stale
  # /Applications is a far smaller problem than a system generation that never
  # finished activating.
  system.activationScripts.homebrew.text = lib.mkAfter ''
    /bin/sh ${../scripts/sync-emacs-apps.sh} "${emacsPrefix}" ||
      echo >&2 "warning: could not sync the Emacs app bundles to /Applications"
  '';

  homebrew = {
    enable = true;

    taps = [
      "d12frosted/emacs-plus"
      "muxy-app/tap"
      "eryouhao/tap"
    ];

    brews = [
      {
        name = "emacs-plus@31";
        args = [ "with-xwidgets" ];
      }

      # herdr: absent from nixpkgs (checked 2026-08-15), bottled in
      # homebrew/core for both aarch64 and x86_64, no tap needed.  Wanted on
      # every Mac, not just the ARM ones, so it lives here rather than in
      # darwin/homebrew-arm.nix.
      "herdr"
    ];

    casks = [
      "muxy"
      "graker"
    ];

    # The dragon-plus icon cannot be passed as a formula arg; it lives in
    # ~/.config/emacs-plus/build.yml (see home/home.nix).
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "none";
    };
  };
}
