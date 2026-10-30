{ ... }:
{
  den.aspects.tools.atuin = {
    homeManager = { ... }: {
      programs.atuin = {
        enable = true;
        enableFishIntegration = true;

        settings = {
          # Local-only history; no account is configured.
          auto_sync = false;
          update_check = false;
          search_mode = "fuzzy";
        };
      };
    };
  };
}
