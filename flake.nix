{
  description = "Jules de Cube system configuration";

  inputs = {
    iac.url = git+https://gitlab.julesdecube.com/infra/iac;

    nixpkgs.follows = "iac/nixpkgs";
    home-manager.follows = "jdc-home-manager/home-manager";

    jdc-home-manager = {
      url = git+https://gitlab.julesdecube.com/julesdecube/home-manager;
      inputs = {
        nixpkgs.follows = "iac/nixpkgs";
        flake-utils.follows = "iac/futils";
      };
    };
  };

  outputs = { self, nixpkgs, ... } @ attrs : {
    nixosConfigurations = {
      nixos-jules-portable = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [ ./configuration.nix ];
      };
    };
  };
}
