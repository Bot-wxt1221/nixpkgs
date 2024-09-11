{
  meta,
  src,
  version,
  nodejs,
  stdenv,
  buildNpmPackage
}:

buildNpmPackage rec{
  inherit meta src version;
  pname = "yaak-webui";

  npmDepsHash = "";

  buildPhase = ''
    runHook preBuild

    node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

    runHook postBuild
  '';
}
