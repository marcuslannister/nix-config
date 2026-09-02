# darwin/homebrew-mac-mini-m1.nix
#
# What mac-mini-m1 holds beyond darwin/homebrew.nix and the shared ARM list in
# darwin/homebrew-arm.nix: its Exceptions, the taps that serve them and its
# casks.  This machine's Homebrew state is now completely Declared.
#
# Its 115 Leaves were read from the install receipts under /opt/homebrew/Cellar
# on 2026-08-12.  65 were already in environment.systemPackages, 9 stayed
# Declared on Homebrew as Exceptions, 18 were dropped outright, and the
# remaining 23 turned out to be dependencies that `installed_on_request` had
# wrongly flagged as Leaves.  Nothing moved into environment.systemPackages:
# every Leaf worth keeping was already there.
#
# The 20 casks this machine carried undeclared are all gone rather than added:
# 10 of its 15 font casks are supplied by fonts.packages in common-darwin.nix
# and the other 5 followed macbook-pro-m1's, and git-credential-manager with
# its -core phantom, switchresx, wezterm and fliqlo were dropped.  So the cask
# list below is unchanged.
#
# One Caskroom record is a retired cask token kept as a symlink beside the live
# one -- squirrel -> squirrel-app.  Only the live token is Declared.  Never
# remove the stale record with `brew uninstall --cask squirrel`: Homebrew
# resolves the alias and deletes the live cask instead.  Remove it by path.
# /opt/homebrew/Cellar has three of the same shape -- rustup-init -> rustup,
# python-cryptography -> cryptography and python-certifi -> certifi.
#
# This Mac is the one whose /opt/homebrew was owned by a second account rather
# than by the user activation runs as, which left `brew` unable to read its own
# git repository ("dubious ownership"), unable to report its version and unable
# to update.  It was chowned to the primary user on 2026-08-12.  If a later
# switch fails inside `brew bundle` with a Cask "definition is invalid" error,
# suspect an out-of-date Homebrew before suspecting the cask.
#
# Before this machine's first switch with this module, its taps must be in
# ~/.homebrew/trust.json; see the note in darwin/homebrew-mac-mini-m4.nix.
{ ... }:

{
  homebrew = {
    taps = [
      "daipeihust/tap" # im-select
      "darrylmorley/whatcable" # whatcable-cli
      "lance0/tap" # ttl
      "steipete/tap" # peekaboo
    ];

    # Exceptions, every one checked against this flake's nixpkgs with
    # meta.available on 2026-08-12, on x86_64-darwin as well as aarch64-darwin:
    # im-select, peekaboo, ttl and whatcable-cli have no package at all.
    # httping, mole, nexttrace and tcping promoted to darwin/homebrew-arm.nix
    # on 2026-08-15 -- all three ARM Macs carried them.
    #
    # Unlike mac-mini-m4, this machine has no syncthing formula and so no
    # Exception of the second kind: the syncthing.plist on disk belongs to the
    # other account, and nothing it names is installed.
    #
    # ttl is qualified with its tap: homebrew/core grew its own unrelated
    # `ttl` formula on 2026-08-31, and `brew bundle` refuses to resolve the
    # bare name once two taps claim it.  crip was dropped on 2026-09-01.
    brews = [
      "im-select"
      "peekaboo"
      "lance0/tap/ttl"
      "whatcable-cli"
    ];

    casks = [
      # shared with mac-mini-m4 only
      "amethyst"
      "android-platform-tools"
      "fontbase"
      "forklift"
      "orion"

      # this machine only.  squirrel-app is the input method, Declared under
      # the current token; the retired `squirrel` record is dropped by path,
      # never by `brew uninstall`.
      "docker-desktop"
      "electrum"
      "openusage"
    ];
  };
}
