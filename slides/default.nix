let pkgs = import <nixpkgs> {}; in

{ stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  pythonPackages ? pkgs.pythonPackages,
  chromium ? pkgs.chromium,
  strings ? pkgs.lib.strings }:

let
  landslide = pythonPackages.buildPythonPackage rec {
    name = "landslide-1.1.3";

    src = fetchurl {
      url = "https://pypi.python.org/packages/source/l/landslide/landslide-1.1.3.tar.gz";
      md5 = "81d0e79bbc748c2fca90d2cbd5f85d06";
    };

    propagatedBuildInputs = with pythonPackages; [
      jinja2
      markdown
      pygments
      docutils
      six
    ];
  };

  readPythonSources = file: strings.concatStringsSep "\n    " (
      strings.splitString "\n" (builtins.readFile file));
in
  stdenv.mkDerivation rec {
    version = "0.0.1";
    name = "itgm5-python-nix-slides-${version}";
    src = ./.;

    buildPhase = ''
    substituteAll $src/slides.md slides.md
    ${landslide}/bin/landslide slides.md
    '';

    installPhase = ''
    mkdir $out/
    cp presentation.html $out/

    echo "${chromium}/bin/chromium --incognito $out/presentation.html" >> $out/run
    '';
  }


