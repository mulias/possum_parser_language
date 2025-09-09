{
  description = "A Nix-flake-based Zig development environment";

  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
  inputs.zig-overlay.url = "github:mitchellh/zig-overlay";
  inputs.zls-overlay.url = "github:zigtools/zls?ref=0.15.0";

  outputs = { self, nixpkgs, nixpkgs-unstable, zig-overlay, zls-overlay }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f (rec {
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        unstable = import nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        zig = zig-overlay.packages.${system}."0.15.1";
        zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
          nativeBuildInputs = [ zig ];
        });
      }));
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, unstable, zig, zls }: {
        default = pkgs.mkShell {
          packages = [
            zig
            zls
            pkgs.python311Packages.cram
            pkgs.pandoc
          ];
          shellHook = ''
            export NVIM_ZIG_LSP=true
          '';
        };

        ci = pkgs.mkShell {
          packages = [
            zig
            pkgs.python311Packages.cram
            pkgs.pandoc
          ];
        };
      });
    };
}
