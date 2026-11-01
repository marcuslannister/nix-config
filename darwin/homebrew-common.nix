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
      "smarzban/tap" # tsk
    ];

    # Exceptions checked against nixpkgs: httping and nexttrace are unavailable
    # on Darwin, mole is a different tool in nixpkgs, peekaboo has no
    # package, and hunk and tsk are not in nixpkgs.  netperf-enable-demo follows flent's documented macOS install
    # (https://flent.org/intro.html#installing-flent).
    #
    # bun is the other kind of Exception: nixpkgs has it, but the Nix build
    # (1.3.13) makes `bun build --compile` binaries that macOS kills at launch
    # (exit 137, checked on mac-mini-m4 and macbook-pro-m1 on 2026-10-31), and
    # herdr.collie compiles its binary with Bun.  The Homebrew bottle is the
    # upstream build.
    brews = [
      "bun"
      "httping"
      "hunk"
      "mole"
      "netperf-enable-demo"
      "nexttrace"
      "peekaboo"
      "smarzban/tap/tsk"
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
