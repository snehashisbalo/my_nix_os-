{ ... }:
{
  den.aspects.workstation.wm.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        # Ships Noto Sans Bengali + Noto Serif Bengali (verified in
        # /nix/store/*-noto-fonts-*/share/fonts/noto/Noto* Bengali*).
        noto-fonts
      ];

      # Bengali (bn) renders with Noto Sans Bengali / Noto Serif Bengali.
      # `defaultFonts` covers the generic lookup; `localConf` (higher
      # priority than `defaultFonts`) pins `:lang=bn` with a strong
      # binding so it still wins when the theme aliases sans-serif onto
      # JetBrainsMono (which has no Bengali glyphs).
      fonts.fontconfig = {
        defaultFonts = {
          sansSerif = [
            "Noto Sans"
            "Noto Sans Bengali"
          ];
          serif = [
            "Noto Serif"
            "Noto Serif Bengali"
          ];
        };
        localConf = ''
          <match target="pattern">
            <test name="lang" compare="contains">
              <string>bn</string>
            </test>
            <test name="family"><string>sans-serif</string></test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans Bengali</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="lang" compare="contains">
              <string>bn</string>
            </test>
            <test name="family"><string>serif</string></test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Serif Bengali</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="lang" compare="contains">
              <string>bn</string>
            </test>
            <test name="family"><string>monospace</string></test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans Bengali</string>
            </edit>
          </match>
        '';
      };
    };
  };
}
