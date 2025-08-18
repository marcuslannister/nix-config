# common-darwin.nix
{ config, pkgs, ... }:

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
  nixpkgs.overlays = [
    (final: prev:
      {
        bitwarden-cli = prev.bitwarden-cli.overrideAttrs (oldAttrs:
          { nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.llvmPackages_18.stdenv.cc ];
            stdenv = prev.llvmPackages_18.stdenv;
          });
      })
  ];

  # Environment packages
  environment.systemPackages = with pkgs; [
    # base
    vim
    git
    python3
    ruby # for ~/.scm_breeze/install.sh
    jujutsu

    # utils
    eza # A modern replacement for ‘ls’
    ripgrep # recursively searches directories for a regex pattern
    tmux

    # files
    duf
    dust
    fzf
    fd

    # misc
    zoxide
    delta
    bitwarden-cli

    # network
    iperf3
    croc
    axel

    # document
    pandoc
    tectonic
    # pdflatex
  ];

  # User configuration for Darwin
  users.users.ken = {
    name = "ken";
    home = "/Users/ken";
    shell = pkgs.zsh;
  };
}
