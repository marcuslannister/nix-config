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

  # Environment packages.
  #
  # The tools below the base set include mac-mini-m4's Homebrew Leaves, moved
  # here on 2026-08-12 under the rule in CONTEXT.md: everything that is not an
  # app bundle belongs to Nix.  Every one was checked with meta.available on
  # both aarch64-darwin and x86_64-darwin, so the Intel Mac still evaluates.
  environment.systemPackages = with pkgs; [
    # base
    vim
    git
    ruby # for ~/.scm_breeze/install.sh
    # jujutsu
    nodejs_24
    # From unstable: 25.05 carries bun 1.2.13, a year behind.  Homebrew had
    # 1.3.14; unstable is 1.3.13.  On Intel `unstable` resolves to 25.05, so
    # that host stays on 1.2.13 (same trade-off as gcc15 and zellij).
    unstable.bun
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
    gdu
    procs
    glow
    lazygit
    yazi
    nushell
    starship

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

    # GNU tool replacements (macOS ships BSD variants).  gnused and diffutils
    # shadow the BSD sed and diff, the same way gnutar/gnugrep/gawk already do.
    # coreutils stays g-prefixed: ~/.emacs.d/lisp/init-dired.el looks for `gls`,
    # and the BSD ls it falls back to has no --dired.
    gnutar
    gnugrep
    gawk
    findutils
    gnused
    diffutils
    # Both: ~/.zshenv used to put Homebrew's coreutils gnubin first on PATH, so
    # ls, cp, rm and date were GNU already; plain coreutils keeps that.  The
    # prefixed set is still needed for `gls`, which ~/.emacs.d/lisp/init-dired.el
    # looks for and BSD ls cannot replace (no --dired).
    coreutils
    coreutils-prefixed

    # network
    iperf3
    croc
    axel
    speedtest-cli
    socat
    wget
    httpie
    bandwhich
    cloudflared
    dog
    doggo
    ffsend
    fping
    mitmproxy
    mtr
    net-snmp
    wakeonlan
    wgcf
    wireguard-tools
    # httping and nexttrace stay on Homebrew: both are Linux-only in nixpkgs
    # 25.05 (meta.platforms excludes darwin).  See CONTEXT.md, "Exception".

    # dev tools
    autoconf
    automake
    cmake
    gnumake
    ninja
    # pkg-config, not pkgconf: the nixpkgs pkgconf package installs a `pkgconf`
    # binary only, while autotools and cmake look for `pkg-config` by name.
    pkg-config
    lld
    # From unstable: 25.05's gcc15 is 15.1.0 and cannot build on aarch64-darwin.
    # Its libgcc re-exports ___register_frame_table, which the linker cannot resolve.
    unstable.gcc15
    guile
    git-filter-repo
    quilt
    texinfo
    rustup
    gh
    go
    hugo
    llvm
    pyenv
    subversion
    fswatch
    global
    minicom

    # editors & language servers
    neovim
    bash-language-server
    marksman
    shfmt
    stylua
    micro
    nodePackages.prettier

    # media
    ffmpeg
    yt-dlp
    imagemagick
    jpegoptim
    libjxl
    tesseract
    gnutls
    fontforge

    # document
    pandoc
    tectonic
    # pdflatex
    # aspell
    # aspellDicts.en
    (aspellWithDicts (dicts: with dicts; [en en-computers en-science]))

    # mac and hardware
    mas
    opencode
    qrencode
    scrcpy
    smartmontools
    # syncthing stays on Homebrew; see darwin/homebrew-mac-mini-m4.nix

    # docker
    docker-compose
    sqlite

  ];

  # Fonts that were Homebrew casks.  They are files, not app bundles, so Nix
  # owns them (see CONTEXT.md); fonts.packages installs into /Library/Fonts.
  fonts.packages = with pkgs; [
    ibm-plex
    inconsolata
    inter
    iosevka
    jetbrains-mono
    maple-mono.NF-CN
    source-sans-pro
    source-serif-pro
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
  ];

  # User configuration for Darwin
  # primaryUser is what nix-darwin's user-scoped options default to; homebrew.user
  # reads it, and enabling homebrew without it fails evaluation.
  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
