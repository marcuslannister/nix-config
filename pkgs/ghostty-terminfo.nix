{ lib, runCommand, ncurses }:

# Compiles the vendored xterm-ghostty entry so that ssh'ing into a machine from
# a Ghostty terminal doesn't fail with "can't find terminal definition for
# xterm-ghostty". nixpkgs' `ghostty.terminfo` is a split output of the ghostty
# package, which is linux-only, so it can't be reused on darwin.
runCommand "ghostty-terminfo"
{
  nativeBuildInputs = [ ncurses ];

  meta = {
    description = "xterm-ghostty terminfo entry, compiled from a vendored source";
    homepage = "https://ghostty.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
} ''
  mkdir -p "$out/share/terminfo"
  tic -x -o "$out/share/terminfo" ${./xterm-ghostty.terminfo}
  test -n "$(find "$out/share/terminfo" -name xterm-ghostty)"
''
