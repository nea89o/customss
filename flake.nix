{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [];
        pkgs = import nixpkgs {inherit system overlays;};
      in
        with pkgs; rec {
          packages = {
            inherit slurp-patched myss;
          };
          myss = symlinkJoin rec {
            name = "myss";
            deps = [
              slurp-patched
              grim
              wl-clipboard
              imagemagick
              gnused
              coreutils
            ];
            scriptSource = builtins.readFile ./myss.sh;
            buildInputs = [makeWrapper];
            scriptO = (writeScriptBin name scriptSource).overrideAttrs (old: {
              buildCommand = "${old.buildCommand}\npatchShebangs $out";
            });
            paths = [scriptO] ++ deps;
            postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
          };

          slurp-patched = stdenv.mkDerivation (finalAttrs: rec {
            pname = "slurp";
            version = "1.0.0";
            src = fetchFromGitHub {
              owner = "tmccombs";
              repo = "slurp";
              rev = "8422167eb4899cd369e4a432ee78ff59659071a0";
              hash = "sha256-6cDcrCmsnFSSC2DEFr+zP4PklCWRZ+z8pUkeuUAIlBA=";
            };
            depsBuildBuild = [pkg-config];

            nativeBuildInputs =
              [
                meson
                ninja
                pkg-config
                wayland-scanner
              ]
              ++ lib.optional buildDocs scdoc;

            buildInputs = [
              cairo
              libxkbcommon
              wayland
              wayland-protocols
            ];

            strictDeps = true;
            buildDocs = true;

            mesonFlags = [(lib.mesonEnable "man-pages" buildDocs)];
          });
          formatter = pkgs.alejandra;
        }
    );
}
