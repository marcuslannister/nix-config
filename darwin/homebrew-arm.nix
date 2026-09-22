# darwin/homebrew-arm.nix
#
# ARM-only additions to darwin/homebrew-common.nix.  The common module carries
# the cross-architecture subset; these packages stay on the ARM Macs because
# the current Intel profile does not use them.  `raycast` is ARM-only in the
# current cask definition, and the current `tcping` release is darwin-arm64.
#
# This list started as a description of what was already true on all three, so
# adopting it installed and removed nothing.  It is now a decision as well: a
# formula promoted here is installed on any of the three that lacks it at the
# next switch, and one dropped from here leaves all three.  `betterdisplay`,
# `iina`, `spotify`, `winbox` and `lm-studio` are deliberately not part of the
# Intel profile by user choice.
{ ... }:

{
  imports = [ ./homebrew-common.nix ];

  homebrew = {
    taps = [
      "pouriyajamshidi/tap" # tcping
    ];

    brews = [
      "pouriyajamshidi/tap/tcping"
    ];

    casks = [
      "raycast"
      "betterdisplay"
      "iina"
      "spotify"
      "winbox"
      "lm-studio"
      "thaw"
    ];
  };
}
