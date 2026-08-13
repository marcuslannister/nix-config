#!/usr/bin/env zsh

# Fails when this Mac holds Homebrew packages the flake does not Declare, or
# Declares packages the Mac does not hold (see CONTEXT.md for both terms).
#
# The configuration is the complete description of Homebrew, but activation
# does not enforce it -- `homebrew.onActivation.cleanup` stays "none" because
# Homebrew 6 needs `--force-cleanup` to act on it, and that also resets the
# global trust store.  This script is the enforcement instead.
#
# Homebrew's own inventory commands cannot be trusted for this.  Observed on
# 2026-08-11 with Homebrew 6.0.16, all describing the same machine:
#   brew list --formula              66   plain names only
#   brew list --formula --full-name  71   phantoms for kegs already removed
#   brew info --json=v2 --installed  59   drops third-party-tap formulae
#   brew leaves                       4   hides 11 installed CLI formulae
#   /opt/homebrew/Cellar             65   the truth
# So the disk is the source, and each keg names its own tap in
# INSTALL_RECEIPT.json.

set -eu

repo_root=${0:A:h:h}
host=${1:-$(scutil --get LocalHostName)}
prefix=$(brew --prefix)

brewfile=$(nix eval --impure --raw "$repo_root#darwinConfigurations.${host}.config.homebrew.brewfile")

parse() {
  # $1 is the Brewfile keyword; prints one name per line, empty when none.
  print -r -- "$brewfile" | rg -o "^$1 \"([^\"]+)\"" -r '$1' || true
}

declared_taps=(${(@f)"$(parse tap)"})
declared_brews=(${(@f)"$(parse brew)"})
declared_casks=(${(@f)"$(parse cask)"})

installed_formulae=()
for d in $prefix/Cellar/*(N/); do
  [[ ${d:t} == .* ]] || installed_formulae+=(${d:t})
done

installed_casks=()
for d in $prefix/Caskroom/*(N/); do
  [[ ${d:t} == .* ]] || installed_casks+=(${d:t})
done

installed_taps=()
for d in $prefix/Library/Taps/*/homebrew-*(N/); do
  installed_taps+=("${d:h:t}/${${d:t}#homebrew-}")
done

# A dependency of a Declared formula is not drift.  Only Leaves are Declared,
# so everything brew pulled in underneath them is expected to be on disk.
declared_leaves=()
for b in $declared_brews; do declared_leaves+=(${b:t}); done

# The closure comes from the receipts, not from `brew deps`, for two reasons.
# `brew deps` refuses any formula whose tap is missing from Homebrew's trust
# store, and one refusal blanks a whole batch.  It also answers from the
# current formula definition rather than from what is installed, so it misses
# runtime dependencies that are genuinely on disk -- libomp, openssl@4 and
# readline all went unreported here.  Each keg lists its own.
dependencies=(${(@f)"$(python3 - $prefix $declared_leaves <<'PY'
import json, sys, glob, os
prefix, leaves = sys.argv[1], sys.argv[2:]
def receipt(name):
    # A formula keeps its older kegs on disk until `brew cleanup` runs, and each
    # keg's tab names the dependencies of that build alone.  Six formulae are in
    # that state here, and libtiff was one: its 4.7.1_1 tab named four
    # dependencies and its 4.7.2 tab named seven.  Glob order chose between them,
    # so the closure below -- and with it the Adopted verdict -- depended on how
    # the directory happened to be laid out.  `$prefix/opt/<name>` is the keg
    # Homebrew has linked, so its tab is the one that describes what this Mac
    # uses.  Newest tab first as a fallback, for a formula with no opt link.
    paths = []
    linked = os.path.join(prefix, 'opt', name)
    if os.path.exists(linked):
        paths.append(os.path.join(os.path.realpath(linked), 'INSTALL_RECEIPT.json'))
    paths += sorted(glob.glob(f'{prefix}/Cellar/{name}/*/INSTALL_RECEIPT.json'),
                    key=os.path.getmtime, reverse=True)
    for path in paths:
        try:
            with open(path) as handle:
                return json.load(handle)
        except (OSError, ValueError):
            continue  # a damaged tab must not hide the kegs behind it
    return None
seen, queue = set(), list(leaves)
while queue:
    name = queue.pop()
    data = receipt(name)
    if not data:
        continue
    for dep in data.get('runtime_dependencies') or []:
        dep = (dep.get('full_name') or '').split('/')[-1]
        if dep and dep not in seen:
            seen.add(dep)
            queue.append(dep)
print('\n'.join(sorted(seen)))
PY
)"})

missing_from() {
  # Prints the members of $2.. that are absent from the array named $1.
  local -A have
  local name
  for name in ${(P)1}; do have[$name]=1; done
  for name in ${@:2}; do (( ${+have[$name]} )) || print -r -- $name; done
}

expected_formulae=($declared_leaves $dependencies)

adopted_formulae=(${(@f)"$(missing_from expected_formulae $installed_formulae)"})
adopted_casks=(${(@f)"$(missing_from declared_casks $installed_casks)"})
adopted_taps=(${(@f)"$(missing_from declared_taps $installed_taps)"})

absent_formulae=(${(@f)"$(missing_from installed_formulae $declared_leaves)"})
absent_casks=(${(@f)"$(missing_from installed_casks $declared_casks)"})
absent_taps=(${(@f)"$(missing_from installed_taps $declared_taps)"})

drift=0
report() {
  local label=$1; shift
  local -a items=($@)
  (( ${#items} )) || return 0
  print -u2 -- "$label: ${items}"
  drift=1
}

report 'installed but not Declared (formulae)' $adopted_formulae
report 'installed but not Declared (casks)' $adopted_casks
report 'installed but not Declared (taps)' $adopted_taps
report 'Declared but not installed (formulae)' $absent_formulae
report 'Declared but not installed (casks)' $absent_casks
report 'Declared but not installed (taps)' $absent_taps

if (( drift )); then
  print -u2 -- "$host has Homebrew drift"
  exit 1
fi

print -- "$host matches its Brewfile: ${#declared_taps} taps, ${#declared_leaves} brews, ${#declared_casks} casks"
