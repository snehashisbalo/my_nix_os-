{ ... }:
{
  den.aspects.shell.starship = {
    homeManager =
      { pkgs, lib, config, ... }:
      {
        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          # No `settings`: the prompt is rendered by the Noctalia user template
          # "starship" into <state>/starship/starship.toml, and STARSHIP_CONFIG
          # points starship at it. Letting home-manager also write
          # ~/.config/starship.toml would just shadow the rendered file.
        };

        # mkForce because programs.starship also defines this variable (pointing
        # at the ~/.config/starship.toml it would otherwise own).
        home.sessionVariables.STARSHIP_CONFIG = lib.mkForce "${config.xdg.stateHome}/starship/starship.toml";
      };
  };
}
