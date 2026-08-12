# darwin/homebrew-arm.nix
#
# The casks installed on all three ARM Macs.  Anything only some of them carry
# stays in that host's own file, so adopting this module installs nothing and
# removes nothing -- it describes what is already true.
#
# Deliberately not in darwin/homebrew.nix: that module reaches every Darwin
# host, including `default` and the Intel Mac, and neither should acquire one
# group's application list.
{ ... }:

{
  homebrew = {
    taps = [
      "farion1231/ccswitch"     # cc-switch
    ];

    casks = [
      # browsers
      "brave-browser"
      "google-chrome"

      # editors and terminals
      "kitty"
      "markedit"
      "visual-studio-code"

      # input methods and text
      "atext"
      "cc-switch"
      "keyboardholder"

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
      "yacreader"

      # network and remote
      "winbox"

      # security and privacy
      "lulu"
      "oversight"

      # system utilities
      "apparency"
      "appcleaner"
      "opencore-patcher"
      "sensei"
      "sloth"
      "tmpdisk"

      # misc tools
      "lm-studio"
    ];
  };
}
