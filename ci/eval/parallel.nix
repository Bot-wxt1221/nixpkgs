{
  lib ? import ../../lib,
  path ? ../..,
  attrpathFile,
  chunkSize,
  myChunk,
  checkMeta,
  includeBroken,
  systems,
}:

let
  attrpaths = lib.importJSON attrpathFile;
  myAttrpaths = lib.sublist (chunkSize * myChunk) chunkSize attrpaths;

  unfiltered = import ../../pkgs/top-level/release-outpaths.nix {
    inherit path;
    inherit checkMeta includeBroken systems;
  };

  filtered =
    let
      recurse =
        index: paths: attrs:
        lib.mapAttrs (
          name: values:
          if attrs ? ${name} then
            if lib.any (value: lib.length value <= index + 1) values then
              attrs.${name}
            else
              recurse (index + 1) values attrs.${name}
          else
            null
        ) (lib.groupBy (a: lib.elemAt a index) paths);
    in
    recurse 0 myAttrpaths unfiltered;

  recurseEverywhere =
    val:
    if lib.isDerivation val || !(lib.isAttrs val) then
      val
    else
      (lib.mapAttrs (_: v: recurseEverywhere v) val) // { recurseForDerivations = true; };

in
recurseEverywhere filtered
