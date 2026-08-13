#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
fixture_root=$(mktemp -d)
trap 'rm -rf -- "$fixture_root"' EXIT

prefix=$fixture_root/homebrew
mkdir -p "$prefix/opt" "$fixture_root/bin"

formulae=(example-missing example-broken)
for formula in "${formulae[@]}"; do
  mkdir -p "$prefix/Cellar/$formula/1.0"
  print -r -- '{"runtime_dependencies": []}' \
    >"$prefix/Cellar/$formula/1.0/INSTALL_RECEIPT.json"
done
ln -s ../Cellar/example-broken/2.0 "$prefix/opt/example-broken"

cat >"$fixture_root/bin/brew" <<'EOF'
#!/bin/sh
test "$1" = "--prefix" || exit 64
printf '%s\n' "$HOMEBREW_KEG_HEALTH_TEST_PREFIX"
EOF
chmod +x "$fixture_root/bin/brew"

set +e
output=$(PATH="$fixture_root/bin:$PATH" \
  HOMEBREW_KEG_HEALTH_TEST_PREFIX=$prefix \
  /bin/zsh -f "$repo_root/tests/homebrew-keg-health.zsh" 2>&1)
exit_code=$?
set -e

if (( exit_code == 0 )); then
  print -u2 -- 'expected invalid opt links to fail the health check'
  exit 1
fi

print -r -- "$output" | rg -q \
  'unlinked keg, example-missing has no valid .*/opt/example-missing'
print -r -- "$output" | rg -q \
  'unlinked keg, example-broken has no valid .*/opt/example-broken'

print -- 'missing and broken opt links are rejected'
