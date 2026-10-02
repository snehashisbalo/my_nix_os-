{ ... }:
{
  den.aspects.workstation.wm.keyd = {
    nixos = {
      # Universal clipboard keys BELOW the compositor (Omarchy muscle memory on
      # niri). niri cannot inject a shortcut into the focused window, and
      # wtype/ydotool would leak the still-held Super into the app. keyd sits
      # between the kernel and the compositor, so apps receive a plain
      # Ctrl+Insert / Shift+Insert:
      #
      #   Super+C -> Ctrl+Insert   (copy; kitty maps it to the clipboard)
      #   Super+V -> Shift+Insert  (paste; kitty maps it to the clipboard)
      #   Super+X -> Ctrl+X        (cut; terminals are the accepted exception)
      #
      # All other Super combos pass through untouched: the stock [meta] layer
      # keeps every unlisted key bound to itself, and the [meta+control]
      # composite layer (defined AFTER its constituents, per keyd(1)) only
      # pins v, so Super+Ctrl+V still reaches niri as Mod+Ctrl+V for the
      # clipboard-history panel. Super alone also still reaches niri binds.
      #
      # Panic exit if the keyboard dies: hold Backspace+Escape+Enter (keyd
      # terminates). Roll back with: sudo systemctl disable --now keyd
      services.keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings = {
            main = {
              meta = "layer(meta)"; # explicit: everything else passes through
            };
            meta = {
              c = "C-insert";
              v = "S-insert";
              x = "C-x";
            };
          };
          extraConfig = ''
            # Composite layers must come after the layers they comprise.
            # Keep Super+Ctrl+V reachable by niri (clipboard history) instead
            # of letting it collapse into the Ctrl+Shift+Insert paste.
            [meta+control]
            v = M-C-v
          '';
        };
      };
    };
  };
}
