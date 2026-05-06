{
  description = "Breeze cursors recolored with Catppuccin accents";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      accents = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
      };
      accentNames = builtins.attrNames accents;
      outlineColor = "#1e1e2e";
      version = self.shortRev or self.dirtyShortRev or "dev";
      buildSource = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./src
          ./Breeze-Catppuccin/src
        ];
      };
      prebuiltSource = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./prebuilt
        ];
      };
      forEachSystem = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      mkBuildFromSource = pkgs:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "catppuccin-breeze-build";
          inherit version;
          src = buildSource;

          nativeBuildInputs = with pkgs; [
            inkscape
            perl
            python3
            python3Packages.pyside6
            xcursorgen
          ];

          buildPhase = ''
            runHook preBuild

            cp -r "$src/Breeze-Catppuccin" ./Breeze-Catppuccin-base
            cp -r "$src/src" ./tooling
            chmod -R u+w ./Breeze-Catppuccin-base ./tooling
            chmod +x ./tooling/build.sh ./tooling/generate_cursors

            patchShebangs ./tooling
            export QT_QPA_PLATFORM=offscreen

            for accent in ${lib.concatStringsSep " " accentNames}; do
              case "$accent" in
${lib.concatStringsSep "\n" (map (accent: "                ${accent}) color='${accents.${accent}}' ;;") accentNames)}
              esac

              themeName="Breeze-Catppuccin-$accent"
              workDir="./build-$accent"

              cp -r ./Breeze-Catppuccin-base "$workDir"
              chmod -R u+w "$workDir"

              substituteInPlace "$workDir/src/index.theme" \
                --replace-fail "Name=Breeze-Catppuccin-Blue" "Name=$themeName" \
                --replace-fail "Comment=Breeze with Catppuccin blue cursor accents" "Comment=Breeze with Catppuccin $accent cursor colors"

              for svg in "$workDir"/src/svg/*.svg; do
                perl -0pi -e "s|#cdd6f4|$color|g; s|#89b4fa|$color|g; s|#f38ba8|$color|g; s|#fab387|$color|g; s|#11111b|${outlineColor}|g; s|opacity=\\\"\\.2\\\" fill=\\\"${outlineColor}\\\"|opacity=\\\".2\\\" fill=\\\"#11111b\\\"|g" "$svg"
              done

              (
                cd "$workDir"
                ../tooling/build.sh
              )
            done

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p "$out/share/icons"

            for accent in ${lib.concatStringsSep " " accentNames}; do
              cp -r "./build-$accent/Breeze-Catppuccin-$accent" "$out/share/icons/"
            done

            runHook postInstall
          '';

          meta = {
            description = "Prebuilt Breeze cursor themes for all Catppuccin accents";
            homepage = "https://github.com/matthis-k/breeze-catppuccin";
            license = lib.licenses.gpl2Only;
            platforms = systems;
          };
        };
      mkPrebuiltBundle = pkgs:
        pkgs.runCommand "catppuccin-breeze-prebuilt-${version}"
          {
            meta = {
              description = "Checked-in Breeze cursor themes for all Catppuccin accents";
              homepage = "https://github.com/matthis-k/breeze-catppuccin";
              license = lib.licenses.gpl2Only;
              platforms = systems;
            };
          }
          ''
            mkdir -p "$out/share/icons"
            cp -a "${prebuiltSource}/prebuilt/." "$out/share/icons/"
          '';
      mkTheme = pkgs: build: accent:
        pkgs.runCommand "catppuccin-breeze-${accent}-${version}"
          {
            meta = {
              description = "Breeze cursors recolored to match Catppuccin ${accent} content and outline colors";
              homepage = "https://github.com/matthis-k/breeze-catppuccin";
              license = lib.licenses.gpl2Only;
              platforms = systems;
            };
          }
          ''
            mkdir -p "$out/share/icons"
            ln -s "${build}/share/icons/Breeze-Catppuccin-${accent}" "$out/share/icons/Breeze-Catppuccin-${accent}"
          '';
    in
    {
      packages = forEachSystem (pkgs:
        let
          build = mkPrebuiltBundle pkgs;
          buildFromSource = mkBuildFromSource pkgs;
          themes = lib.genAttrs accentNames (accent: mkTheme pkgs build accent);
        in
        themes
        // {
          inherit build buildFromSource;
          default = themes.blue;
          catppuccin-breeze = themes;
        });
    };
}
