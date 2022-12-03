{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
 # choose the ocaml version you want to use
 ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
in
pkgs.mkShell {
  nativeBuildInputs = with ocamlPackages; [ ocaml-lsp ];
  buildInputs = [ pkgs.opam pkgs.pkg-config ocamlPackages.utop ];
  # dune utop lib
  # dune build
  # dune exec ./bin/main.exe
  shellHook = ''
    export NVIM_OCAML_LSP=true
    eval $(opam env)
  '';
}
