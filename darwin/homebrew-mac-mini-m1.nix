# darwin/homebrew-mac-mini-m1.nix
#
# What mac-mini-m1 holds beyond darwin/homebrew.nix.
#
# Casks only for now, for the same reason as mac-mini-m4: separating this
# machine's Leaves from their dependencies needs the install receipts under
# /opt/homebrew/Cellar, which only exist there.
#
# Still carried but deliberately not Declared, and due for removal on that
# machine: 15 font casks now supplied by fonts.packages in common-darwin.nix,
# git-credential-manager with its -core phantom, and the retired `squirrel`
# record that sits alongside the live squirrel-app.
#
# Before this machine's first switch with this module, its taps must be in
# ~/.homebrew/trust.json; see the note in darwin/homebrew-mac-mini-m4.nix.
{ ... }:

{
  homebrew = {
    casks = [
      # shared with mac-mini-m4 only
      "amethyst"
      "android-platform-tools"
      "calibre"
      "fontbase"
      "forklift"
      "openmtp"
      "orion"

      # this machine only
      "electrum"
      "openusage"
    ];
  };
}
