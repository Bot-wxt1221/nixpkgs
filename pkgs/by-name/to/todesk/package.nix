{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, gzip
, gnutar
}:
stdenv.mkDerivation rec {
  pname = "todesk";
  version = "4.7.2.0";

  src = fetchurl {
    url = "https://dl.todesk.com/linux/todesk-v4.7.2.0-amd64.deb";
    sha256 = "sha256-v7VpXXFVaKI99RpzUWfAc6eE7NHGJeFrNeUTbVuX+yg=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook];

  unpackPhase = ''
    runHook preUnpack
    dpkg -x $src ./todesk
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -pv $out
    cp -r ./todesk/* "$out"

    runHook postInstall
  '';


  meta = with lib; {
    description = "Remote control and team work";
    homepage = "https://www.todesk.com/linux.html";
    license = licenses.unfree;
    platforms = with platforms; [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ Bot-wxt1221 ];
    mainProgram = "ToDesk";
  };
}

