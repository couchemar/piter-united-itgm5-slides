{
  pythonPackages ? (import <nixpkgs> {}).pythonPackages,
  tornado ? pythonPackages.tornado_3,
  my-math ? import ../my_math {inherit pythonPackages;}
}:

pythonPackages.buildPythonPackage {
   name = "web_math";
   src = ./.;

   buildInputs = [ tornado my-math ];
}
