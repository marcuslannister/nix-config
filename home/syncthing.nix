# Syncthing as a Home Manager user service (Linux only: the Macs keep the
# Homebrew formula and its launchd agent, see darwin/homebrew-mac-mini-m4.nix).
# No `settings`: devices and folders stay in Syncthing's own config.xml and
# are managed in the GUI, so syncthing-init only sets the GUI address.
# The host needs `loginctl enable-linger <user>` to run it without a login.
{ pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    package = pkgs.callPackage ../pkgs/syncthing.nix { };
    guiAddress = "0.0.0.0:8384";
  };

  # Debian 10 (vm14, systemd 241): unprivileged user namespaces are blocked,
  # so PrivateUsers fails with 217/USER; and the 2019 @system-service list
  # lacks syscalls of current Go, so the filter kills syncthing with SIGSYS.
  # An empty SystemCallFilter= resets the module's filter.
  systemd.user.services.syncthing.Service = {
    PrivateUsers = lib.mkForce false;
    SystemCallFilter = lib.mkForce "";
  };
}
