{
  buildGoModule,
  lib,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync";
  version = "0.5.19";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "any-sync";
    rev = "refs/tags/v${version}";
    hash = "sha256-oES/HSWPTQT1gsSA88dbS0+tTtUiozUVhNI4mnQg1Xc=";
  };

  vendorHash = "sha256-az30eFqJ77j5O+/PFIFEs9vNDz5DzdC7jJzug4P86i4=";

  meta = {
    homepage = "https://anytype.io/";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    description = "Open-source protocol designed to create high-performance, local-first, peer-to-peer, end-to-end encrypted applications that facilitate seamless collaboration among multiple users and devices";
    mainProgram = "";
    license = lib.licenses.mit;
  };
}
