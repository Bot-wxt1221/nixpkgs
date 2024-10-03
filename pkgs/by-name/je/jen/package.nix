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

  cargoHash = "sha256-Nia5SsmxdBrWO4zmkoi0gCmknkhwsM8PZ52aPVMnp90=";

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
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
