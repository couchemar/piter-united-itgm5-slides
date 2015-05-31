let pkgs = import <nixpkgs> {}; in

{ stdenv ? pkgs.stdenv,
  hovercraft ? pkgs.python34Packages.hovercraft,
  chromium ? pkgs.chromium,
  strings ? pkgs.lib.strings }:

let

  readAndIndentSources = file: strings.concatStringsSep "\n    " (
      strings.splitString "\n" (builtins.readFile file));
in
  stdenv.mkDerivation rec {
    version = "0.0.1";
    name = "itgm5-python-nix-slides-${version}";
    src = ./.;

    web_math_run_py = readAndIndentSources(./web_math/run.py);
    web_math_default_nix = readAndIndentSources(./web_math/default.nix);
    my_math_init_py = readAndIndentSources(./my_math/my_math/__init__.py);
    my_math_default_nix = readAndIndentSources(./my_math/default.nix);
    my_math2_init_py = readAndIndentSources(./my_math2/my_math/__init__.py);
    my_math2_default_nix = readAndIndentSources(./my_math2/default.nix);

    installPhase = ''
    substituteAll slides.rst _slides.rst
    ${hovercraft}/bin/hovercraft _slides.rst $out
    echo "${chromium}/bin/chromium --incognito $out/index.html" >> $out/run
    '';
  }
