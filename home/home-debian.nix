# home-debian.nix
{ config, pkgs, inputs, dotfiles, ... }:

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
    ruby # for ~/.scm_breeze/install.sh
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
}
