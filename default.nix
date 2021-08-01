with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "valauncher";
  version = "0.1.0.0";
  src = ./.;
  buildInputs = [
    gnome3.libgee
    gtk3
    pcre
  ];
  nativeBuildInputs = [ vala cmake pkg-config ];
}
