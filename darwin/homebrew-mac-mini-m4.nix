# darwin/homebrew-mac-mini-m4.nix
#
# What mac-mini-m4 holds beyond darwin/homebrew.nix and the shared ARM list in
# darwin/homebrew-arm.nix: its Exceptions, the taps that serve them and its
# casks.  This machine's Homebrew state is completely Declared.
#
# Its 129 Leaves were read from the install receipts under /opt/homebrew/Cellar
# on 2026-08-12.  45 were already in environment.systemPackages, 33 moved there,
# 18 were dropped outright, 7 stayed Declared here, and the remaining 26 turned
# out to be dependencies that `installed_on_request` had wrongly flagged as
# Leaves.
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
      "crmne/tap" # fastpotify
      "darrylmorley/whatcable" # whatcable
      "neighbor-z/swiftmtp" # swiftmtp
    ];

    # httping, mole, nexttrace and tcping promoted to darwin/homebrew-arm.nix
    # on 2026-08-15 -- all three ARM Macs carried them.
    #
    # syncthing is the second kind of Exception (see CONTEXT.md): nixpkgs has
    # it, but a loaded launchd agent -- ~/Library/LaunchAgents/syncthing.plist,
    # hand-made in 2021 and outside this repo -- runs the Homebrew binary by
    # absolute path, so removing the formula stops the user's sync.  This
    # nix-darwin has no services.syncthing option, so Declaring the agent is
    # separate work.
    brews = [
      "syncthing"
    ];

    casks = [
      # shared with mac-mini-m1 only
      "calibre"

      # shared with macbook-pro-m1 only
      "fastpotify"

      # ~/.emacs.d/lisp/init-local.el asks for "Aporetic Sans M Nerd Font", and
      # nixpkgs has no equivalent.  The other 15 font casks this machine carried
      # are gone: 10 are supplied by fonts.packages in common-darwin.nix, and 5
      # were dropped.
      "font-aporetic"

      # this machine only
      "docker-desktop"
      "fluidvoice"
      "macdown-3000"
      "magicquit"
      "popclip"
      "swiftmtp"
      "whatcable"
      "zen"
    ];
  };
}
