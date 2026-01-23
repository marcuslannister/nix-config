{ config, pkgs, ... }:

{
  system.stateVersion = "25.05";

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Zsh and Git configuration management
  programs.zsh = {
    enable = true;
    enableCompletion = false; # <--- disables the default compinit
    # You can still use shellInit or other options as needed
  };
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    # base
    vim
    git

    # utils
    eza # A modern replacement for ‘ls’
    ripgrep # recursively searches directories for a regex pattern
    zellij
    ncdu

    # misc
    zoxide
    delta
  ];

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PasswordAuthentication = false;
  };

  networking.firewall.enable = false;

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUG5mr3pQev5rbwYR6P319kX0nf1LBteKQ0WfgYDTCOCdL/UYuhwNGVji8D/9jdnUbgz7qS0ESIPssN97Hk/X2xkps0daro8oOZxvuPaQ2D+heDsukEyy3ZS2sh8gwy5m9fn0M3O1uSkOW2RS9ERA4akXioirtMGRaXHlUelBon+6ZEir63Uf6MjfZvPRpXnnSEbgtuh6Xs/ljYIZdwTfUSL2RR32lrQxo41CnNaB4V9dVED8fW1h/aUDo6uVn6Ct5zsYcmLylEsFNDqy6OD12Qb7iVfDwvJfSi/OfTo3P3cbVVVBpIkLjTAdycKOrw7L6Ac1VMqBORaJ2YRxj3AM0IFOpiGSPJffSJ16D201Sm9SHngcAo2RkYwB9/kTw2idjHtRTzDouAA96ww2zGQR2XP6YqLnehF+i8jMDfP8tyAVZKFEpgRDOwKo9TNpozgbvX3HdqN1L/vdDdF+mdKaHJ/rEyHHc3AOaMplxM5VMj1R1+GF88XsJeEiRKKcihu0iJQsbOiVs9vBHW6EFh4n0z4XCDE2XbuH50feT7rjf/Wk+jpjyt+FJoUhASzuRl2QiCtwiQ9dRgG2XmQ0NhNZjHSKP3UMeFCeQX5X98OjvRl7SwRD/wyg9D5sMx74tIhfiFEEOQJX1GWXirHwdsiqL/Yy5Ijlhn/1pdHHLIZQxYw== ken@iMac"

  ];

  users.users.ken = {
    isNormalUser = true;
    home = "/home/ken";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # replace with your own public key
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUG5mr3pQev5rbwYR6P319kX0nf1LBteKQ0WfgYDTCOCdL/UYuhwNGVji8D/9jdnUbgz7qS0ESIPssN97Hk/X2xkps0daro8oOZxvuPaQ2D+heDsukEyy3ZS2sh8gwy5m9fn0M3O1uSkOW2RS9ERA4akXioirtMGRaXHlUelBon+6ZEir63Uf6MjfZvPRpXnnSEbgtuh6Xs/ljYIZdwTfUSL2RR32lrQxo41CnNaB4V9dVED8fW1h/aUDo6uVn6Ct5zsYcmLylEsFNDqy6OD12Qb7iVfDwvJfSi/OfTo3P3cbVVVBpIkLjTAdycKOrw7L6Ac1VMqBORaJ2YRxj3AM0IFOpiGSPJffSJ16D201Sm9SHngcAo2RkYwB9/kTw2idjHtRTzDouAA96ww2zGQR2XP6YqLnehF+i8jMDfP8tyAVZKFEpgRDOwKo9TNpozgbvX3HdqN1L/vdDdF+mdKaHJ/rEyHHc3AOaMplxM5VMj1R1+GF88XsJeEiRKKcihu0iJQsbOiVs9vBHW6EFh4n0z4XCDE2XbuH50feT7rjf/Wk+jpjyt+FJoUhASzuRl2QiCtwiQ9dRgG2XmQ0NhNZjHSKP3UMeFCeQX5X98OjvRl7SwRD/wyg9D5sMx74tIhfiFEEOQJX1GWXirHwdsiqL/Yy5Ijlhn/1pdHHLIZQxYw== ken@iMac"
    ];
    shell = pkgs.zsh;
  };
}
