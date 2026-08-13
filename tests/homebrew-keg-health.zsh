#!/usr/bin/env zsh

# Fails when the install receipts under `$(brew --prefix)/Cellar` describe a
# dependency graph that cannot be true, so that `tests/homebrew-drift.zsh` is
# never asked to walk one.
#
# The drift test reads each keg's `runtime_dependencies` to decide which
# formulae are dependencies of a Declared Leaf and which are Adopted (see
# CONTEXT.md).  Those lists are written once, at build time, and Homebrew never
# revises them.  A tab therefore drifts away from the formula it came from, and
# the drift test inherits the error without any sign:
#
#   a tab that names too much  widens the closure and hides an Adopted formula
#   a tab that names too little narrows it and invents one
#
# Both were live here on 2026-08-12.  An installed webp 1.6.0 tab named libtiff
# while homebrew/core webp named only giflib, jpeg-turbo and libpng, and libtiff
# names webp, so the two closed a loop.  Homebrew reported it as "circular
# dependency: libtiff, webp" on unrelated commands for as long as it lasted.
#
# The checks read the disk alone.  They ask Homebrew nothing, so an untrusted
# tap cannot blank an answer the way it blanks `brew deps` and `brew leaves`,
# and they need no network.
#
#   cycle     a real dependency graph is acyclic, so any loop is a stale tab
#   dangling  a tab naming a formula with no keg means the closure walk stops
#             short of dependencies that are genuinely installed
#
# Extra kegs are reported but do not fail: Homebrew leaves them until
# `brew cleanup`, and the drift test now reads the linked keg, not whichever
# one the glob returned first.

set -eu

prefix=$(brew --prefix)

python3 - "$prefix" <<'PY'
import json, os, sys

prefix = sys.argv[1]
cellar = os.path.join(prefix, 'Cellar')

def versions(name):
    path = os.path.join(cellar, name)
    return sorted(v for v in os.listdir(path) if not v.startswith('.'))

def receipt(name):
    # Same rule as the drift test: the linked keg describes what is in use.
    paths = []
    linked = os.path.join(prefix, 'opt', name)
    if os.path.exists(linked):
        paths.append(os.path.join(os.path.realpath(linked), 'INSTALL_RECEIPT.json'))
    paths += [os.path.join(cellar, name, v, 'INSTALL_RECEIPT.json')
              for v in versions(name)]
    for path in paths:
        try:
            with open(path) as handle:
                return json.load(handle)
        except (OSError, ValueError):
            continue
    return None

installed = sorted(name for name in os.listdir(cellar)
                   if not name.startswith('.')
                   and os.path.isdir(os.path.join(cellar, name)))
have = set(installed)

deps = {}
for name in installed:
    data = receipt(name)
    named = {(dep.get('full_name') or '').split('/')[-1]
             for dep in (data.get('runtime_dependencies') or [])} if data else set()
    deps[name] = sorted(named - {''})

dangling = {name: [d for d in named if d not in have]
            for name, named in deps.items()}
dangling = {name: missing for name, missing in dangling.items() if missing}

# Depth-first search over the installed graph.  A grey node reached a second
# time closes a loop, and the slice of the current path from that node is it.
cycles, colour, path = [], {}, []
def visit(name):
    colour[name] = 'grey'
    path.append(name)
    for dep in deps.get(name, ()):
        if dep not in have:
            continue
        if colour.get(dep) is None:
            visit(dep)
        elif colour[dep] == 'grey':
            cycles.append(path[path.index(dep):])
    path.pop()
    colour[name] = 'black'

for name in installed:
    if colour.get(name) is None:
        visit(name)

seen, unique = set(), []
for cycle in cycles:
    key = frozenset(cycle)
    if key not in seen:
        seen.add(key)
        unique.append(cycle)

extra = {name: versions(name) for name in installed if len(versions(name)) > 1}
if extra:
    print(f'{len(extra)} formulae keep an older keg, cleared by `brew cleanup`:')
    for name, found in sorted(extra.items()):
        print(f'  {name}: {" ".join(found)}')

faults = 0
for cycle in unique:
    print('stale tab, circular dependency: '
          + ' -> '.join(cycle + [cycle[0]]), file=sys.stderr)
    faults += 1
for name, missing in sorted(dangling.items()):
    print(f'stale tab, {name} names uninstalled {" ".join(missing)}',
          file=sys.stderr)
    faults += 1

if faults:
    print(f'\nRepair each named formula, then run this test again:',
          file=sys.stderr)
    print('  brew uninstall --ignore-dependencies --force <names>'
          ' && brew install <names>', file=sys.stderr)
    sys.exit(1)

print(f'{len(installed)} kegs, no cycle and no dangling dependency')
PY
