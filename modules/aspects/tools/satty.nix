{ ... }:
{
  den.aspects.tools.satty = {
    homeManager = { pkgs, ... }: {
      programs.satty = {
        enable = true;
        settings = {
          general = {
            fullscreen = true;
            early-exit = true;
            copy-command = "wl-copy";
            corner-roundness = 16;
            initial-tool = "arrow";
          };
          font = {
            family = "JetBrainsMono Nerd Font";
            style = "bold";
          };
        };
      };
    };
  };
}
