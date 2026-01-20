# common-darwin.nix
{ config, pkgs, unstable, ... }:

{
  # Darwin-specific configuration
  system.stateVersion = 6;

  # Nix configuration
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" "ken" ];
  };

  # Enable programs
  programs.zsh = {
    enable = true;
    enableCompletion = false; # <--- disables the default compinit
    # You can still use shellInit or other options as needed
  };

  # fixme: patch from https://github.com/NixOS/nixpkgs/issues/339576#issuecomment-2574076670
  # nixpkgs.overlays = [
  #   (final: prev:
  #     {
  #       bitwarden-cli = prev.bitwarden-cli.overrideAttrs (oldAttrs:
  #         { nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.llvmPackages_18.stdenv.cc ];
  #           stdenv = prev.llvmPackages_18.stdenv;
  #         });
  #     })
  # ];

  nixpkgs.config.allowUnfree = true;

  # Environment packages
  environment.systemPackages = with pkgs; [
    # base
    vim
    git
    python3
    ruby # for ~/.scm_breeze/install.sh
    # jujutsu
    nodejs_24

    # utils
    eza # A modern replacement for ‘ls’
    ripgrep # recursively searches directories for a regex pattern
    tmux
    zellij
    ncdu

    # files
    duf
    dust
    fzf
    fd

    # misc
    zoxide
    delta
    # bitwarden-cli

    # network
    iperf3
    croc
    axel

    # document
    pandoc
    tectonic
    # pdflatex
    # aspell
    # aspellDicts.en
    (aspellWithDicts (dicts: with dicts; [en en-computers en-science]))

    # cmake
    # unstable.syncthing

    # docker
    docker-compose

  ];

  # # 1. Enable the Syncthing service for the system
  # services.syncthing = {
  #   enable = true;
  #   # # IMPORTANT: Specify your macOS username here
  #   # user = "ken";
  #   # # Optional: Specify the group, defaults to 'staff' which is usually correct
  #   # group = "staff";
  #   # # Optional: Specify where Syncthing stores its data and configuration
  #   # dataDir = "/Users/ken/Library/Application Support/Syncthing";
  #   # configDir = "/Users/ken/Library/Application Support/Syncthing";
  # };

  # User configuration for Darwin
  users.users.ken = {
    name = "ken";
    home = "/Users/ken";
    shell = pkgs.zsh;
  };
}
