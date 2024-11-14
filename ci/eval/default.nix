{
  lib,
  runCommand,
  writeShellScript,
  linkFarm,
  time,
  procps,
  nix,
  jq,
}:

let
  nixpkgs =
    with lib.fileset;
    toSource {
      root = ../..;
      fileset = unions (
        map (lib.path.append ../..) [
          "default.nix"
          "doc"
          "lib"
          "maintainers"
          "nixos"
          "pkgs"
          ".version"
          "ci/eval/parallel.nix"
        ]
      );
    };

  supportedSystems = import ../supportedSystems.nix;

  attrpathsSuperset =
    runCommand "attrpaths-superset.json"
      {
        src = nixpkgs;
        nativeBuildInputs = [
          nix
        ];
        env.supportedSystems = builtins.toJSON supportedSystems;
        passAsFile = [ "supportedSystems" ];
      }
      ''
        export NIX_STATE_DIR=$(mktemp -d)
        mkdir $out
        nix-instantiate --eval --strict --json --arg enableWarnings false $src/pkgs/top-level/release-attrpaths-superset.nix -A paths > $out/paths.json
        mv "$supportedSystemsPath" $out/systems.json
      '';

  singleSystem =
    {
      evalSystem,
      attrpathFile,
      checkMeta ? true,
      includeBroken ? true,
      # How many attributes to be evaluating at any single time.
      # This effectively limits the maximum memory usage.
      # Decrease this if too much memory is used
      simultaneousAttrsPerSystem ? 100000,
      quickTest ? false,
    }:
    let
      singleChunk = writeShellScript "chunk" ''
        set -euo pipefail
        chunkSize=$1
        myChunk=$2
        outputDir=$3
        system=$4

        nix-env -f "${nixpkgs}/ci/eval/parallel.nix" \
          --query --available \
          --no-name --attr-path --out-path \
          --show-trace \
          --arg chunkSize "$chunkSize" \
          --arg myChunk "$myChunk" \
          --arg attrpathFile "${attrpathFile}" \
          --arg systems "[ \"$system\" ]" \
          --arg checkMeta ${lib.boolToString checkMeta} \
          --arg includeBroken ${lib.boolToString includeBroken} \
          > "$outputDir/$myChunk"
      '';
    in
    runCommand "nixpkgs-eval-${evalSystem}"
      {
        nativeBuildInputs = [
          nix
          time
          procps
          jq
        ];
        env = {
          inherit evalSystem;
        };
      }
      ''
        set -x
        export NIX_STATE_DIR=$(mktemp -d)
        nix-store --init

        echo "System: $evalSystem"
        cores=$NIX_BUILD_CORES
        echo "Cores: $cores"
        num_attrs=$(jq length "${attrpathFile}")
        echo "Attribute count: $num_attrs"
        chunk_size=$(( ${toString simultaneousAttrsPerSystem} / cores ))
        echo "Chunk size: $chunk_size"
        # Same as `num_attrs / chunk_size` but rounded up
        num_chunks=$(( (num_attrs - 1) / chunk_size + 1 ))
        echo "Chunk count: $num_chunks"

        (
          while true; do
            free -g
            sleep 20
          done
        ) &

        seq_end=$(( num_chunks - 1 ))

        ${lib.optionalString quickTest ''
          seq_end=0
        ''}

        chunkOutputDir=$(mktemp -d)
        seq -w 0 "$seq_end" |
          command time -v xargs -t -I{} -P"$cores" \
          ${singleChunk} "$chunk_size" {} "$chunkOutputDir" "$evalSystem"

        mkdir $out
        cat "$chunkOutputDir"/* > $out/paths
      '';

  combine =
    {
      resultsDir,
    }:
    runCommand "combined-result"
      {
        nativeBuildInputs = [
          jq
        ];
        passAsFile = [ "jqScript" ];
        jqScript = # jq
          ''
            split("\n") |
            map(select(. != "") | split(" ") | map(select(. != ""))) |
            map(
              {
                key: .[0],
                value: .[1] | split(";") | map(split("=") |
                  if length == 1 then
                    { key: "out", value: .[0] }
                  else
                    { key: .[0], value: .[1] }
                  end) | from_entries}
            ) | from_entries
          '';
      }
      ''
        mkdir -p $out
        cat ${resultsDir}/*/paths |
          jq --sort-keys --raw-input --slurp -f "$jqScriptPath" \
          > $out/outpaths.json
      '';

  together =
    {
      quickTest ? false,
    }:
    let
      systems = if quickTest then [ "x86_64-linux" ] else supportedSystems;
      results = linkFarm "results" (
        map (system: {
          name = system;
          path = singleSystem {
            system = system;
            attrpathFile = attrpathsSuperset + "/paths.json";
            inherit quickTest;
          };
        }) systems
      );
      final = combine {
        resultsDir = results;
      };
    in
    final;

in
{
  inherit
    attrpathsSuperset
    singleSystem
    combine
    together
    ;
}
