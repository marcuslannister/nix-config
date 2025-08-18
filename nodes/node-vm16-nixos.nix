{
  modulesPath,
  config,
  pkgs,
  ...
}: let

  hostname = "vm16-nixos";

in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  boot.isContainer = true;
  networking.hostName = hostname;

  # Supress systemd units that don't work because of LXC.
  # https://blog.xirion.net/posts/nixos-proxmox-lxc/#configurationnix-tweak
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
}
