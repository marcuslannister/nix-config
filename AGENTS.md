# Agent instructions

## Deploy

Apply the configuration to this Mac:

```sh
sudo darwin-rebuild switch --flake . --impure
```

- `--impure` is required: `flake.nix` reads the account name from `SUDO_USER` (or `USER`) at evaluation time.
- To check a change without applying it, run `darwin-rebuild build --flake . --impure` (no `sudo`).

## Dotfiles

The `dotfiles` flake input pins `github:marcuslannister/dotfiles`. A change to a file in `~/dotfiles`, or to a link into it, lands in this order:

1. Ship the change in `~/dotfiles`: commit, push, pull.
2. Here, run `nix flake update dotfiles`.
3. Deploy.
4. Ship the `flake.lock` change.

The sequence ends when the pushed `flake.lock` pins the pushed dotfiles commit.
