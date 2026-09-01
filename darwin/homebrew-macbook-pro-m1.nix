# darwin/homebrew-macbook-pro-m1.nix
#
# What macbook-pro-m1 holds beyond darwin/homebrew.nix and the shared ARM list
# in darwin/homebrew-arm.nix: the Exceptions, the taps that serve them, and the
# five casks the two Mac minis do not have.
{ ... }:

{
  homebrew = {
    taps = [
      "barrybarrywu/tap" # tutti
      "daipeihust/tap" # im-select
      "darrylmorley/whatcable" # whatcable-cli
      "hakky54/crip" # crip
      "lance0/tap" # ttl
      "supercmdlabs/supercmd" # supercmd
    ];

    # Exceptions, every one verified against nixpkgs 25.05 on 2026-08-11: crip
    # is Linux-only; im-select, ttl and whatcable-cli have no nixpkgs package
    # at all.  httping, mole, nexttrace and tcping promoted to
    # darwin/homebrew-arm.nix on 2026-08-15 -- all three ARM Macs carried them.
    # crip and ttl are qualified with their taps: homebrew/core grew its own
    # unrelated formulae with those names on 2026-08-31, and `brew bundle`
    # refuses to resolve the bare name once two taps claim it.
    brews = [
      "hakky54/crip/crip"
      "im-select"
      "lance0/tap/ttl"
      "whatcable-cli"
    ];

    casks = [
      "electrum"
      "supercmd"
      "tutti"
    ];
  };
}
