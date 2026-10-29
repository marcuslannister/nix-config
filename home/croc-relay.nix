# croc relay as a Home Manager user service on vm16 (it replaced the Docker
# container schollz/croc on 2026-10-28).  Default ports 9009-9013 on all
# addresses and the default relay password, as the container had.
# The host needs `loginctl enable-linger <user>` to run it without a login.
{ pkgs, ... }:

{
  systemd.user.services.croc-relay = {
    Unit.Description = "croc relay";
    Service = {
      ExecStart = "${pkgs.callPackage ../pkgs/croc.nix { }}/bin/croc relay";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
