# darwin/homebrew-macbook-pro-m1.nix
#
# What macbook-pro-m1 holds beyond darwin/homebrew.nix and the shared ARM list
# in darwin/homebrew-arm.nix: the Exceptions, the taps that serve them, and the
# five casks the two Mac minis do not have.
{ ... }:

{
  homebrew = {
    taps = [
      "barrybarrywu/tap"        # tutti
      "daipeihust/tap"          # im-select
      "darrylmorley/whatcable"  # whatcable-cli
      "hakky54/crip"            # crip
      "lance0/tap"              # ttl
      "pouriyajamshidi/tap"     # tcping
      "supercmdlabs/supercmd"   # supercmd
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
      "electrum"
      "squirrel-app"
      "supercmd"
      "thaw"
      "tutti"
    ];
  };
}
