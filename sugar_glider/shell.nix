{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  unstable = import <unstable> {};
in

mkShell {
  buildInputs = [
    unstable.zig_0_11
    unstable.zls
  ];
  shellHook = ''
    export NVIM_ZIG_LSP=true
  '';
}
