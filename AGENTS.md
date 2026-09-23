# Agent instructions

## Deploy

Apply the configuration to this Mac:

```sh
sudo darwin-rebuild switch --flake . --impure
```

- `--impure` is required: `flake.nix` reads the account name from `SUDO_USER` (or `USER`) at evaluation time.
- To check a change without applying it, run `darwin-rebuild build --flake . --impure` (no `sudo`).
