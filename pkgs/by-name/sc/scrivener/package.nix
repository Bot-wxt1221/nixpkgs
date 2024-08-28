{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  buildFHSEnv,
  cups,
  libX11,
  libz,
  libpng12,
  xorg,
  gst_all_1,
}:
let
  pname = "scrivener";
  version = "1.9.0.1";
  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version;

    src = fetchurl {
      url = "http://www.literatureandlatte.com/scrivenerforlinux/scrivener-${version}-amd64.deb";
      hash = "sha256-qmz5kvDPn1CTXULA3yYllBG3EjJRxrquqU3g5AtHzdw=";
    };

    nativeBuildInputs = [
      dpkg
    ];

    unpackPhase = ''
      runHook preUnpack

      dpkg -x $src .

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/* $out

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  inherit pname version;

  targetPkgs =
    pkgs:
    ([
      unwrapped
      cups
      libX11
      libz
      libpng12
    ])
    ++ (with xorg; [
      libXrender
    ]);

  runScript = "scrivener";
  meta = with lib; {
    license = licenses.unfree;
    description = "Scrivener is the go-to app for writers of all kinds, used every day by best-selling novelists, screenwriters, non-fiction writers, students, academics, lawyers, journalists, translators and more.";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ bot-wxt1221 ];
    homepage = "https://www.literatureandlatte.com/scrivener/overview";
  };
}
