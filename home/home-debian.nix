# home-debian.nix
{ config, pkgs, inputs, dotfiles, nixpkgs-unstable, ... }:

let
  # nixpkgs' own scmpuff rather than the v0.7.0 pin the ARM Macs run: that pin
  # adds gitMinimal and which as check inputs, which turns on scmpuff's
  # testscript shell-wrapper suite, and those tests eval `scmpuff init -s`
  # whose output shells out to /usr/bin/env -- absent from the Linux build
  # sandbox, so the derivation cannot build here at all.  The Macs build
  # unsandboxed and are unaffected.  Unstable's 0.6.0, not 25.05's 0.5.0,
  # to stay closer to the Macs; both answer to the same `scmpuff exec
  # --relative` that .zshrc uses.
  scmpuffPkg = nixpkgs-unstable.legacyPackages.${pkgs.system}.scmpuff;
in

{
  # Import the base home configuration
  imports = [ ./home.nix ];

  programs.zsh = {
    enable = true;
    enableCompletion = false; # <--- disables the default compinit
    # You can still use shellInit or other options as needed
  };

  # Add specific packages on top of the base ones
  home.packages = with pkgs; [
    # base
    vim
    git
    scmpuffPkg # took SCM Breeze's place, which was ruby's only reason to be here
    # jujutsu
    nodejs_24

    # python
    (python3.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
    ]))


    # utils
    eza # A modern replacement for ‘ls’
    ripgrep # recursively searches directories for a regex pattern
    tmux
    zellij
    ncdu
    bc

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
    speedtest-cli
    openiscsi

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
    sqlite
  ];
}
