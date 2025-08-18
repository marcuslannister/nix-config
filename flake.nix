{
  description = "Ken's multi-platform system flake";

  inputs = {
    # Use consistent nixpkgs for all platforms
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

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
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-darwin, nix-darwin, home-manager, deploy-rs, dotfiles }:
  let
    # System definitions
    systems = {
      darwin = "aarch64-darwin";
      darwin-intel = "x86_64-darwin";
      linux = "x86_64-linux";
    };

    # Helper function to create pkgs for each system
    mkPkgs = system: nixpkgsInput: import nixpkgsInput {
      inherit system;
      config.allowUnfree = true;
    };

    # Shared configuration modules
    sharedModules = {
      common = import ./common.nix;
      common-darwin = import ./common-darwin.nix;  # For Darwin
      nixos = import ./nixos.nix;
      home = import ./home/home.nix;
    };

    # Darwin configuration factory
    mkDarwinConfig = { system ? systems.darwin, modules ? [] }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Base Darwin configuration
          sharedModules.common-darwin
          {
            nixpkgs.hostPlatform = system;
          }

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.ken = sharedModules.home;
              extraSpecialArgs = inputs // { inherit dotfiles; };
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
        extraSpecialArgs = inputs // extraSpecialArgs;
      };

    # NixOS configuration factory
    mkNixosConfig = { system, modules ? [], hostname }:
      nixpkgs.lib.nixosSystem {
        inherit system;
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
              users.ken = sharedModules.home;
              extraSpecialArgs = inputs;
              backupFileExtension = "backup";
            };
          }

          # System-specific settings
          {
            networking.hostName = hostname;
            nix.settings.trusted-users = [ "root" "ken" ];
          }
        ] ++ modules;
      };

  in
  {
    # === Darwin Configurations ===
    darwinConfigurations = {
      "Ken-MM-M4" = macMiniConfig; # Make sure the host name is same
      "Ken-MM-M1" = macMiniConfig;
      default = macMiniConfig;  # This enables "darwin-rebuild build --flake ."

      # Intel Mac (if you have one)
      "Ken-MBP-2015" = mkDarwinConfig {
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
      ken = mkHomeConfig {
        system = systems.linux;
        extraSpecialArgs = { inherit dotfiles; };
      };

      ken-debian = mkHomeConfig {
        system = systems.linux;
        modules = [ ./home/home-debian.nix ];
        extraSpecialArgs = { inherit dotfiles; };
      };

      # Darwin home-manager (if not using darwinModules)
      ken-darwin = mkHomeConfig {
        system = systems.darwin;
        extraSpecialArgs = { inherit dotfiles; };
      };

      # Intel Darwin home-manager
      ken-darwin-intel = mkHomeConfig {
        system = systems.darwin-intel;
        modules = [ sharedModules.home ];
        extraSpecialArgs = { inherit dotfiles; };
      };
    };

    # === NixOS Configurations ===
    nixosConfigurations = {
      # nix95 = mkNixosConfig {
      #   system = systems.linux;
      #   hostname = "nix95";
      #   modules = [
      #     {
      #       home-manager.users.ken = import ./home-nix95.nix;
      #     }
      #   ];
      # };

      vm16-nixos = mkNixosConfig {
        system = systems.linux;
        hostname = "vm16-nixos";
      };
    };

    # === Deploy-rs Configuration ===
    deploy = {
      nodes = {
        vm16-nixos = {
          hostname = "vm16-nixos";
          sshUser = "ken";
          remoteBuild = true;

          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${systems.linux}.activate.nixos
              self.nixosConfigurations.vm16-nixos;
          };
        };

        # nix95 = {
        #   hostname = "nix95";
        #   sshUser = "ken";
        #   remoteBuild = true;
        #
        #   profiles.system = {
        #     user = "root";
        #     path = deploy-rs.lib.${systems.linux}.activate.nixos
        #       self.nixosConfigurations.nix95;
        #   };
        # };

        # Debian node (home-manager only)
        # vm99 = {
        #   hostname = "vm99";
        #   sshUser = "ken";
        #   remoteBuild = true;
        #   # modules = [
        #   #   {
        #   #     home-manager.users.ken = import ./home-debian.nix;
        #   #   }
        #   # ];
        #
        #   profiles.home = {
        #     user = "ken";
        #     path = deploy-rs.lib.${systems.linux}.activate.home-manager
        #       self.homeConfigurations.ken-debian;
        #   };
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
          echo "🚀 Welcome to Ken's Nix development environment!!"
          echo ""
          echo "Available commands:"
          echo "  dd          - deploy --dry-run"
          echo "  deploy-nix95 - deploy .#nix95"
          echo "  hm-switch   - home-manager switch --flake ."
          echo ""

          # Useful aliases
          alias dd="deploy --dry-run"
          alias deploy-nix95="deploy .#nix95"
          alias hm-switch="home-manager switch --flake ."
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
