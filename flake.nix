{
  description = "A very basic flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { nixpkgs, ... }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      system = "x86_64-linux";
      version = "1.9.1";
      application = fetchzip {
        url =
          "https://github.com/LaurentRDC/pandoc-plot/releases/download/${version}/pandoc-plot-Linux-x86_64-static.zip";
        sha256 = "PWWiZOwscpAR9b7t1oCh/+FevgQ/0Z1se9f4XjenP+c=";
      };

    in {
      packages.${system}.default = stdenv.mkDerivation (finalAttrs: {
        pname = "pandoc-plot";
        inherit version;

        src = application;

        nativeBuildInputs = [ gmp libz unzip ];

        phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
        installPhase = ''
          mkdir -p $out/bin
          cp $src/pandoc-plot $out/bin/pandoc-plot
        '';
        fixupPhase = ''
          chmod +xw $out/bin/pandoc-plot
          patchelf --set-rpath ${gmp}/lib:${libz}/lib $out/bin/pandoc-plot
          chmod -w $out/bin/pandoc-plot
        '';

        meta = {
          description =
            "Render and include figures in Pandoc documents using your plotting toolkit of choice";
          homepage = "https://laurentrdc.github.io/pandoc-plot/";
          license = lib.licenses.gpl2;
          maintainers = [ ];
        };

      });
      formatter.${system} = nixfmt-classic;
    };
}
