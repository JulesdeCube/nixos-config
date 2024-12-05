{
  description = "Jules de Cube system configuration";

  inputs = {
    snowball.url = "git+https://gitlab.julesdecube.com/infra/snowball.git";
    nixpkgs.follows = "snowball/nixpkgs";
    git-hooks.follows = "snowball/git-hooks";
    flake-utils.follows = "snowball/flake-utils";
    home-manager.follows = "jdc-home-manager/home-manager";

    jdc-home-manager = {
      url = "git+https://gitlab.julesdecube.com/julesdecube/home-manager.git";
      inputs = {
        snowball.follows = "snowball";
      };
    };
  };

  outputs = { self, nixpkgs, jdc-home-manager, flake-utils, git-hooks, ... } @ attrs:
    let
      inherit (flake-utils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ jdc-home-manager.overlays.default ];
        };

      globalOutput = {
        nixosConfigurations = rec {
          default = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [
              { nixpkgs.overlays = [ jdc-home-manager.overlays.default ]; }
              ./configuration.nix
            ];
          };

          "nixos-jules-portable.julesdecube.com" = default;
          nixos-jules-portable = default;


          yubikey = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./yubikey.nix ];
          };
        };
      };

      systemOutput = system:
        let
          pkgs = pkgImport nixpkgs system;
          hook = git-hooks.lib.${system};
          tools = import "${git-hooks}/nix/call-tools.nix" pkgs;
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
