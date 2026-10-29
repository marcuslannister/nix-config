# croc 11 on every host and on the vm16 relay: 11.0 changed the PAKE
# handshake, so 10.x and 11.x peers should not be mixed.  The upstream release
# binary, not a source build: croc 11.5.5 and its dependency bradfitz/reco need
# Go >= 1.27.1, and 26.05's newest Go is 1.27rc3.  shortcut: bump the version
# and the four hashes with each croc release; drop this file once the nixpkgs
# release in flake.nix ships croc 11.
{ lib, stdenvNoCC, fetchurl, fetchFromGitHub, installShellFiles }:

let
  version = "11.5.5";
  assets = {
    aarch64-darwin = { name = "macOS-ARM64"; hash = "sha256-RNznX5jinLyx9COeHkk+8zfIATp75IUX6yHs7Xcb/6o="; };
    x86_64-darwin = { name = "macOS-64bit"; hash = "sha256-egCNYd1/faArQjRAV7pGrYEL5yUvM7L6/r7I9IBgxOw="; };
    x86_64-linux = { name = "Linux-64bit"; hash = "sha256-Le6bft6EmXFTLFl+8/0pUHv8lwMwdYz+0TZXvgTzQkM="; };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
  # Only for the bash and zsh completion scripts, which the release lacks.
  source = fetchFromGitHub {
    owner = "schollz";
    repo = "croc";
    rev = "v${version}";
    hash = "sha256-Y3WgLiMZL4caokULWOV+daNWkXNvzm7MDA3Vu6hUIHo=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "croc";
  inherit version;

  src = fetchurl {
    url = "https://github.com/schollz/croc/releases/download/v${version}/croc_v${version}_${asset.name}.tar.gz";
    inherit (asset) hash;
  };
  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -Dm755 croc $out/bin/croc
    installShellCompletion --cmd croc \
      --bash ${source}/src/install/bash_autocomplete \
      --zsh ${source}/src/install/zsh_autocomplete
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/croc --version | grep -F "${version}"
  '';

  meta = {
    description = "Easily and securely send things from one computer to another";
    homepage = "https://github.com/schollz/croc";
    license = lib.licenses.mit;
    platforms = builtins.attrNames assets;
    mainProgram = "croc";
  };
}
