with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "valauncher";
  version = "0.1.0.0";
  src = ./.;
  buildInputs = [ vala cmake pkgconfig gnome3.libgee gtk3 ];
}
