{ 
  pythonPackages, 
  numpy ? pythonPackages.numpy
}:

pythonPackages.buildPythonPackage {
  name = "my-math";
  src = ./.;
  propagatedBuildInputs = [ numpy ];
}
