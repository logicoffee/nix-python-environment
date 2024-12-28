{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pythonPackageOverlay = final: prev: rec {
          python = prev.python312.override {
            packageOverrides = pFinal: pPrev: rec {
              # You can override packages or add packages that are not in nixpkgs
              fastapi = pPrev.buildPythonPackage rec {
                pname = "fastapi";
                version = "0.115.6";
                pyproject = true;
                build-system = [
                  pPrev.pdm-backend
                ];
                dependencies = with pPrev; [
                  starlette
                  pydantic
                  typing-extensions
                ];
                src = pPrev.fetchPypi {
                  inherit pname version;
                  hash = "sha256-nsRvet3BTqRylYqWquW13mXzlyGkaq9XBcSA2ai3ZlQ=";
                };
              };
            };
          };
        };

        pkgs = import nixpkgs { inherit system; overlays = [ pythonPackageOverlay ]; };

        python = (pkgs.python.withPackages (p: with p; [
          # Add packages you want to use
          fastapi
        ]));
      in
        {
          devShell = pkgs.mkShell {
            packages = [ python pkgs.pyright ];
          };
        }
    );
}
