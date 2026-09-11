{
  description = "Status bar, notification daemon, quick settings panel and lockscreen for Quickshell, built for Sway";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "mesa-shell";
          version = self.shortRev or self.dirtyShortRev or "dirty";

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.difference
              (pkgs.lib.fileset.unions [ ./shell.qml ./Components ./Modules ./Services ./assets ])
              ./assets/screenshot.png;
          };

          installPhase = ''
            mkdir -p $out/share/mesa-shell
            cp -r . $out/share/mesa-shell
          '';
        };

        mesa-dmenu = pkgs.stdenvNoCC.mkDerivation {
          pname = "mesa-dmenu";
          version = self.shortRev or self.dirtyShortRev or "dirty";

          src = ./scripts;
          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            install -Dm755 mesa-dmenu $out/bin/mesa-dmenu
            wrapProgram $out/bin/mesa-dmenu \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.socat pkgs.coreutils ]}
          '';

          meta.mainProgram = "mesa-dmenu";
        };
      });

      homeManagerModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.mesa-shell;
          json = pkgs.formats.json { };
          system = pkgs.stdenv.hostPlatform.system;

          quickshell = pkgs.symlinkJoin {
            name = "quickshell-mesa-shell";
            paths = [ pkgs.quickshell ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              for bin in quickshell qs; do
                wrapProgram $out/bin/$bin \
                  --prefix NIXPKGS_QT6_QML_IMPORT_PATH : ${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix} \
                  --suffix PATH : ${lib.makeBinPath [ pkgs.brightnessctl pkgs.bluez ]}
              done
            '';
            meta.mainProgram = "quickshell";
          };
        in
        {
          options.programs.mesa-shell = {
            enable = lib.mkEnableOption "mesa-shell";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${system}.default;
              description = "The mesa-shell package.";
            };

            settings = lib.mkOption {
              type = json.type;
              default = { };
              description = "Written to config.json, see config.example.json.";
            };
          };

          config = lib.mkIf cfg.enable {
            programs.quickshell = {
              enable = true;
              package = quickshell;
              activeConfig = "mesa-shell";
            };

            xdg.configFile."quickshell/mesa-shell" = {
              source = "${cfg.package}/share/mesa-shell";
              recursive = true;
            };

            xdg.configFile."quickshell/mesa-shell/config.json" = lib.mkIf (cfg.settings != { }) {
              source = json.generate "mesa-shell-config.json" cfg.settings;
            };

            home.packages = [ self.packages.${system}.mesa-dmenu ];
          };
        };
    };
}
