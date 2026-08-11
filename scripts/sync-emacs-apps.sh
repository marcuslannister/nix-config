#!/bin/sh
# Copy the Homebrew-built Emacs bundles into /Applications.
#
# emacs-plus keeps Emacs.app and Emacs Client.app inside its keg, where Finder,
# Spotlight and the Dock do not look.  Copying a bundle costs seconds, so this
# script fingerprints the keg bundles and copies only when the fingerprint
# differs from the last copy -- that is, after a new emacs-plus build.  Every
# other `darwin-rebuild switch` walks 1600 files and stops.
#
# Usage: sync-emacs-apps.sh <keg-prefix>
#   e.g. sync-emacs-apps.sh /opt/homebrew/opt/emacs-plus@31
#
# APPLICATIONS_DIR and STAMP_FILE exist for the test in
# tests/homebrew-emacs-activation.zsh; activation uses the defaults.

set -eu

prefix=${1:?usage: sync-emacs-apps.sh <keg-prefix>}
applications=${APPLICATIONS_DIR:-/Applications}
stamp=${STAMP_FILE:-/var/lib/nix-darwin/emacs-plus-apps.stamp}

# The bundles to copy, as positional parameters: POSIX sh has no arrays, and
# "Emacs Client.app" must survive its space.
shift
set -- 'Emacs.app' 'Emacs Client.app'

# No keg means Homebrew never built emacs-plus on this Mac: nothing to copy.
[ -d "$prefix" ] || exit 0

# The resolved keg path carries the version; the stat of every file catches a
# rebuild of the same version, and a `brew postinstall` that rewrites nothing
# but the icon.
fingerprint() {
  (cd "$prefix" && pwd -P)
  for app in "$@"; do
    [ -d "$prefix/$app" ] || continue
    /usr/bin/find "$prefix/$app" -type f -exec /usr/bin/stat -f '%N %z %m' {} +
  done
}

# A matching stamp only says what was copied last time.  The bundles must also
# still be in /Applications as real directories: a deleted Emacs Client.app, or
# an entry someone replaced with a symlink, has to bring the copy back.
destinations_intact() {
  for app in "$@"; do
    [ -d "$prefix/$app" ] || continue
    [ -d "$applications/$app" ] || return 1
    [ ! -L "$applications/$app" ] || return 1
  done
}

current=$(fingerprint "$@" | /usr/bin/sort)

if [ -r "$stamp" ] &&
   [ "$current" = "$(/bin/cat "$stamp")" ] &&
   destinations_intact "$@"; then
  exit 0
fi

# ditto into a dot-prefixed staging bundle, then swap: a half-copied
# /Applications/Emacs.app would be worse than the old one.
for app in "$@"; do
  [ -d "$prefix/$app" ] || continue
  echo >&2 "Copying $app to $applications..."
  /bin/rm -rf "$applications/.$app.nix-darwin"
  /usr/bin/ditto "$prefix/$app" "$applications/.$app.nix-darwin"
  /bin/rm -rf "$applications/$app"
  /bin/mv "$applications/.$app.nix-darwin" "$applications/$app"
done

# Last, so that a copy that died halfway is retried on the next activation.
/usr/bin/install -d -m 0755 "$(/usr/bin/dirname "$stamp")"
printf '%s\n' "$current" >"$stamp"
