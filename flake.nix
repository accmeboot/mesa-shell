{
  description = "Status bar, notification daemon, quick settings panel and lockscreen for Quickshell, built for dwl";

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
              ./assets/screenshots;
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
    };
}
