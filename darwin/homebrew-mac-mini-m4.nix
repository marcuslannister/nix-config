# darwin/homebrew-mac-mini-m4.nix
#
# What mac-mini-m4 holds beyond darwin/homebrew.nix.
#
# Casks only for now.  This machine carries several hundred formulae, and
# telling its Leaves from their dependencies needs the install receipts under
# /opt/homebrew/Cellar, which only exist on that Mac.  Until its brews are
# written down here, tests/homebrew-drift.zsh will report them all as
# undeclared -- that is honest, not a bug.
#
# Two more things it still carries that this repo deliberately does not
# Declare, and that should be removed there:
#   - 16 font casks, now supplied by fonts.packages in common-darwin.nix
#     (font-aporetic and font-server-mono have no Nix equivalent yet)
#   - git-credential-manager and its git-credential-manager-core phantom,
#     replaced by gh's credential helper
#
# Before this machine's first switch with this module: its taps must be in
# ~/.homebrew/trust.json, or `brew bundle` refuses to load their casks and
# activation fails.  home-manager deploys that file, but it runs *after*
# Homebrew, so the symlink has to exist beforehand:
#   ln -s ~/dotfiles/.homebrew/trust.json ~/.homebrew/trust.json
#   env -u XDG_CONFIG_HOME brew trust --taps <each third-party tap>
{ ... }:

{
  homebrew = {
    casks = [
      # shared with mac-mini-m1 only
      "amethyst"
      "android-platform-tools"
      "calibre"
      "fontbase"
      "forklift"
      "openmtp"
      "orion"

      # input method, re-adopted under the current token; the retired
      # `squirrel` record is dropped by path, never by `brew uninstall`
      "squirrel-app"

      # this machine only
      "docker-desktop"
      "fluidvoice"
      "macdown-3000"
      "magicquit"
      "pearcleaner"
      "popclip"
      "swiftmtp"
      "whatcable"
      "zen"
      "zen-browser"
    ];
  };
}
