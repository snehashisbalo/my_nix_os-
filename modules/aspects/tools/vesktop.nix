{ ... }:
{
  den.aspects.tools.vesktop = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [ vesktop ];

        # The palette lives in the Noctalia user template "vesktop", rendered to
        # vesktop/themes/noctalia.theme.css. quickCss is always applied, so this
        # one import is enough to make Vesktop follow `theme-set` live.
        xdg.configFile."vesktop/settings/quickCss.css" = {
          force = lib.mkForce true;
          text = ''@import url("../themes/noctalia.theme.css");'';
        };
      };
  };
}
