{
  description = "A Nix-flake-based Zig development environment";

  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        unstable = import nixpkgs-unstable { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, unstable }: {
        default = pkgs.mkShell {
          packages = [
            unstable.zig
            unstable.zls
            pkgs.python311Packages.cram
            pkgs.pandoc
          ];
          shellHook = ''
            export NVIM_ZIG_LSP=true
          '';
        };
      });
    };
}
