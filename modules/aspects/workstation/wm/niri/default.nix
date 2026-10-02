{ ... }:
{
  den.aspects.workstation.wm.niri = {
    nixos =
      { pkgs, ... }:
      {
        programs.niri.enable = true;
      };

    homeManager =
      { pkgs, lib, ... }:
      let
        # Niri autostart: environment variables + background daemons (Noctalia).
        autostart = pkgs.writeShellScript "niri-autostart" ''
          # 1. Silence the 25-second D-Bus accessibility timeout
          export NO_AT_BRIDGE=1

          # Cursor comes from the active theme (written by theme-runtime-apply).
          # Falls back to the Catppuccin cursor the rice shipped with before the
          # runtime theme system existed.
          STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/theme"
          export XCURSOR_THEME="$(cat "$STATE_DIR/cursor-theme" 2>/dev/null || true)"
          [ -n "$XCURSOR_THEME" ] || export XCURSOR_THEME="catppuccin-mocha-dark-cursors"
          export XCURSOR_SIZE=20

          # 2. Forward Wayland and cursor variables to D-Bus and systemd
          dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=niri DISPLAY XCURSOR_THEME XCURSOR_SIZE
          systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XCURSOR_THEME XCURSOR_SIZE

          # 3. Background daemons, DMS and wallpaper. xsettingsd bridges the GTK
          #    settings theme-runtime-apply writes to toolkits that read XSettings.
          pgrep -x wl-clip-persist >/dev/null || wl-clip-persist --clipboard regular &
          pgrep -x xwayland-satellite >/dev/null || xwayland-satellite &
          pgrep -x xsettingsd >/dev/null || xsettingsd &
          pgrep -x noctalia >/dev/null || noctalia &
        '';
      in
      {
        # xwayland-satellite comes from the pinned nixpkgs-satellite
        # (see workstation/wm/graphical.nix).
        home.packages = with pkgs; [
          wl-clip-persist
        ];

        wayland.windowManager.niri = {
          enable = true;
          package = null;
          systemd.enable = false;
          xwaylandSatellitePackage = null;
          portalPackage = null;
          checkConfig = false;
          extraConfig = # kdl
            ''
              // Launch the unified autostart script
              spawn-at-startup "~/.config/niri/autostart.sh"

              // ==========================================================
              //                   Monitor settings
              // ==========================================================
              // Built-in laptop panel (see `niri msg outputs`).
              output "eDP-1" {
                  mode "1920x1080@59.96"
                  scale 1.0
              }

              hotkey-overlay {
                  skip-at-startup
              }

              screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

              // Soft, moderate blur (smaller radius and fewer passes)
              blur {
                  passes 2
                  offset 1.5
              }

              overview {
                  backdrop-color "#080B16dd"
                  workspace-shadow {
                      on
                  }
              }

              animations {
                  horizontal-view-movement {
                      spring damping-ratio=0.84 stiffness=820 epsilon=0.0001
                  }
                  window-movement {
                      spring damping-ratio=0.82 stiffness=800 epsilon=0.0001
                  }
                  window-resize {
                      spring damping-ratio=0.80 stiffness=900 epsilon=0.0001
                  }
                  workspace-switch {
                      spring damping-ratio=0.85 stiffness=850 epsilon=0.0001
                  }
                  overview-open-close {
                      spring damping-ratio=0.85 stiffness=800 epsilon=0.0001
                  }
                  screenshot-ui-open {
                      duration-ms 200
                      curve "ease-out-expo"
                  }
                  window-open {
                      duration-ms 200
                      curve "ease-out-expo"
                  }
                  window-close {
                      duration-ms 150
                      curve "ease-out-quad"
                  }
              }

              environment {
                  QT_QPA_PLATFORMTHEME "qt6ct"
              }

              prefer-no-csd

              include "${./input.kdl}"
              include "${./layout.kdl}"
              include "${./window-rules.kdl}"
              include "${./binds.kdl}"

              // Noctalia's wallpaper-derived colours (written at runtime).
              include "noctalia.kdl"

              // Cursor for the active theme (written at runtime by
              // theme-runtime-apply). niri re-reads includes on change, so a
              // `theme-set` updates the cursor without a re-login.
              include "theme.kdl"
            '';
        };
        xdg.configFile."niri/autostart.sh" = {
          source = autostart;
          force = true;
        };

        # Power off screens after 15 minutes idle.
        services.swayidle = {
          enable = true;
          systemdTargets = [ "graphical-session.target" ];
          timeouts = [
            {
              timeout = 900;
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
          ];
        };
      };
  };
}
