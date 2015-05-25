{ pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "my-math";
  src = ./.;
}
