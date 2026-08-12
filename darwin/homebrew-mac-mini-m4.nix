# darwin/homebrew-mac-mini-m4.nix
#
# What mac-mini-m4 holds beyond darwin/homebrew.nix and the shared ARM list in
# darwin/homebrew-arm.nix: its Exceptions, the taps that serve them and its
# casks.  This machine's Homebrew state is now completely Declared.
#
# Its 129 Leaves were read from the install receipts under /opt/homebrew/Cellar
# on 2026-08-12.  48 were already in environment.systemPackages, 34 moved there,
# 17 were dropped outright, and the rest turned out to be dependencies that
# `installed_on_request` had wrongly flagged as Leaves.
#
# Three Caskroom records are retired cask tokens kept as symlinks beside the
# live one -- squirrel -> squirrel-app, fontforge -> fontforge-app and
# zen-browser -> zen.  Only the live token is Declared.  Never remove the stale
# record with `brew uninstall --cask <old token>`: Homebrew resolves the alias
# and deletes the live cask instead.  Remove it by path.
#
# Before this machine's first switch with this module: its taps must be in
# ~/.homebrew/trust.json, or `brew bundle` refuses to load their formulae and
# activation fails.  home-manager deploys that file, but it runs *after*
# Homebrew, so the symlink has to exist beforehand:
#   ln -s ~/dotfiles/.homebrew/trust.json ~/.homebrew/trust.json
#   env -u XDG_CONFIG_HOME brew trust --taps <each third-party tap>
{ ... }:

{
  homebrew = {
    taps = [
      "darrylmorley/whatcable"  # whatcable
      "lihaoyun6/tap"           # xhistory
      "neighbor-z/swiftmtp"     # swiftmtp
      "nowledge-co/tap"         # con-beta
      "pouriyajamshidi/tap"     # tcping
      "scouzi1966/afm"          # afm
      "steipete/tap"            # codexbar
    ];

    # Exceptions, every one checked against this flake's nixpkgs on
    # aarch64-darwin with meta.available on 2026-08-12: httping and nexttrace
    # are Linux-only, nixpkgs `mole` is an unrelated SSH tunnel tool rather than
    # this Mac cleanup utility, and afm and tcping have no package at all.
    #
    # syncthing is the second kind of Exception (see CONTEXT.md): nixpkgs has
    # it, but a loaded launchd agent -- ~/Library/LaunchAgents/syncthing.plist,
    # hand-made in 2021 and outside this repo -- runs the Homebrew binary by
    # absolute path, so removing the formula stops the user's sync.  This
    # nix-darwin has no services.syncthing option, so Declaring the agent is
    # separate work.
    brews = [
      "afm"
      "httping"
      "mole"
      "nexttrace"
      "syncthing"
      "tcping"
    ];

    casks = [
      # shared with mac-mini-m1 only
      "amethyst"
      "android-platform-tools"
      "calibre"
      "fontbase"
      "forklift"
      "openmtp"
      "orion"

      # input method, Declared under the current token; the retired `squirrel`
      # record is dropped by path, never by `brew uninstall`
      "squirrel-app"

      # fonts with no nixpkgs equivalent.  The other 14 font casks this machine
      # carried are gone: 10 are supplied by fonts.packages in
      # common-darwin.nix, and 4 were dropped with macbook-pro-m1's.
      "font-aporetic"
      "font-server-mono"

      # this machine only
      "android-file-transfer"
      "balenaetcher"
      "codexbar"
      "con-beta"
      "docker-desktop"
      "fluidvoice"
      "fontforge-app"
      "ghostty"
      "macdown-3000"
      "magicquit"
      "pearcleaner"
      "popclip"
      "swiftmtp"
      # a JDK rather than an .app, but Homebrew puts it in
      # /Library/Java/JavaVirtualMachines where `java_home` finds it, which the
      # Nix store does not do
      "temurin"
      "whatcable"
      "xhistory"
      "zen"
    ];
  };
}
