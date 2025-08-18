# home-debian.nix
{ config, pkgs, inputs, dotfiles, ... }:

{
  # Import the base home configuration
  imports = [ ./home.nix ];

  # Add specific packages on top of the base ones
  home.packages = with pkgs; [
    git
    zsh
    eza
    zoxide
    tmux
    delta
  ];
}
