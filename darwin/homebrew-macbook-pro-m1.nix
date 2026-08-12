# darwin/homebrew-macbook-pro-m1.nix
#
# Everything Homebrew holds on macbook-pro-m1 beyond the shared Emacs install.
#
# This is a per-host file rather than the shared ARM list on purpose: it was
# built from this laptop's state alone, and mac-mini-m4 and mac-mini-m1 have
# not been inventoried yet.  Promoting it to the shared module before then
# would install 61 casks on machines nobody has looked at.  Once those two are
# inventoried, whatever all three agree on moves up into darwin/homebrew.nix.
{ ... }:

{
  homebrew = {
    taps = [
      "barrybarrywu/tap"        # tutti
      "daipeihust/tap"          # im-select
      "darrylmorley/whatcable"  # whatcable-cli
      "farion1231/ccswitch"     # cc-switch
      "hakky54/crip"            # crip
      "lance0/tap"              # ttl
      "pouriyajamshidi/tap"     # tcping
      "supercmdlabs/supercmd"   # supercmd
      "tw93/tap"                # kakuku
    ];

    # Exceptions, every one verified against nixpkgs 25.05 on 2026-08-11:
    # httping and nexttrace are Linux-only (meta.platforms excludes darwin);
    # crip is Linux-only; nixpkgs `mole` is an unrelated SSH tunnel tool, not
    # this Mac cleanup utility; im-select, tcping, ttl and whatcable-cli have
    # no nixpkgs package at all.
    brews = [
      "crip"
      "httping"
      "im-select"
      "mole"
      "nexttrace"
      "tcping"
      "ttl"
      "whatcable-cli"
    ];

    casks = [
      # browsers
      "brave-browser"
      "google-chrome"
      "microsoft-edge"

      # editors, terminals and dev
      "kitty"
      "markedit"
      "visual-studio-code"
      "zed"

      # input methods and text
      "atext"
      "cc-switch"
      "input-source-pro"
      "keyboardholder"
      "squirrel-app"
      "switchkey"

      # window and input management
      "alt-tab"
      "bettertouchtool"
      "hammerspoon"
      "jordanbaird-ice"
      "karabiner-elements"
      "macgesture"
      "raycast"
      "supercmd"

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
      "electrum"
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
      "thaw"
      "tmpdisk"

      # misc tools
      "kakuku"
      "lm-studio"
      "macgpt"
      "microsoft-auto-update"
      "tutti"
      "via"
    ];
  };
}
