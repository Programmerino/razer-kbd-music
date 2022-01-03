{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    barva-repo.url = "github:Kharacternyk/barva";
    barva-repo.flake = false;
    razer-led-cli.url = "github:Programmerino/razer-led-cli";
    razer-led-cli.flake = true;
  };

  description = "A simple script for music visualization for Razer laptop keyboards";

  outputs = { self, nixpkgs, flake-utils, razer-led-cli, barva-repo }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
        barva = import "${barva-repo}/shell.nix" { inherit pkgs; };
      in
        rec {
          packages.razer-kbd-music = pkgs.writeShellScriptBin "razer-kbd-music" ''
            export BARVA_PULSE_SIMPLE="${pkgs.libpulseaudio}/lib/libpulse-simple.so.0"
            ${pkgs.unixtools.script}/bin/script -f -O /dev/null -qc "${barva}/bin/barva pulse-hex --fps 60 --unsafe True --inertia 0.2 --cto \#FFFFFF" | sudo ${razer-led-cli.defaultPackage."${system}"}/bin/razer-led-cli
          '';

          defaultPackage = packages.razer-kbd-music;

          apps.razer-kbd-music = flake-utils.lib.mkApp {
            drv = packages.razer-kbd-music;
          };
          
          defaultApp = apps.razer-kbd-music;
        }
    );
}
