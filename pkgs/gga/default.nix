{ lib
, stdenvNoCC
, makeWrapper
, bash
, coreutils
, curl
, findutils
, git
, gnugrep
, gnused
, procps
, python3
}:

stdenvNoCC.mkDerivation {
  pname = "gga";
  version = "2.10.1";

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${./gga} "$out/bin/gga"
    install -Dm644 ${./lib/cache.sh} "$out/lib/gga/cache.sh"
    install -Dm644 ${./lib/pr_mode.sh} "$out/lib/gga/pr_mode.sh"
    install -Dm644 ${./lib/providers.sh} "$out/lib/gga/providers.sh"
    patchShebangs "$out/bin/gga"
    wrapProgram "$out/bin/gga" \
      --prefix PATH : ${lib.makeBinPath [
        bash
        coreutils
        curl
        findutils
        git
        gnugrep
        gnused
        procps
        python3
      ]}

    runHook postInstall
  '';

  meta = {
    description = "Provider-agnostic AI code review CLI";
    homepage = "https://github.com/Gentleman-Programming/gentleman-guardian-angel";
    license = lib.licenses.mit;
    mainProgram = "gga";
    platforms = lib.platforms.unix;
  };
}
