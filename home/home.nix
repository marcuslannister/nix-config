{ config, pkgs, inputs, dotfiles, username, ... }:

let
  # Platform-aware dotfiles path
  dotfilesPath = if pkgs.stdenv.isDarwin
    then "/Users/${username}/dotfiles"
    else "/home/${username}/dotfiles";

  # Helper function
  mkDotfileLink = file: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${file}";
  mkDotfileSource = file:
    if pkgs.stdenv.isDarwin
    then mkDotfileLink file
    else "${dotfiles}/${file}";

  # ssh'ing into a host from Ghostty leaves TERM=xterm-ghostty, which no stock
  # ncurses database knows about; without this every remote shell greets you
  # with "can't find terminal definition for xterm-ghostty".
  ghosttyTerminfo = pkgs.callPackage ../pkgs/ghostty-terminfo.nix { };

  zellijSmartTabs = pkgs.fetchurl {
    url = "https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/download/v0.2.4/zellij-smart-tabs.wasm";
    hash = "sha256-CUSSxJWAZLejW4uGwoVpudHCRD1gqHLanyamHmjF3y0=";
  };
in

{
  # === Basic Configuration ===
  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";
  };

  # === Packages ===
  home.packages = with pkgs; [
    # networking tools

    # development tools
  ];

  # === Dotfiles ===
  home.file = {
    # Shell Configuration
    # Don't forget to run zompile after change these files
    ".zlogin".source = mkDotfileSource ".zlogin";
    ".zshenv".source = mkDotfileSource ".zshenv";
    ".zshrc".source = mkDotfileSource ".zshrc";

    ".zimrc".source = "${dotfiles}/.zimrc";

    # Version Control
    ".gitconfig".source = mkDotfileSource ".gitconfig";

    # Package managers
    ".npmrc".source = mkDotfileSource ".npmrc";

    ".local/bin/git-ediff-tui" = {
      source = "${dotfiles}/local/bin/git-ediff-tui";
      executable = true;
    };

    # Vim
    ".vimrc".source = "${dotfiles}/.vimrc";
    ".vim" = {
      source = "${dotfiles}/.vim";
      recursive = true;
    };

    # Tmux
    ".tmux.conf".source = "${dotfiles}/.tmux.conf";

    # Scripts with fixed shebangs for NixOS
    ".local/bin/cuip" = {
      source = "${dotfiles}/local/bin/cuip";
      executable = true;
    };

    ".local/bin/yank" = {
      source = "${dotfiles}/local/bin/yank";
      executable = true;
    };

    ".local/bin/writebackup.sh" = {
      source = "${dotfiles}/local/bin/writebackup.sh";
      executable = true;
    };

    ".local/bin/ns.sh" = {
      source = mkDotfileSource "local/bin/ns.sh";
      executable = false;
    };

    # ~/.terminfo is on ncurses' built-in search path, so this resolves even
    # before TERMINFO_DIRS is exported by the profile scripts.
    ".terminfo" = {
      source = "${ghosttyTerminfo}/share/terminfo";
      recursive = true;
    };

    # Create directories by placing empty .keep files
    ".local/share/vim/backup/.keep".text = "";
    ".local/share/vim/swap/.keep".text = "";
    ".local/share/vim/undo/.keep".text = "";
  }
  # Homebrew reads its trust store from ~/.homebrew/trust.json when
  # XDG_CONFIG_HOME is unset, which is the case during `darwin-rebuild switch`;
  # an interactive shell has it set and reads ~/.config/homebrew/trust.json
  # instead.  Activation is the one that matters: `brew bundle` refuses to load
  # formulae from an untrusted tap and takes the switch down with it.
  #
  # This has to stay an out-of-store symlink -- `brew trust` writes to the file,
  # which a Nix store path would forbid.  Note the same ordering caveat as the
  # emacs-plus icon below: home-manager runs after Homebrew, so a first-ever
  # switch on a new Mac needs this file in place beforehand.
  // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
    ".homebrew/trust.json".source = mkDotfileLink ".homebrew/trust.json";
  };

  # === XDG Configuration ===
  xdg.configFile = {
    # Don't forget to run zompile after change these files
    "zsh/.zshrc.personal".source = mkDotfileSource ".config/zsh/.zshrc.personal";
    "zsh/.zshrc.fzf".source = mkDotfileSource ".config/zsh/.zshrc.fzf";
    "otty".source = mkDotfileSource ".config/otty";
    "tty7/config.json".source = mkDotfileSource ".config/tty7/config.json";

    "kitty/kitty.conf".source = mkDotfileSource ".config/kitty/kitty.conf";
    "kitty/current-theme.conf".source = mkDotfileSource ".config/kitty/current-theme.conf";

    "zellij/config.kdl".source = mkDotfileSource "/.config/zellij/config.kdl";
    "zellij/plugins/zellij-smart-tabs.wasm".source = zellijSmartTabs;
    "zellij/plugins/zjstatus.wasm".source = "${pkgs.zjstatus}/bin/zjstatus.wasm";
    "zellij/themes/modus_operandi_tinted.kdl".source = "${dotfiles}/.config/zellij/themes/modus_operandi_tinted.kdl";
    "zellij/layouts/default.kdl".source = mkDotfileSource ".config/zellij/layouts/default.kdl";
  }
  # emacs-plus reads its icon and patch choices from this file; there is no
  # formula option for the icon.  Every Darwin host installs emacs-plus (see
  # emacsModule in flake.nix), so this file is read wherever it lands.  Note
  # that homebrew activation runs before home-manager, so a first-ever install
  # picks up the default icon; `brew postinstall emacs-plus@31` re-applies this
  # without recompiling.
  // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
    "emacs-plus/build.yml".text = "icon: dragon-plus\n";
  };
}
