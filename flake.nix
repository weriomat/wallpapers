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
        packages = rec {
          c = pkgs.runCommand "c" {} ''
            mkdir $out
            for WALLPAPER in $(find ./wallpapers -type f)
            do
              ${pkgs.lutgen}/bin/lutgen apply $WALLPAPER -o $out/$(basename $WALLPAPER) -p catppuccin-mocha
            done
          '';
          b = let
            path = "./wallpapers";
          in
            pkgs.runCommand "prism" {} ''
              mkdir -p $out/lut_wallpapers
              find ${path} -type f -exec ${pkgs.lutgen}/bin/lutgen apply {} -p catppuccin-mocha -o $out/lut_wallpapers/{} \;
            '';
          a = pkgs.stdenv.mkDerivation {
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
          default = a;
          # default = pkgs.writeShellApplication {
          #   name = "lut";
          #   runtimeInputs = with pkgs; [lutgen findutils coreutils];
          #   text = ''
          #     rm -r ./lut_wallpapers
          #     mkdir -p ./lut_wallpapers
          #     find ./wallpapers -type f -exec ${pkgs.lutgen}/bin/lutgen apply {} -p catppuccin-mocha -o ./lut_wallpapers/{} \;
          #     mv ./lut_wallpapers/wallpapers/* ./lut_wallpapers
          #     rm -r ./lut_wallpapers/wallpapers
          #   '';
          # };

          # pkgs.runCommand "prism" {} ''
          #   mkdir $out/lut_wallpapers
          #   for WALLPAPER in $(find ${cfg.wallpapers} -type f)
          #   do
          #     ${pkgs.lutgen}/bin/lutgen apply $WALLPAPER -o $out/$(basename $WALLPAPER) ${colors}
          #   done
          # '';
        };
      }
    )
  );
}
