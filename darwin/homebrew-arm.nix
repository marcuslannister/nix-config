# darwin/homebrew-arm.nix
#
# The casks and brews all three ARM Macs should carry.  Anything only some of
# them want stays in that host's own file.
#
# This list started as a description of what was already true on all three, so
# adopting it installed and removed nothing.  It is now a decision as well: a
# formula promoted here is installed on any of the three that lacks it at the
# next switch, and one dropped from here leaves all three.  `thaw` was
# promoted that way on 2026-08-12 and installed on mac-mini-m4 by the switch
# that followed.  httping, mole, nexttrace and tcping were promoted the same
# way on 2026-08-15.  keyboardholder was dropped on 2026-09-01: its app was
# already gone from /Applications on macbook-pro-m1 (nothing left for an
# upgrade to replace) and Homebrew deprecated the cask the same day for
# failing the macOS Gatekeeper check.
#
# Deliberately not in darwin/homebrew.nix: that module reaches every Darwin
# host, including `default` and the Intel Mac, and neither should acquire one
# group's application list.
{ ... }:

{
  homebrew = {
    taps = [
      "tw93/tap" # mole
      "pouriyajamshidi/tap" # tcping
    ];

    # Exceptions, checked against this flake's nixpkgs on 2026-08-12/13:
    # httping and nexttrace are Linux-only, nixpkgs `mole` is an unrelated SSH
    # tunnel tool rather than this Mac cleanup utility, and tcping has no
    # package at all.  httping and nexttrace come from homebrew/core and need
    # no tap.  tcping is qualified with its tap: homebrew/core grew its own
    # unrelated `tcping` formula on 2026-08-31, and `brew bundle` refuses to
    # resolve the bare name once two taps claim it.
    brews = [
      "httping"
      "mole"
      "nexttrace"
      "pouriyajamshidi/tap/tcping"
    ];

    casks = [
      # browsers
      "brave-browser"
      "google-chrome"

      # editors and terminals
      "kitty"
      "markedit"

      # input methods and text
      "atext"
      # Declared under the current token; the retired `squirrel` record beside
      # it is dropped by path, never by `brew uninstall`, which resolves the
      # alias and deletes the live cask.
      "squirrel-app"

      # window and input management
      "alt-tab"
      "bettertouchtool"
      "hammerspoon"
      "karabiner-elements"
      "macgesture"
      "raycast"

      # display and screen
      "betterdisplay"

      # media
      "iina"
      "spotify"

      # network and remote
      "winbox"

      # security and privacy
      "lulu"
      "oversight"

      # system utilities
      "apparency"
      "appcleaner"
      "sensei"
      "sloth"
      "thaw"
      "tmpdisk"

      # misc tools
      "lm-studio"
    ];
  };
}
