{ ... }:
{
  den.aspects.tools.system = {
    homeManager =
      { pkgs, ... }:
      {
        # No `programs.fastfetch`: the whole config is rendered by the Noctalia
        # user template "fastfetch" into ~/.config/fastfetch/config.jsonc, so
        # the section colours follow `theme-set`. Home Manager only drops the
        # logo the template points at.
        home.packages = with pkgs; [ fastfetch ];

        xdg.configFile."fastfetch/easy.png".source = ../../../assets/fastfetch/Easy.png;

        programs.bat = {
          enable = true;
          config = {
            # base16-256 maps to the terminal's ANSI colours, which Noctalia
            # sets per theme (see the "terminal-sequences" template), so bat
            # follows the palette without carrying its own theme file.
            theme = "base16-256";
            pager = "less -FR";
          };
        };

        programs.eza = {
          enable = true;
          enableFishIntegration = true;
          icons = "auto";
          git = true;
          extraOptions = [
            "--group-directories-first"
            "--header"
          ];
        };

        programs.fzf = {
          enable = true;
          enableFishIntegration = true;
        };

        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
  };
}
