{ inputs, ... }:
{
  den.aspects.tools.noctalia = {
    homeManager =
      { pkgs, config, ... }:
      {
        # NOTE: home-manager now ships `programs.noctalia` upstream, so the
        # module is not imported from the noctalia flake (importing it here
        # would redeclare every option). The flake is still used for the
        # patched package below.
        programs.noctalia = {
          enable = true;

          package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
            src = pkgs.applyPatches {
              src = old.src;
              patches = [ ../../../patches/noctalia-bar-capsule-blur.patch ];
            };
          });

          settings = {
            backdrop.enabled = false;

            # Dynamic Material-You theming: noctalia derives the palette from the
            # displayed wallpaper and re-renders the enabled app templates.
            # customPalettes.Nullscapes stays defined below as a manual fallback
            # (switch source back to "custom" to use it).
            # Palette selection is owned by `theme-set` (see
            # modules/aspects/workstation/theme). These values are only the
            # starting point; `[theme.templates]` now lives in
            # ~/.config/noctalia/templates.toml so it is not shadowed by the
            # GUI-managed settings.toml overlay.
            theme = {
              mode = "dark";
              source = "builtin";
              builtin = "Noctalia";
              wallpaper_scheme = "m3-content";
            };

            wallpaper = {
              enabled = true;
              fill_mode = "crop";
              directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
              transition = [ "fade" "wipe" "disc" "stripes" "zoom" "honeycomb" ];
              transition_duration = 1500;
              transition_on_startup = true;
              default.path = "${../../../assets/wallpapers/nullscapes.png}";
            };
            shell = {
              corner_radius_scale = 0.88;
              font_family = "JetBrainsMono Nerd Font";

              # Clipboard history: enabled, selecting an entry only copies
              # it to the clipboard (paste separately with Super+V), no auto-paste.
              clipboard_enabled = true;
              clipboard_auto_paste = "off";

              # Minimal launcher: no category chips, package-origin
              # indicators, or desktop actions. Icons and usage-frequency
              # sorting stay enabled by default.
              launcher = {
                categories = false;
                show_app_origin_indicator = false;
                show_app_actions = false;
              };

              panel = {
                transparency_mode = "soft";
                borders = true;
                shadow = true;
              };
              screenshot = {
                freeze_screen = true;
                pipe_to_command = true;
                pipe_command = "${pkgs.satty}/bin/satty --filename - --fullscreen --output-filename ${config.home.homeDirectory}/Pictures/Screenshots/Screenshot-%Y-%m-%d_%H-%M-%S.png";
                save_to_file = false;
                copy_to_clipboard = false;
              };
            };
            bar.main = {
              thickness = 40;
              background_opacity = 0.0;
              shadow = false;
              contact_shadow = false;
              margin_ends = 18;
              margin_edge = 10;
              padding = 6;
              widget_spacing = 8;
              capsule = false;
              start = [ "group:lunar" ];
              center = [ "group:pulse" ];
              end = [ "group:signal" ];
              capsule_group = [
                {
                  id = "lunar";
                  members = [ "launcher" "wallpaper" "workspaces" "clock" ];
                  fill = "surface_variant";
                  border = "outline";
                  foreground = "on_surface";
                  padding = 10;
                  radius = 16;
                  opacity = 0.58;
                  widget_spacing = 8;
                }
                {
                  id = "pulse";
                  members = [ "audio_visualizer" "media" "audio_visualizer" ];
                  fill = "surface_variant";
                  border = "outline";
                  foreground = "on_surface";
                  padding = 12;
                  radius = 16;
                  opacity = 0.64;
                  widget_spacing = 8;
                }
                {
                  id = "signal";
                  members = [ "tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session" ];
                  fill = "surface_variant";
                  border = "outline";
                  foreground = "on_surface";
                  padding = 10;
                  radius = 16;
                  opacity = 0.58;
                  widget_spacing = 8;
                }
              ];
            };
            widget.audio_visualizer = {
              width = 56;
              bands = 20;
              mirrored = true;
              reversed = false;
              centered = true;
              show_when_idle = false;
              color_1 = "primary";
              color_2 = "tertiary";
            };
            osd = {
              position = "top_center";
              orientation = "horizontal";
              scale = 1.0;
              background_opacity = 0.85;
              offset_y = 14;
              kinds = {
                volume = true;
                volume_output = true;
                volume_input = true;
                brightness = true;
                wifi = true;
                bluetooth = true;
              };
            };
          };

          customPalettes.Nullscapes.dark = {
            mPrimary = "#678FE4";
            mOnPrimary = "#181C25";
            mSecondary = "#715CD6";
            mOnSecondary = "#EEF4FF";
            mTertiary = "#AB66CC";
            mOnTertiary = "#181B24";
            mError = "#FD4663";
            mOnError = "#181C25";
            mSurface = "#141B29";
            mOnSurface = "#F2F2F3";
            mSurfaceVariant = "#1B2437";
            mOnSurfaceVariant = "#AFB1B6";
            mOutline = "#616771";
            mShadow = "#141B29";
            mHover = "#283653";
            mOnHover = "#F2F2F3";
            terminal = {
              background = "#080B16";
              foreground = "#E8EDFF";
              cursor = "#A8B7FF";
              cursorText = "#090C18";
              selectionBg = "#344879";
              selectionFg = "#FFFFFF";
              normal = {
                black = "#080B16";
                red = "#E8758D";
                green = "#79B9B5";
                yellow = "#C8CBE6";
                blue = "#6480D7";
                magenta = "#8A91E8";
                cyan = "#82B8E8";
                white = "#E8EDFF";
              };
              bright = {
                black = "#46516F";
                red = "#FF91A5";
                green = "#A0D8CF";
                yellow = "#F1F3FF";
                blue = "#829AFF";
                magenta = "#B2BBFF";
                cyan = "#AED8FF";
                white = "#FFFFFF";
              };
            };
          };
        };

        # Seed a default wallpaper so the wallpaper-driven palette has an image
        # to sample on first login; the picker reads the whole directory.
        home.file."Pictures/Wallpapers/nullscapes.png".source =
          ../../../assets/wallpapers/nullscapes.png;
      };
  };
}
