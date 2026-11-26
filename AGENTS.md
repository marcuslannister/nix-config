# Agent instructions

## Deploy

Apply the configuration to this Mac:

```sh
scripts/darwin-switch.sh
```

- The script runs `sudo darwin-rebuild switch --flake . --impure`. An agent that types `sudo` itself stops at the Claude Code ask rule `Bash(sudo:*)`; the script does not. On mac-mini-m1 and mac-mini-m4, `rebuildSudoModule` in `flake.nix` lets it run without a password.
- `--impure` is required: `flake.nix` reads the account name from `SUDO_USER` (or `USER`) at evaluation time.
- To check a change without applying it, run `darwin-rebuild build --flake . --impure` (no `sudo`).
- Deploy a Linux node, or fix a failed deploy: read `docs/deploy-linux.md`.

## Dotfiles

The `dotfiles` flake input pins `github:marcuslannister/dotfiles`. A change to a file in `~/dotfiles`, or to a link into it, lands in this order:

1. Ship the change in `~/dotfiles`: commit, push, pull.
2. Here, run `nix flake update dotfiles`.
3. Run `darwin-rebuild build --flake . --impure` to check the change.
4. Ship the `flake.lock` change.
5. Deploy.

The pushed `flake.lock` must pin the pushed dotfiles commit before you deploy.
