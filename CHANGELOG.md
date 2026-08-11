# Changelog

## Unreleased

- Deploy the tracked TTY7 configuration through Home Manager.
- Copy the Homebrew-built Emacs and Emacs Client app bundles into `/Applications` after Homebrew Bundle runs, through `scripts/sync-emacs-apps.sh`. The script fingerprints the keg bundles and copies only after a new emacs-plus build, so a routine `darwin-rebuild switch` costs two stat calls.
- Install the xterm-ghostty terminfo entry into `~/.terminfo` on every managed host, so ssh sessions from Ghostty no longer fail with "can't find terminal definition for xterm-ghostty".
- Give every Darwin host `emacs-plus@31`, ARM and Intel alike: the homebrew block moved out of the `macbook-pro-m1` entry into a shared `emacsModule` that `mkDarwinConfig` adds to every configuration. nix-darwin picks the right `brewPrefix` per platform on its own (`/opt/homebrew/bin` on aarch64, `/usr/local/bin` on Intel) and skips activation with an error, rather than failing the switch, on a Mac with no Homebrew.
- Resolve `unstable` to nixpkgs-darwin 25.05 on x86_64-darwin, since nixpkgs 26.11 dropped that platform and importing it throws at evaluation time, which had made the macbook-pro-2015-intel configuration unevaluable. On Intel only, `gcc15`, `zellij` and `syncthing` now come from 25.05 at older versions; aarch64-darwin still tracks unstable.
- Manage Emacs declaratively on macbook-pro-m1: split it out of the shared `macMiniConfig` and enable the nix-darwin `homebrew` module with the `d12frosted/emacs-plus` tap and `emacs-plus@31 --with-xwidgets`, replacing the hand-placed Emacs.app 31.0.50 with a Homebrew-built 31.0.91. `upgrade = false` keeps an unrelated `darwin-rebuild switch` from turning into a 30-minute source build, and `cleanup = "none"` protects the 139 formulae and 78 casks already installed by hand that the Brewfile does not describe.
- Leave `~/.homebrew/trust.json` to a hand-made symlink: managing it from activation needed a `sudo` call before `brew bundle`, which is more machinery than a one-time `ln -s` deserves.
- Select the `dragon-plus` Emacs icon through `~/.config/emacs-plus/build.yml`, deployed by home-manager, since emacs-plus exposes no formula option for icons. Homebrew activation runs before home-manager, so a first-ever install needs the file pre-seeded or a follow-up `brew postinstall emacs-plus@31`.
- Set `system.primaryUser`, the default that `homebrew.user` reads; enabling the homebrew module without it fails evaluation.
- Keep `unstable.gcc15` but correct its rationale: Emacs native compilation no longer depends on it now that `emacs-plus@31` pulls Homebrew `gcc`/`libgccjit` 16.1.0 in as hard dependencies, verified by native-compiling under `emacs -Q`. The earlier claim below that it matched "the libgccjit 15.2.0 bundled in Emacs.app" was wrong: that bundled dylib reports current version 26.0.26.
- Move Darwin from `gcc` (14.3.0) to `unstable.gcc15` (15.2.0) so the runtime archives Emacs.app native compilation links against match the libgccjit 15.2.0 bundled in Emacs.app; this also replaces the Homebrew `gcc`/`libgccjit` formulae, now uninstalled. Taken from unstable because 25.05's `gcc15` is 15.1.0 and fails to bootstrap on aarch64-darwin, its libgcc re-exporting `___register_frame_table` and other symbols the linker cannot resolve.
- Ignore .codegraph so its daemon socket no longer breaks flake evaluation on a dirty tree.
- Fix the scmpuff v0.7.0 build with Go 1.26 and its required test dependencies.
- Add scmpuff v0.7.0, pinned via a local buildGoModule package since nixpkgs only ships 0.5.0/0.6.0, scoped to mac-mini-m1 only.
- Deploy Karabiner modifier-chord fixes and complex-modification assets from dotfiles.
- Deploy FZF Ctrl-R history search to remote Zsh sessions.
- Deploy Smart Tabs labels without program names from dotfiles.
- Install Smart Tabs v0.2.4 as a Nix-managed local Zellij plugin.
- Deploy engineering-agent repository conventions from dotfiles.
- Deploy corrected Zellij and Kitty ANSI palettes from dotfiles.
- Install zjstatus from a pinned Nix flake and deploy the unlocked Zellij startup mode from dotfiles.
- Update Zellij to 0.44.3 on Darwin.
- Disable zjstatus single-pane frame toggling to prevent persistent redraw flicker.
- Replace hardcoded personal username with dynamic $USER detection across system, Darwin, and home-manager configs.
- Rename flake output and Darwin hostname keys to drop personal name, genericize SSH key comment, and remove dead nix95 config block.
- Resolve the dynamic username via SUDO_USER when invoked through sudo, since darwin-rebuild/nixos-rebuild reset $USER to root even with `sudo -E`.
