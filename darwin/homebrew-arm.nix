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
      "tw93/tap"                # kakuku
    ];

    casks = [
      # browsers
      "brave-browser"
      "google-chrome"
      "microsoft-edge"

      # editors and terminals
      "kitty"
      "markedit"
      "visual-studio-code"
      "zed"

      # input methods and text
      "atext"
      "cc-switch"
      "input-source-pro"
      "keyboardholder"
      "switchkey"

      # window and input management
      "alt-tab"
      "bettertouchtool"
      "hammerspoon"
      "jordanbaird-ice"
      "karabiner-elements"
      "macgesture"
      "raycast"

      # display and screen
      "betterdisplay"
      "shottr"

      # media
      "iina"
      "openemu"
      "spotify"
      "tidal"
      "vlc"
      "yacreader"

      # network and remote
      "clashx"
      "moonlight"
      "rustdesk"
      "tunnelbear"
      "winbox"

      # security and privacy
      "lulu"
      "oversight"

      # notes, reading and reference
      "anki"
      "logseq"
      "netnewswire"
      "numi"
      "scapple"

      # system utilities
      "apparency"
      "appcleaner"
      "imazing"
      "istat-menus"
      "opencore-patcher"
      "sensei"
      "sloth"
      "tmpdisk"

      # misc tools
      "kakuku"
      "lm-studio"
      "macgpt"
      "microsoft-auto-update"
      "via"
    ];
  };
}
