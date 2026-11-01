# darwin/homebrew-macbook-pro-m1.nix
#
# What macbook-pro-m1 holds beyond darwin/homebrew.nix and the shared ARM list
# in darwin/homebrew-arm.nix: the Exceptions, the taps that serve them, and the
# casks the two Mac minis do not have.
{ ... }:

{
  homebrew = {
    taps = [
      "barrybarrywu/tap" # tutti
      "crmne/tap" # spotifast
      "daipeihust/tap" # im-select
      "darrylmorley/whatcable" # whatcable-cli
      "lance0/tap" # ttl
    ];

    # Exceptions, every one verified against nixpkgs 25.05 on 2026-08-11:
    # im-select, ttl and whatcable-cli have no nixpkgs package at all.
    # httping, mole, nexttrace and tcping promoted to darwin/homebrew-arm.nix
    # on 2026-08-15 -- all three ARM Macs carried them.  ttl is qualified with
    # its tap: homebrew/core grew its own unrelated `ttl` formula on
    # 2026-08-31, and `brew bundle` refuses to resolve the bare name once two
    # taps claim it.  crip was dropped on 2026-09-01.
    #
    # syncthing: the second kind of Exception, as on mac-mini-m4.  The
    # hand-made 2021 ~/Library/LaunchAgents/syncthing.plist runs
    # /opt/homebrew/bin/syncthing; until 2026-10-28 that was a hand-copied
    # 1.30.0 binary.  Keep its version equal to pkgs/syncthing.nix (vm14).
    brews = [
      "im-select"
      "lance0/tap/ttl"
      "syncthing"
      "whatcable-cli"
    ];

    casks = [
      "crisp"
      "electrum"
      "spotifast"
      "tutti"
    ];
  };
}
