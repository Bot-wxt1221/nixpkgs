{
  lib,
  rustPlatform,
  fetchCrate,
  stdenv,
  darwin,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "jen";
  version = "1.7.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-nouAHEo5JJtZ0pV8ig/iJ3eB8uPz3yMVIYP6RrNVlSA=";
  };

  cargoHash = "sha256-Y81YqrzJSar0BxhQb7Vm/cZ9E6krlyZesXPY+j37IHA=";

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoPatches = [
    ./0001-update-time.patch
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple CLI generation tool for creating large datasets";
    mainProgram = "jen";
    homepage = "https://github.com/whitfin/jen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ figsoda ];
  };
}
