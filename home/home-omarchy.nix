# home-omarchy.nix
# Omarchy (Arch + Hyprland) owns the system, the desktop configs and the CLI
# tools it ships (eza, ripgrep, fd, fzf, zoxide, git, docker).  Nix adds only
# what Omarchy lacks.  zsh itself comes from pacman so /etc/shells lists it;
# programs.zsh stays off so it does not write a ~/.zshrc over the dotfiles one.
{ pkgs, ... }:

let
  # nixpkgs' scmpuff, not the v0.7.0 pin: see home-debian.nix.
  scmpuffPkg = pkgs.scmpuff;
in

{
  imports = [ ./home.nix ];

  # GPU drivers for Nix GUI apps (kitty), plus XDG_DATA_DIRS in the systemd
  # user session so xdg-terminal-exec finds Nix's kitty.desktop.  The first
  # switch prints a one-time `sudo .../non-nixos-gpu-setup` to run.
  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # ssh'ing in from kitty leaves TERM=xterm-kitty, which Arch's ncurses lacks.
  # Beside home.nix's xterm-ghostty in ~/.terminfo, which ncurses searches first.
  home.file.".terminfo/x/xterm-kitty".source = "${pkgs.kitty.terminfo}/share/terminfo/x/xterm-kitty";

  home.packages = with pkgs; [
    # kitty from Nix, not pacman, so it matches the Macs' config.
    kitty
    (callPackage ../pkgs/fluent-emoji-flat { })

    scmpuffPkg
    zellij
    nodejs_24

    ncdu
    duf
    dust
    delta

    iperf3
    (callPackage ../pkgs/croc.nix { })
    axel
    speedtest-cli

    pandoc
    tectonic
    (aspellWithDicts (dicts: with dicts; [en en-computers en-science]))
  ];
}
