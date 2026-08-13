#!/usr/bin/env python3

"""Print the Homebrew Leaves of this Mac, read from the disk alone.

A Leaf is a formula installed because you asked for it, not because another
formula depends on it (CONTEXT.md).  Only Leaves are Declared, so this is the
list an adoption starts from, and getting it wrong Declares a dependency that
Homebrew would have installed anyway.

Neither of the two obvious sources can produce it.

`brew leaves` under-reports.  It refuses to load a formula from a tap missing
from the trust store, and the refused formulae then vanish from the answer: it
listed 4 on macbook-pro-m1 while 11 third-party command-line formulae had real
kegs and binaries on PATH.

`installed_on_request` in each keg's receipt over-reports.  It records how a
keg was asked for at the time, not what depends on it now, and Homebrew never
revises it.  The mac-mini-m4 audit found 26 formulae carrying a true flag that
were plain dependencies, 13 of them inside emacs-plus@31's own closure.  It
also stays true after a repair: reinstalling libtiff by hand to break a stale
tab set the flag on a formula four other kegs depend on.

So this reads the graph instead.  A keg that no other installed keg names in
its `runtime_dependencies` is a Leaf, whatever either source claims.  It asks
Homebrew nothing, which is what makes it safe to run on a Mac whose taps are
not yet trusted, and it prints each Leaf's tap because Declaring one needs it.

    ./scripts/homebrew-leaves.py [--prefix /opt/homebrew] [--flagged]

`--flagged` prints instead the formulae whose `installed_on_request` disagrees
with the graph, which is the list of traps for that machine.
"""

import argparse
import json
import os
import sys


def versions(cellar, name):
    return sorted(v for v in os.listdir(os.path.join(cellar, name))
                  if not v.startswith('.'))


def receipt(prefix, cellar, name):
    """The linked keg's tab, since older kegs describe older builds."""
    paths = []
    linked = os.path.join(prefix, 'opt', name)
    if os.path.exists(linked):
        paths.append(os.path.join(os.path.realpath(linked), 'INSTALL_RECEIPT.json'))
    paths += [os.path.join(cellar, name, v, 'INSTALL_RECEIPT.json')
              for v in versions(cellar, name)]
    for path in paths:
        try:
            with open(path) as handle:
                return json.load(handle)
        except (OSError, ValueError):
            continue
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prefix', default='/opt/homebrew',
                        help='Homebrew prefix (/usr/local on Intel)')
    parser.add_argument('--flagged', action='store_true',
                        help='print the formulae installed_on_request gets wrong')
    args = parser.parse_args()

    cellar = os.path.join(args.prefix, 'Cellar')
    if not os.path.isdir(cellar):
        sys.exit(f'no Cellar under {args.prefix}')

    installed = sorted(name for name in os.listdir(cellar)
                       if not name.startswith('.')
                       and os.path.isdir(os.path.join(cellar, name)))

    tabs = {name: receipt(args.prefix, cellar, name) for name in installed}

    # Every formula named by any installed keg is a dependency, not a Leaf.
    depended_on = set()
    for data in tabs.values():
        for dep in (data.get('runtime_dependencies') or []) if data else ():
            depended_on.add((dep.get('full_name') or '').split('/')[-1])

    leaves = [name for name in installed if name not in depended_on]

    if args.flagged:
        for name in installed:
            data = tabs[name] or {}
            claimed = bool(data.get('installed_on_request'))
            actual = name not in depended_on
            if claimed != actual:
                verdict = ('claims Leaf, is a dependency' if claimed
                           else 'claims dependency, is a Leaf')
                print(f'{name}\t{verdict}')
        return

    for name in leaves:
        tap = ((tabs[name] or {}).get('source') or {}).get('tap') or 'homebrew/core'
        print(f'{name}\t{tap}')

    wrong = sum(1 for name in installed
                if bool((tabs[name] or {}).get('installed_on_request'))
                != (name not in depended_on))
    print(f'{len(leaves)} Leaves of {len(installed)} kegs; '
          f'installed_on_request disagrees on {wrong}', file=sys.stderr)


if __name__ == '__main__':
    main()
