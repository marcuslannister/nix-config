# Syncthing at the version Homebrew gives the Macs, so every device runs the
# same release.  shortcut: nixpkgs (26.05, unstable and master) is still at
# 2.1.3; bump this with each Homebrew upgrade, and drop it once nixpkgs is
# not behind Homebrew.
{ syncthing, fetchFromGitHub }:

syncthing.overrideAttrs (finalAttrs: _: {
  version = "2.1.7";

  src = fetchFromGitHub {
    owner = "syncthing";
    repo = "syncthing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XJqXWzZ0gePbrXeMpCgwXhYN1Lqco16wmEESJDAhFiA=";
  };

  vendorHash = "sha256-gLbRwLPldH4GRuDu8nmZagBfFzg3FZ7Rpa2nDBRWcZo=";
})
