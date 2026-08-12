# nix-config

Declarative configuration for four Macs, two Debian hosts and one NixOS VM. On
macOS two package managers share the machine: Nix owns everything that is not an
application bundle, and Homebrew owns the application bundles.

## Language

**Declared**:
A package written into the Nix configuration. The configuration is the complete
description of what a machine holds, whether Nix or Homebrew installs it.
_Avoid_: managed, tracked, pinned

**Adopted**:
A package installed by hand that the configuration does not yet describe. Every
Adopted package is either made Declared or removed; none stay Adopted.
_Avoid_: manual, untracked, orphan, legacy

**Leaf**:
A Homebrew formula installed because you asked for it, not because another
formula depends on it. Only Leaves are Declared; dependencies look after
themselves.
_Avoid_: top-level, root formula, direct install

**Exception**:
A command-line tool kept on Homebrew for one of two reasons: nixpkgs has no
package for it, or something outside this repository is bound to its Homebrew
path. An Exception carries a comment saying which reason applies.
_Avoid_: workaround, special case, fallback

**Drift**:
A difference between what a machine holds and what the configuration Declares,
in either direction.
_Avoid_: out of sync, stale, mismatch
