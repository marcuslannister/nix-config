#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
flake_ref=$repo_root
sync_script=$repo_root/scripts/sync-emacs-apps.sh

# 1. Activation runs `brew bundle` first, then the app sync, and a failed sync
#    only warns instead of aborting the switch.
for config_name in default macbook-pro-2015-intel; do
  activation=$(nix eval --impure --raw "$flake_ref#darwinConfigurations.${config_name}.config.system.activationScripts.homebrew.text")

  bundle_line=$(print -r -- "$activation" | rg -Fn -- 'brew bundle --file=' | head -1)
  bundle_line=${bundle_line%%:*}
  sync_line=$(print -r -- "$activation" | rg -Fn -- 'sync-emacs-apps.sh' | head -1)
  sync_line=${sync_line%%:*}

  if [[ -z $bundle_line || -z $sync_line ]]; then
    print -u2 -- "$config_name activation misses brew bundle or the app sync"
    exit 1
  fi

  if (( bundle_line >= sync_line )); then
    print -u2 -- "$config_name copies the Emacs apps before Homebrew builds them"
    exit 1
  fi

  if ! print -r -- "$activation" | rg -Fq -- 'warning: could not sync the Emacs app bundles'; then
    print -u2 -- "$config_name lets a failed app sync abort activation"
    exit 1
  fi

  print -- "$config_name runs bundle, then syncs the Emacs apps, and tolerates a failed sync"
done

# 2. The sync copies a fresh build once, then skips until the keg changes.
work=$(mktemp -d)
trap 'rm -rf $work' EXIT

keg=$work/opt/emacs-plus@31
applications=$work/Applications
emacs_app=$keg/Emacs.app
client_app="$keg/Emacs Client.app"
mkdir -p $emacs_app/Contents/{MacOS,Resources} $client_app/Contents/MacOS $applications
print -- 'emacs' >$emacs_app/Contents/MacOS/Emacs
print -- 'icon' >$emacs_app/Contents/Resources/Emacs.icns
print -- 'droplet' >$client_app/Contents/MacOS/droplet
chmod +x $emacs_app/Contents/MacOS/Emacs

run_sync() {
  APPLICATIONS_DIR=$applications STAMP_FILE=$work/stamp \
    /bin/sh $sync_script $keg 2>&1
}

# A sentinel inside the copied bundle is the only honest proof of a skip: any
# real copy wipes the staging bundle and takes the sentinel with it.
sentinel=$applications/Emacs.app/Contents/.sentinel
mark_copy() { touch $sentinel }
copied() { [[ ! -e $sentinel ]] }

run_sync >/dev/null
if [[ ! -x $applications/Emacs.app/Contents/MacOS/Emacs ]]; then
  print -u2 -- 'first sync did not copy Emacs.app'
  exit 1
fi
if [[ $(<$applications/'Emacs Client.app'/Contents/MacOS/droplet) != 'droplet' ]]; then
  print -u2 -- 'first sync did not copy Emacs Client.app'
  exit 1
fi
print -- 'first sync copies both Emacs bundles'

mark_copy
run_sync >/dev/null
if copied; then
  print -u2 -- 'unchanged keg was copied again'
  exit 1
fi
print -- 'unchanged keg skips the copy'

# 3. Drift in /Applications brings the copy back, stamp or no stamp.
rm -rf $applications/'Emacs Client.app'
run_sync >/dev/null
if [[ ! -d $applications/'Emacs Client.app' ]]; then
  print -u2 -- 'a deleted Emacs Client.app was not restored'
  exit 1
fi
print -- 'a deleted bundle is restored'

mark_copy
rm -rf $applications/Emacs.app
ln -s $emacs_app $applications/Emacs.app
run_sync >/dev/null
if [[ -L $applications/Emacs.app ]]; then
  print -u2 -- 'Emacs.app was left as a symlink'
  exit 1
fi
print -- 'a symlinked bundle is replaced by a real copy'

# 4. Both a new executable and an icon-only postinstall count as a new build.
mark_copy
print -- 'emacs rebuilt' >$emacs_app/Contents/MacOS/Emacs
run_sync >/dev/null
if ! copied; then
  print -u2 -- 'a rebuilt executable did not trigger a copy'
  exit 1
fi
if [[ $(<$applications/Emacs.app/Contents/MacOS/Emacs) != 'emacs rebuilt' ]]; then
  print -u2 -- '/Applications still holds the old executable'
  exit 1
fi
print -- 'a rebuilt executable copies again'

mark_copy
print -- 'dragon-plus icon' >$emacs_app/Contents/Resources/Emacs.icns
run_sync >/dev/null
if ! copied; then
  print -u2 -- 'a new icon did not trigger a copy'
  exit 1
fi
print -- 'an icon-only change copies again'

# 5. A Mac without emacs-plus is left alone.
APPLICATIONS_DIR=$applications STAMP_FILE=$work/stamp \
  /bin/sh $sync_script $work/opt/absent
print -- 'missing keg is a no-op'
