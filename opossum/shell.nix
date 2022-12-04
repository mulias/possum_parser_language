{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
 ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
in
pkgs.mkShell {
  buildInputs = [ pkgs.opam pkgs.pkg-config ocamlPackages.utop ocamlPackages.ocaml-lsp ];
  shellHook = ''
    export NVIM_OCAML_LSP=true
    eval $(opam env)
  '';
}
