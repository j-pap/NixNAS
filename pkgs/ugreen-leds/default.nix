{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  smartmontools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ugreen-leds";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "miskcoo";
    repo = "ugreen_leds_controller";
    rev = "0c4b19d397306bd96f69dd838c463db5781f95ea";
    hash = "sha256-33ZQ8wMEiOHIo0/88wIWq9my6N0bDK8GczJlajzWTlM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ smartmontools ];

  postPatch = ''
    substituteInPlace cli/Makefile --replace-warn "-static" "-shared-libgcc"
    substituteInPlace scripts/ugreen-diskiomon --replace-warn "/usr/sbin/smartctl" "${lib.getExe' smartmontools "smartctl"}"
  '';

  buildPhase = ''
    runHook preBuild

    make -C cli
    g++ -std=c++17 -O2 scripts/blink-disk.cpp -o scripts/ugreen-blink-disk
    g++ -std=c++17 -O2 scripts/check-standby.cpp -o scripts/ugreen-check-standby

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    chmod +x scripts/ugreen-power-led
    cp cli/ugreen_leds_cli $out/bin/ugreen_leds_cli
    cp -r scripts/ugreen-* $out/bin && rm $out/bin/ugreen-leds.conf

    runHook postInstall
  '';

  meta = {
    description = "Binary for UGREEN's DX/DXP NAS Series LED controller";
    homepage = "https://github.com/miskcoo/ugreen_leds_controller";
    license = lib.licenses.mit;
    mainProgram = "ugreen_leds_cli";
    maintainers = with lib.maintainers; [ j-pap ];
    platforms = lib.platforms.linux;
  };
})
