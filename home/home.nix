{ config, pkgs, inputs, dotfiles, ... }:

let
  # Platform-aware dotfiles path
  dotfilesPath = if pkgs.stdenv.isDarwin
    then "/Users/ken/dotfiles"
    else "/home/ken/dotfiles";

  # Helper function
  mkDotfileLink = file: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${file}";
  mkDotfileSource = file:
    if pkgs.stdenv.isDarwin
    then mkDotfileLink file
    else "${dotfiles}/${file}";
in

{
  # === Basic Configuration ===
  home = {
    username = "ken";
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
    ".gitconfig".source = "${dotfiles}/.gitconfig";

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

    # Create directories by placing empty .keep files
    ".local/share/vim/backup/.keep".text = "";
    ".local/share/vim/swap/.keep".text = "";
    ".local/share/vim/undo/.keep".text = "";
  };

  # === XDG Configuration ===
  xdg.configFile = {
    # Don't forget to run zompile after change these files
    "zsh/.zshrc.personal".source = mkDotfileSource ".config/zsh/.zshrc.personal";
    "zsh/.zshrc.fzf".source = mkDotfileSource ".config/zsh/.zshrc.fzf";

    "kitty/kitty.conf".source = mkDotfileSource ".config/kitty/kitty.conf";
    "kitty/current-theme.conf".source = mkDotfileSource ".config/kitty/current-theme.conf";
  };
}
