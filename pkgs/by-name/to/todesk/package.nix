{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, gzip
, gnutar
, nspr
, kmod
, systemdMinimal
, glib
, libX11
, libXrandr
, glibc
, libdrm
, libGL
, libXcomposite
, libXdamage
, libXfixes
, libXtst
, nss
, libXxf86vm
, gtk3
, gdk-pixbuf
, pango
, appindicator-sharp
}:

stdenv.mkDerivation rec {
  pname = "todesk";
  version = "4.7.2.0";

  src = fetchurl {
    url = "https://github.com/Bot-wxt1221/Bot-wxt1221-NvChad/releases/download/temp/todesk-v4.7.2.0-amd64.deb";
    sha256 = "sha256-v7VpXXFVaKI99RpzUWfAc6eE7NHGJeFrNeUTbVuX+yg=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [
   nspr
   kmod
   systemdMinimal
   glib
   libX11
   libXrandr
   glibc
   libdrm
   libGL
   libXcomposite
   libXdamage
   libXfixes
   libXtst
   nss
   libXxf86vm
   gtk3
   gdk-pixbuf
   pango
   appindicator-sharp
  ];

  autoPatchelfIgnoreMissingDeps = [ "iHD_drv_video.so" "libglut.so" "libigdgmm.so" "libmfx.so" "libmfxhw64.so" "libva.so" "libva-drm.so" "libva-x11.so" "libzrtc.so" ];

  unpackPhase = ''
    runHook preUnpack

    dpkg -x $src ./todesk-src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    mkdir -p $out/lib
    cp -r todesk-src/* "$out"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Remote Desktop Application";
    homepage = "https://www.todesk.com/linux.html";
    license = licenses.unfree;
    platforms = with platforms; [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ Bot-wxt1221 ];
    mainProgram = "ToDesk";
  };
}
