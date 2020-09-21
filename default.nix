let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "relatively-cool";
  buildInputs = [
    pkgs.nodejs
  ];
}
