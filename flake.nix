{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: (
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # TODO: put this into the main flake and only make this a thingie
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "weriomat wallpapers";
            version = "0.0.1";

            src = builtins.path {
              name = "wallpapers";
              path = ./wallpapers;
            };

            buildInputs = with pkgs; [lutgen findutils coreutils];

            buildPhase = ''
              mkdir -p $out/lut_wallpapers
              find . -type f -exec ${pkgs.lutgen}/bin/lutgen apply {} -p catppuccin-mocha -o $out/lut_wallpapers/{} \;
            '';

            installPhase = ''
              runHook preInstall

              mv $out/lut_wallpapers/* $out
              rm -r $out/lut_wallpapers

              runHook postInstall
            '';
          };
        };
      }
    )
  );
}
