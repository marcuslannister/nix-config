{ lib, stdenvNoCC }:

# COLR v0 TTF built from microsoft/fluentui-emoji Flat SVGs with nanoemoji.
# Vendored: a live rebuild of ~3000 SVGs is too slow for darwin-rebuild.
stdenvNoCC.mkDerivation {
  pname = "fluent-emoji-flat";
  version = "0.1.0";
  src = ./FluentEmojiFlat.ttf;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" "$out/share/fonts/truetype/FluentEmojiFlat.ttf"
    runHook postInstall
  '';
  meta = {
    description = "Fluent Emoji Flat COLR font for Kitty";
    homepage = "https://github.com/microsoft/fluentui-emoji";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
