# SSH forward to CPA (CLIProxyAPI) on oraus1, as a Home Manager user service on vm16.
# CPA listens on 127.0.0.1:8317 on oraus1 only. This service forwards the LAN
# address 192.168.8.16:8317 (not 0.0.0.0) to it, so home clients such as Pi use
# http://192.168.8.16:8317/v1 with their CPA client key.
# The host needs `loginctl enable-linger <user>` to run it without a login.
#
# Not declared here (made by hand on 2026-11-13):
# - the key ~/.ssh/cpa_tunnel_ed25519 (no passphrase);
# - its public half in oraus1's ~/.ssh/authorized_keys with
#   restrict,port-forwarding,permitopen="127.0.0.1:8317",command="/bin/false"
#   (the key can only forward to CPA; it cannot run a command);
# - oraus1's ed25519 host key in ~/.ssh/known_hosts (StrictHostKeyChecking=yes).
# It uses the system ssh, so that vm16 does not fetch openssh from the Nix cache.
{ ... }:

{
  systemd.user.services.cpa-tunnel = {
    Unit = {
      Description = "SSH forward to CPA on oraus1 (192.168.8.16:8317)";
      StartLimitIntervalSec = 0;
    };
    Service = {
      ExecStart = builtins.concatStringsSep " " [
        "/usr/bin/ssh -N -n"
        "-i %h/.ssh/cpa_tunnel_ed25519 -o IdentitiesOnly=yes"
        "-o BatchMode=yes -o StrictHostKeyChecking=yes"
        "-o ExitOnForwardFailure=yes -o ConnectTimeout=15"
        "-o ServerAliveInterval=30 -o ServerAliveCountMax=3"
        "-L 192.168.8.16:8317:127.0.0.1:8317"
        "155.248.192.115"
      ];
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
