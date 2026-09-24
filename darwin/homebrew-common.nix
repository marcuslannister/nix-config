# Homebrew packages shared by ARM and Intel Macs.
#
# This is the cross-architecture subset of the ARM application list.  Homebrew
# still checks each cask's macOS version requirement during activation.
{ ... }:

{
  homebrew = {
    taps = [
      "tw93/tap" # mole
      "steipete/tap" # peekaboo
      "kris-anderson/netperf" # netperf-enable-demo
      "stablyai/orca" # orca
    ];

    # Exceptions checked against nixpkgs: httping and nexttrace are unavailable
    # on Darwin, mole is a different tool in nixpkgs, peekaboo has no
    # package, and hunk is not in nixpkgs.  netperf-enable-demo follows flent's documented macOS install
    # (https://flent.org/intro.html#installing-flent).
    brews = [
      "httping"
      "hunk"
      "mole"
      "netperf-enable-demo"
      "nexttrace"
      "peekaboo"
    ];

    casks = [
      # browsers
      "brave-browser"
      "google-chrome"

      # editors and terminals
      "kitty"
      "markedit"
      "stablyai/orca/orca"

      # input methods and text
      "atext"
      "squirrel-app"

      # window and input management
      "alt-tab"
      "bettertouchtool"
      "hammerspoon"
      "karabiner-elements"
      "macgesture"

      # security and privacy
      "lulu"
      "oversight"

      # system utilities
      "appcleaner"
      "sensei"
      "sloth"
      "tmpdisk"
    ];
  };
}
