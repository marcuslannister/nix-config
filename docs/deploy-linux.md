# Deploy a Linux node

The deploy-rs nodes in `flake.nix` (`vm97`, `vm98`, `ycy`, `surface-pro-7-plus`) run standalone Home Manager. Deploy from a Mac:

```sh
nix develop --impure -c deploy .#<node> -- --impure
```

`remoteBuild = true`, so the node builds its own profile. deploy-rs then activates it and waits for confirmation (`confirmTimeout = 300`, because `home.nix` runs `npm install -g` on every activation).

## When a deploy fails

- **`Existing file '…' would be clobbered`**: the node has a plain file where the profile now puts a link. Compare it with the dotfiles version, move it to `<file>.backup`, and deploy again.
- **Confirmation arrives before the activation waits, then rollback** (`Deployment confirmed` precedes `Waiting for confirmation event`): a stale `/tmp/deploy-rs-canary-*` from a cancelled deploy is on the node. Remove it and deploy again.
- **`Connection … closed by remote host` during the build**: a proxy on the path cuts long SSH sessions (seen with `ycy`). Build on the node first, so that the deploy only activates:

  ```sh
  drv=$(nix eval --raw --impure .#deploy.nodes.<node>.profiles.home.path.drvPath)
  NIX_SSHOPTS="-p <port>" nix copy --derivation --to ssh-ng://<user>@<node> "$drv"
  ssh <node> "sudo systemd-run --uid=\$USER --unit=hm-build --collect /nix/var/nix/profiles/default/bin/nix-store --realise $drv"
  ```

  The system unit survives the SSH session; `--uid` keeps it from creating root-owned files in the user's home, which break activation. Poll with `ssh <node> systemctl is-active hm-build`, then deploy.
- **`getting status of "/nix/store/derivations"`**: the `deploy-rs` input is older than the Nix on this Mac (serokell/deploy-rs#355). Run `nix flake update deploy-rs`.

## Checks

`checks` exist for x86_64-linux only. On a Mac, `nix flake check --impure` evaluates every output and skips them; CI (`.github/workflows/check.yml`) evaluates on Linux and builds the deploy-rs schema check.
