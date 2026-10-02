{ ... }:
{
  den.aspects.terminals.ghostty = {
    homeManager = { pkgs, ... }: {
      programs.ghostty = {
        enable = true;
        settings = {
          # Colours come from Noctalia's wallpaper-derived palette (builtin
          # template "ghostty"), written at runtime to themes/noctalia.
          theme = "noctalia";
          font-family = "JetBrainsMono Nerd Font";
          window-width = 96;
          window-height = 25;
          window-save-state = "never";
          window-padding-x = 14;
          window-padding-y = 12;
          window-padding-balance = true;
          cursor-style = "bar";
          cursor-style-blink = true;
          mouse-hide-while-typing = true;
          window-decoration = false;
          background-opacity = 0.76;
          background-blur-radius = 20;
          confirm-close-surface = "false";
          command = "fish";
        };
      };
    };
  };
}
