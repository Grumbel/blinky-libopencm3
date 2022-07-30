{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    libopencm3_src.url = "github:libopencm3/libopencm3";
    libopencm3_src.flake = false;

    libopencm3-miniblink_src.url = "github:libopencm3/libopencm3-miniblink";
    libopencm3-miniblink_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, libopencm3_src, libopencm3-miniblink_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          libopencm3 = pkgs.stdenv.mkDerivation rec {
            pname = "libopencm3";
            version = "1.0.0-git";
            src = libopencm3_src;
            patchPhase = ''
              patchShebangs ./scripts/irq2nvic_h
            '';
            nativeBuildInputs = with pkgs; [
              gcc-arm-embedded
              python3
            ];
            buildInputs = with pkgs; [
            ];
            buildPhase = ''
              # make TARGETS="stm32/f1 stm32/f4"
              make
            '';
            installPhase = ''
              mkdir $out
              mkdir $out/lib/
              cp -v lib/*.a lib/*.ld $out/lib/

              mkdir $out/include/
              cp -vr include/. $out/include/
            '';
          };

          libopencm3-miniblink = pkgs.stdenv.mkDerivation rec {
            pname = "libopencm3-miniblink";
            version = "1.0.0-git";
            src = libopencm3-miniblink_src;
            patchPhase = ''
              rmdir libopencm3
              ln -s ${libopencm3} libopencm3
              ls -l libopencm3/lib/
              substituteInPlace Makefile \
                --replace ": libopencm3/Makefile" ":"
            '';
            nativeBuildInputs = with pkgs; [
              gcc-arm-embedded
            ];
            buildInputs = with pkgs; [
              python3
            ];
            buildPhase = ''
              make TARGETS="stm32/f1 stm32/f4"
            '';
            installPhase = ''
              mkdir $out
              mkdir $out/bin/
              cp -r bin/. $out/bin/
            '';
            fixupPhase = ''
              # do nothing
            '';
          };

          blinky = pkgs.stdenv.mkDerivation rec {
            pname = "blinky";
            version = "0.0.0";
            src = nixpkgs.lib.cleanSource ./.;
            nativeBuildInputs = with pkgs; [
              gcc-arm-embedded
              stlink
            ];
            patchPhase = ''
              ln -s ${libopencm3} libopencm3
            '';
            buildPhase = ''
              make
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp blinky.bin $out/bin/
            '';
            fixupPhase = ''
              # do nothing
            '';
            buildInputs = with pkgs; [
              libopencm3
            ];
          };

          flash-blinky = pkgs.writeShellScriptBin "flash-blinky" ''
            st-flash write ${blinky}/bin/blinky.bin 0x08000000
          '';

          default = blinky;
        };
      }
    );
}
