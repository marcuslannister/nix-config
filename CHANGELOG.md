# Changelog

## Unreleased

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
