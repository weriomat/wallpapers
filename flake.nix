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
        packages = {
          a = pkgs.stdenv.mkDerivation {
            pname = "weriomat wallpapers";
            version = "0.0.1";

            buildInputs = with pkgs; [lutgen findutils coreutils];

            installPhase = ''
              runHook preInstall

              mkdir -p "$out"/wallpapers
              for WALLPAPER in $(find ./wallpapers -type f)
              do
                ${pkgs.lutgen}/bin/lutgen apply $WALLPAPER -o $out/$(basename $WALLPAPER) -p catppuccin-mocha
              done

              runHook postInstall
            '';
          };
          default = pkgs.writeShellApplication {
            name = "lut";
            runtimeInputs = with pkgs; [lutgen findutils coreutils];
            text =
              #zsh
              ''
                rm -r ./lut_wallpapers
                mkdir -p ./lut_wallpapers
                find ./wallpapers -type f -exec ${pkgs.lutgen}/bin/lutgen apply {} -p catppuccin-mocha -o ./lut_wallpapers/{} \;
                mv ./lut_wallpapers/wallpapers/* ./lut_wallpapers
                rm -r ./lut_wallpapers/wallpapers
              '';
          };
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
