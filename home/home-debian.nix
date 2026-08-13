# home-debian.nix
{ config, pkgs, inputs, dotfiles, nixpkgs-unstable, ... }:

let
  # The same v0.7.0 pin the ARM Macs run, built against unstable: scmpuff's
  # go.mod asks for Go 1.26, and 25.05 carries 1.24 here as it does there.
  # nixpkgs' own package is 0.5.0.
  scmpuffPin = nixpkgs-unstable.legacyPackages.${pkgs.system}.callPackage ../pkgs/scmpuff.nix { };
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
    scmpuffPin # took SCM Breeze's place, which was ruby's only reason to be here
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
