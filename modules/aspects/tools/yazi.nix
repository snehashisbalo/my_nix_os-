{ ... }:
{
  den.aspects.tools.yazi = {
    homeManager =
      { pkgs, lib, ... }:
      {
        programs.yazi = {
          enable = true;
          enableFishIntegration = true;
          enableBashIntegration = true;
          settings = {
            mgr = {
              show_hidden = true;
              sort_by = "natural";
              sort_dir_first = true;
              linemode = "size";
            };
            preview = {
              image_filter = "lanczos3";
              max_width = 1200;
              max_height = 1200;
            };
            # The flavour itself is rendered by the Noctalia user template
            # "yazi" into flavors/noctalia.yazi/flavor.toml, so the colours
            # follow `theme-set`. Nothing else about yazi is themed here.
            flavor = {
              dark = "noctalia";
              light = "noctalia";
            };
          };
        };
      };
  };
}
