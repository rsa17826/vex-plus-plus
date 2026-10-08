{
  inputs = {
    nixpkgs = {
      url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = import nixpkgs {
          inherit system;
        };

        pythonEnv = pkgs.python312.withPackages (
          ps: with ps; [
            cryptography
          ]
        );

      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              pythonEnv
            ];
          };
        };
      }
    );
}
