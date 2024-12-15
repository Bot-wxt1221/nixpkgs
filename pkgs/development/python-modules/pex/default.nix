{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pytest,
  pythonOlder,
  pytest-xdist,
  coloredlogs,
  ansicolors,
  psutil,
  pexpect,
  pycodestyle,
}:

buildPythonPackage rec {
  pname = "pex";
  version = "2.27.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tUqt4u9tkYAyVBjHw0ABuWbBSlo28FHEGGWPoVy7Vk4=";
  };

  dependencies = [
    ansicolors
    coloredlogs
    pexpect
    psutil
  ];

  build-system = [ setuptools ];

  nativeCheckInputs = [
    pycodestyle
    pytest
    pytest-xdist
  ];

  postPatch = ''
    substituteInPlace testing/bin/run_tests.py \
      --replace-fail 'subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).decode("ascii").strip()' "\"$PWD\"" \
      --replace-fail '"pytest"' '"pytest","--deselect=test_present_non_empty_namespace_packages_metadata_does_warn"'  # Need twitter-common-lang"
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    python testing/bin/run_tests.py -vss

    runHook postInstallCheck
  '';

  pythonImportsCheck = [ "pex" ];

  meta = {
    description = "Python library and tool for generating .pex (Python EXecutable) files";
    homepage = "https://github.com/pantsbuild/pex";
    changelog = "https://github.com/pantsbuild/pex/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      copumpkin
      phaer
    ];
  };
}
