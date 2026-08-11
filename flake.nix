{
  description = "Multi-platform Nix system flake";

  inputs = {
    # Use consistent nixpkgs for all platforms
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = { url = "github:nix-community/home-manager/release-25.05"; inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:marcuslannister/dotfiles";
      flake = false;
    };

    zjstatus.url = "github:dj95/zjstatus";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-darwin, nix-darwin, home-manager, deploy-rs, dotfiles, nixpkgs-unstable, zjstatus }:
  let
    # System definitions
    systems = {
      darwin = "aarch64-darwin";
      darwin-intel = "x86_64-darwin";
      linux = "x86_64-linux";
    };

    # Dynamic account username (requires --impure; see devShell aliases below).
    # Prefer SUDO_USER: darwin-rebuild/nixos-rebuild run under sudo, which resets
    # USER/LOGNAME to "root" even with `sudo -E`, so plain $USER would misidentify
    # the account when switching via sudo.
    username =
      let sudoUser = builtins.getEnv "SUDO_USER";
          plainUser = builtins.getEnv "USER";
      in if sudoUser != "" then sudoUser else plainUser;

    zjstatusOverlay = final: prev: {
      zjstatus = zjstatus.packages.${prev.system}.default;
    };

    # Helper function to create pkgs for each system
    mkPkgs = system: nixpkgsInput: import nixpkgsInput {
      inherit system;
      config.allowUnfree = true;
      overlays = [ zjstatusOverlay ];
    };

    # Shared configuration modules
    sharedModules = {
      common = import ./common.nix;
      common-darwin = import ./common-darwin.nix;  # For Darwin
      nixos = import ./nixos.nix;
      home = import ./home/home.nix;
    };

    # Emacs on every Mac, ARM and Intel alike, from the d12frosted/emacs-plus
    # tap.  emacs-plus@31 tracks the emacs-31 pretest branch and has no bottle, so
    # every install compiles from source -- hence upgrade = false, which keeps an
    # unrelated `darwin-rebuild switch` from turning into a 30-minute build.
    # cleanup = "none" because these Macs carry formulae and casks installed by
    # hand that the Brewfile does not describe; anything stricter would start
    # uninstalling them.  The dragon-plus icon cannot be passed as a formula arg;
    # it lives in ~/.config/emacs-plus/build.yml (see home/home.nix).
    # brewPrefix follows the platform on its own: /opt/homebrew on ARM,
    # /usr/local on Intel.  A Mac with no Homebrew logs an error and skips.
    # The Homebrew activation prefix installs the out-of-store trust symlink
    # before `brew bundle`; home-manager runs too late for this file.
    emacsModule = { lib, ... }: {
      system.activationScripts.homebrew.text = lib.mkBefore ''
        /usr/bin/install -d -m 0755 -o ${username} -g staff "/Users/${username}/.homebrew"
        sudo --user=${username} --set-home /bin/ln -sfn \
          "/Users/${username}/dotfiles/.homebrew/trust.json" \
          "/Users/${username}/.homebrew/trust.json"
      '';

      homebrew = {
        enable = true;

        taps = [ "d12frosted/emacs-plus" ];

        brews = [
          {
            name = "emacs-plus@31";
            args = [ "with-xwidgets" ];
          }
        ];

        onActivation = {
          autoUpdate = false;
          upgrade = false;
          cleanup = "none";
        };
      };
    };

    # Darwin configuration factory
    mkDarwinConfig = { system ? systems.darwin, modules ? [] }:
      nix-darwin.lib.darwinSystem {
        inherit system;

        # Add specialArgs here with the correct input name
        # On x86_64-darwin `unstable` is really 25.05: nixpkgs 26.11 dropped
        # x86_64-darwin, and importing it throws at evaluation time, which would
        # take the whole Intel host down.  The packages read through this arg
        # (gcc15, zellij, syncthing) all exist in 25.05, just at older versions.
        specialArgs = {
          unstable =
            if system == systems.darwin-intel
            then nixpkgs-darwin.legacyPackages.${system}
            else nixpkgs-unstable.legacyPackages.${system};
          inherit dotfiles username;
        };

        modules = [
          # Base Darwin configuration
          sharedModules.common-darwin
          emacsModule
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.overlays = [ zjstatusOverlay ];
          }

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = sharedModules.home;
              extraSpecialArgs = inputs // { inherit dotfiles username; };
              backupFileExtension = "backup";
            };
          }
        ] ++ modules;
      };

      macMiniConfig = mkDarwinConfig {
        system = systems.darwin;
        modules = [
          # Mac specific settings
          {
            # system.defaults.dock.autohide = false;
          }
        ];
      };

    # Home Manager configuration factory
    mkHomeConfig = { system, modules ? [], extraSpecialArgs ? {} }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system (if (builtins.match ".*darwin.*" system != null) then nixpkgs-darwin else nixpkgs);
        modules = [ sharedModules.home ] ++ modules;
        extraSpecialArgs = inputs // { inherit username; } // extraSpecialArgs;
      };

    # NixOS configuration factory
    mkNixosConfig = { system, modules ? [], hostname }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username; };

        modules = [
          sharedModules.common
          # sharedModules.nixos
          ./nodes/node-${hostname}.nix

          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = sharedModules.home;
              extraSpecialArgs = inputs // { inherit username; };
              backupFileExtension = "backup";
            };
          }

          # System-specific settings
          {
            networking.hostName = hostname;
            nix.settings.trusted-users = [ "root" username ];
            nixpkgs.overlays = [ zjstatusOverlay ];
          }
        ] ++ modules;
      };

  in
  {
    # === Darwin Configurations ===
    darwinConfigurations = {
      # TODO: mac-mini-m1, macbook-pro-m1, macbook-pro-2015-intel still need their
      # physical hostnames renamed to match (System Settings > General > Sharing >
      # Local hostname / Computer Name, or `sudo scutil --set ComputerName/HostName/
      # LocalHostName <name>`). Until then, the implicit hostname lookup used by
      # `darwin-rebuild switch --flake .` (no explicit target) won't find these
      # entries on those machines -- use an explicit `--flake .#mac-mini-m1` (etc.)
      # instead, or fall back to `default`.
      "mac-mini-m4" = macMiniConfig; # Make sure the host name is same

      "macbook-pro-m1" = mkDarwinConfig { system = systems.darwin; };

      default = macMiniConfig;  # This enables "darwin-rebuild build --flake ."

      # mac-mini-m1 only: scmpuff, pinned to upstream v0.7.0 (see pkgs/scmpuff.nix)
      "mac-mini-m1" = mkDarwinConfig {
        system = systems.darwin;
        modules = [
          ({ unstable, ... }: {
            environment.systemPackages = [ (unstable.callPackage ./pkgs/scmpuff.nix { }) ];
          })
        ];
      };

      # Intel Mac (if you have one)
      "macbook-pro-2015-intel" = mkDarwinConfig {
        system = systems.darwin-intel;
        modules = [
          # Intel Mac specific settings
          {
            # system.defaults.dock.autohide = false;
          }
        ];
      };
    };

    # === Home Manager Configurations ===
    homeConfigurations = {
      # Standalone home-manager for non-NixOS systems
      linux = mkHomeConfig {
        system = systems.linux;
        extraSpecialArgs = { inherit dotfiles; };
      };

      debian = mkHomeConfig {
        system = systems.linux;
        modules = [ ./home/home-debian.nix ];
        extraSpecialArgs = { inherit dotfiles; };
      };

      debian-ai = mkHomeConfig {
        system = systems.linux;
        modules = [ ./home/home-debian-ai.nix ];
        extraSpecialArgs = { inherit dotfiles; };
      };

      # Darwin home-manager (if not using darwinModules)
      darwin = mkHomeConfig {
        system = systems.darwin;
        extraSpecialArgs = { inherit dotfiles; };
      };

      # Intel Darwin home-manager
      darwin-intel = mkHomeConfig {
        system = systems.darwin-intel;
        modules = [ sharedModules.home ];
        extraSpecialArgs = { inherit dotfiles; };
      };
    };

    # === NixOS Configurations ===
    nixosConfigurations = {
      vm16-nixos = mkNixosConfig {
        system = systems.linux;
        hostname = "vm16-nixos";
      };
    };

    # === Deploy-rs Configuration ===
    deploy = {
      nodes = {
        # Debian node (home-manager only)
        vm98 = {
          hostname = "vm98";
          sshUser = username;
          remoteBuild = true;
          # modules = [
          #   {
          #     home-manager.users.${username} = import ./home-debian.nix;
          #   }
          # ];

          profiles.home = {
            user = username;
            path = deploy-rs.lib.${systems.linux}.activate.home-manager
              self.homeConfigurations.debian;
          };
         };

        # Debian AI node (home-manager only)
        vm97 = {
          hostname = "vm97";
          sshUser = username;
          remoteBuild = true;
          # modules = [
          #   {
          #     home-manager.users.${username} = import ./home-debian.nix;
          #   }
          # ];

          profiles.home = {
            user = username;
            path = deploy-rs.lib.${systems.linux}.activate.home-manager
              self.homeConfigurations.debian-ai;
          };
         };
      };
    };

    # === Development Shells ===
    devShells = nixpkgs.lib.genAttrs [ systems.darwin systems.linux ] (system:
      let pkgs = mkPkgs system nixpkgs; in
      pkgs.mkShell {
        name = "nix-config-dev";

        buildInputs = with pkgs; [
          # Essential tools
          vim
          git

          # Nix tools
          nixpkgs-fmt
          nil # Nix LSP

          # Deploy tools
          deploy-rs.packages.${system}.default
        ];

        shellHook = ''
          echo "🚀 Welcome to the Nix development environment!!"
          echo ""
          echo "Available commands:"
          echo "  dd            - deploy --dry-run"
          echo "  hm-switch     - home-manager switch --flake . --impure"
          echo "  darwin-switch - darwin-rebuild switch --flake . --impure"
          echo "  nixos-switch  - sudo nixos-rebuild switch --flake . --impure"
          echo ""

          # Useful aliases
          alias dd="deploy --dry-run"
          alias hm-switch="home-manager switch --flake . --impure"
          alias darwin-switch="darwin-rebuild switch --flake . --impure"
          alias nixos-switch="sudo nixos-rebuild switch --flake . --impure"
          alias nix-fmt="nixpkgs-fmt ."

          # Set up development environment
          export EDITOR="vim"
        '';
      }
    );

    # === Checks ===
    checks = builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;

    # === Formatters ===
    formatter = nixpkgs.lib.genAttrs [ systems.darwin systems.linux ] (system:
      (mkPkgs system nixpkgs).nixpkgs-fmt
    );

    # === Packages (optional - for custom packages) ===
    packages = nixpkgs.lib.genAttrs [ systems.darwin systems.linux ] (system:
      let pkgs = mkPkgs system nixpkgs; in
      {
        # Add custom packages here if needed
        # my-script = pkgs.writeShellScriptBin "my-script" ''
        #   echo "Hello from custom package!"
        # '';
      }
    );
  };
}
