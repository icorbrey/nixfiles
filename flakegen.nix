inputs: { devShell, hosts, overlays }: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  withoutEmpty = lib.filterAttrs (x: x != null && (withoutEmpty x) != {});

  forEachSystem = f:
    builtins.listToAttrs
      (builtins.map (name: {
        inherit name;
        value = f name;
      })
        inputs.systems);

  pkgs = forEachSystem (system: {
    pkgs = import inputs.nixpkgs {
      inherit system;
      
      config.allowUnfree = true;
      overlays = overlays inputs;
    };
  });

  # { hosts.${host}.configuration } -> { ${host} }
  forEachNixosConfiguration = f:
    builtins.mapAttrs (hostname: { configuration, system, ... }: f {
      inherit
        configuration
        hostname
        system;
      inherit (pkgs.${system}) pkgs;
    })
    hosts;

  # { hosts.${host}.users.${user} } -> { "${user}@${host}" }
  forEachUserConfiguration = f:
    lib.mkMerge (builtins.listToAttrs (lib.flatten 
      (builtins.mapAttrsToList (hostname: { users, system, ... }:
        builtins.mapAttrsToList (username: configuration: {
          name = "${username}@${hostname}";
          value = f {
            inherit
              configuration
              hostname
              system
              username;
            inherit (pkgs.${system}) pkgs;
          };
        })
        users)
      hosts)));

in withoutEmpty {
  devShells = forEachSystem (system: devShell {
    inherit (pkgs.${system}) pkgs;
  });

  nixosConfigurations = forEachNixosConfiguration
    ({ hostname, configuration }: nixosSystem {
        modules = [
          ./hardware-configuration/${hostname}.nix
          { networking.hostname = hostname; }
          configuration
        ];
    });
  
  homeConfigurations = forEachUserConfiguration
    ({ username, configuration, pkgs, ... }: homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs;
      };

      modules = [
        ({ pkgs, ... }: {
          home.homeDirectory = "/home/${username}";
          home.username = username;

          home.packages = with pkgs; [
            home-manager
          ];
        })
        ({ ... }: configuration // {
          imports = [./modules/home];
        })
      ];
    });
}
