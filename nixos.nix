{ config, pkgs, ... }:

{
  # NixOS-specific options
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware config etc.
  # fileSystems."/" = { ... };
  # swapDevices = [ ... ];
}
