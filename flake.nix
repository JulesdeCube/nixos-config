{
  description = "Jules de Cube system configuration";

  inputs = {
    iac.url = git+https://gitlab.julesdecube.com/infra/iac;

    nixpkgs.follows = "iac/nixpkgs";
    pre-commit-hooks.follows = "iac/pre-commit-hooks";
    futils.follows = "iac/futils";

    jdc-home-manager = {
      url = git+https://gitlab.julesdecube.com/julesdecube/home-manager;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "futils";
      };
    };

    home-manager.follows = "jdc-home-manager/home-manager";
  };

  outputs ={ self, nixpkgs, futils, pre-commit-hooks, ... } @ attrs :
    let
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

      globalOutput = {
    nixosConfigurations = {
      nixos-jules-portable = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [ ./configuration.nix ];
      };
    };
      };

      systemOutput = system:
        let
          pkgs = pkgImport nixpkgs system;
          hook = pre-commit-hooks.lib.${system};
          tools = import "${pre-commit-hooks}/nix/call-tools.nix" pkgs;
        in
        rec {
          checks.pre-commit-check = hook.run {
            src = ./.;

            tools = tools;

            hooks = {
              nixpkgs-fmt.enable = true;
            };
          };

          devShell = pkgs.mkShell {
            name = "iac";

            shellHook = ''
              ${checks.pre-commit-check.shellHook}
            '';

            buildInputs = with pkgs; [
              git
            ];

            packages = with pkgs; [
              nil

              tools.nixpkgs-fmt
            ];
          };
        };
    in
    globalOutput //
    eachDefaultSystem systemOutput;
}
