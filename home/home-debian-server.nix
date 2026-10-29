# home-debian-server.nix
# Lean profile for the small Docker hosts (vm14: 1 GB RAM, vm16: small root
# disk): shell, dotfiles and server tools only.
{ pkgs, lib, ... }:

let
  # Same scmpuff as home-debian.nix; see the note there.
  scmpuffPkg = pkgs.scmpuff;
in

{
  imports = [ ./home.nix ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  # No npm agent CLIs here: `npm install -g` on every activation is too heavy
  # for these hosts, and they would pull nodejs into the closure.
  home.activation.npmGlobalTools = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] "");

  # The full set is 222 MiB.
  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" ];
  };

  home.packages = with pkgs; [
    vim
    gitMinimal # full git pulls in python and perl
    scmpuffPkg
    eza
    ripgrep
    fd
    fzf
    zoxide
    delta
    tmux
    ncdu
    duf
    dust
    (callPackage ../pkgs/croc.nix { })
  ];
}
