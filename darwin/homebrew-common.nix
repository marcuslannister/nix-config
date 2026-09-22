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
    ];

    # Exceptions checked against nixpkgs: httping and nexttrace are unavailable
    # on Darwin, mole is a different tool in nixpkgs, and peekaboo has no
    # package.
    brews = [
      "httping"
      "mole"
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
