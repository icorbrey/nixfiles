{
  description = "My system configurations";

  # Nix stuff
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.nur.url = "github:nix-community/NUR";
  inputs.systems.url = "github:nix-systems/default";

  outputs = inputs: import ./flakegen.nix inputs {
    overlays = { nur, ... }: [
      nur.overlay
    ];
    
    devShell = { pkgs, ... }: import ./shell.nix {
      inherit pkgs;
    };

    hosts.elysium = {
      system = "x86_64-linux";
      stateVersion = "24.11";

      users.icorbrey = {
        workflows.common.enable = true;
        workflows.web-development.enable = true;

        languages.rust.enable = true;
      };
    };

    hosts.NB-99KZST3 = {
      system = "x86_64-linux";
      stateVersion = "24.11";

      users.icorbrey = {
        workflows.common.enable = true;
        workflows.containers.enable = true;
        workflows.web-development.enable = true;

        languages.c-sharp.enable = true;
        languages.java.enable = true;
        languages.rust.enable = true;
      };
    };

    hosts.twili = {
      system = "x86_64-linux";
      stateVersion = "23.11";

      configuration = {
        boot.loader.grub.enable = true;
        boot.loader.grub.device = "/dev/sda";
        boot.loader.grub.useOSProber = true;

        i18n.defaultLocale = "en_US.UTF-8";

        networking.networkmanager.enable = true;

        nixpkgs.config.allowUnfree = true;

        services.openssh.enable = true;
        services.tailscale.enable = true;

        time.timeZone = "America/Indiana/Indianapolis";

        users.users.icorbrey = {
          isNormalUser = true;
        };
      };

      users.icorbrey = {
        workflows.common.enable = true;
      };
    };

    hosts.zephyr = {
      system = "x86_64-linux";
      stateVersion = "24.11";

      users.icorbrey = {
        workflows.common.enable = true;
        workflows.common-gui.enable = true;
        workflows.web-development.enable = true;

        languages.rust.enable = true;
      };
    };
  };
}
