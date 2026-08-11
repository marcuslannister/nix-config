# common-darwin.nix
{ config, pkgs, unstable, username, ... }:

{
  # Darwin-specific configuration
  system.stateVersion = 6;

  # Nix configuration
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" username ];
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
    ruby # for ~/.scm_breeze/install.sh
    # jujutsu
    nodejs_24
    shellcheck

    # python
    (python3.withPackages (ps: with ps; [
      pip
      pyyaml
      setuptools
      wheel
    ]))
    uv

    # utils
    eza # A modern replacement for ‘ls’
    ripgrep # recursively searches directories for a regex pattern
    tmux
    unstable.zellij
    ncdu
    bat
    btop

    # files
    duf
    dust
    fzf
    fd
    sd
    p7zip
    pbzip2
    pigz

    # misc
    zoxide
    delta
    skim # provides `sk`
    # bitwarden-cli

    # GNU tool replacements (macOS ships BSD variants)
    gnutar
    gnugrep
    gawk
    findutils

    # network
    iperf3
    croc
    axel
    speedtest-cli
    socat

    # dev tools
    automake
    cmake
    # Emacs.app native compilation links every .eln against this GCC's runtime
    # archives (libemutls_w.a, libheapt_w.a, libgcc.a); do not drop it, or all
    # native compilation fails with "error invoking gcc driver". ~/.emacs.d
    # early-init.el finds them via `gcc -print-libgcc-file-name`.
    # Taken from unstable to get 15.2.0 exactly, matching the libgccjit 15.2.0
    # bundled in Emacs.app.  25.05's own gcc15 is 15.1.0 and cannot build on
    # aarch64-darwin at all: its libgcc re-exports ___register_frame_table and
    # friends, which the linker cannot resolve.  The unstable build is cached.
    unstable.gcc15
    guile
    git-filter-repo
    quilt
    texinfo
    rustup
    gh

    # editors & language servers
    bash-language-server
    marksman
    shfmt
    stylua
    micro
    nodePackages.prettier

    # media
    imagemagick
    jpegoptim
    libjxl
    tesseract
    gnutls

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

  # User configuration for Darwin
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
