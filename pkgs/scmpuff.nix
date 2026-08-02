{ lib, buildGoModule, fetchFromGitHub }:

# nixpkgs (25.05 stable and unstable) only ships 0.5.0/0.6.0; pin the latest
# upstream release directly until nixpkgs catches up.
# https://github.com/mroth/scmpuff/releases/tag/v0.7.0
buildGoModule (finalAttrs: {
  pname = "scmpuff";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "mroth";
    repo = "scmpuff";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-PrnZYk0moWH46AT5njQPk7kVOQaktwVbOGMAX307tyY=";
  };

  vendorHash = "sha256-Uu3tZhIoYPq4QWc63Y5cPNa+MZtFklwuZyUc0CJLlXc=";

  ldflags = [
    "-s"
    "-w"
    # see .goreleaser.yml in the repository
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=1970-01-01T00:00:00Z"
    "-X main.builtBy=nixpkgs"
    "-X main.treeState=clean"
  ];

  meta = {
    description = "Numeric file shortcuts for common git commands";
    homepage = "https://github.com/mroth/scmpuff";
    changelog = "https://github.com/mroth/scmpuff/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "scmpuff";
  };
})
