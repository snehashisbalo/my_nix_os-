{ ... }:
{
  den.aspects.terminals.kitty = {
    homeManager = {
      programs.kitty = {
        enable = true;

        # Colours come from Noctalia's wallpaper-derived palette (builtin
        # template "kitty"), written at runtime to themes/noctalia.conf.
        extraConfig = "include themes/noctalia.conf";

        settings = {
          # keyd turns Super+C / Super+V into Ctrl+Insert / Shift+Insert for
          # every app; by default those keys hit kitty's PRIMARY-selection
          # bindings, so remap them to the clipboard explicitly. The stock
          # Ctrl+Shift+C/V are kept. (Written as `map ...` directives because
          # this HM snapshot has no programs.kitty.keymaps option.)
          "map ctrl+insert" = "copy_to_clipboard";
          "map shift+insert" = "paste_from_clipboard";

          font_family = "JetBrainsMono Nerd Font";
	  font_size = "20.0";
          cursor_shape = "block";
          cursor_blink_interval = "0.5";
          mouse_hide_wait = "2.0";
          confirm_os_window_close = "0";
          background_opacity = "0.85";
        };
      };
    };
  };
}
