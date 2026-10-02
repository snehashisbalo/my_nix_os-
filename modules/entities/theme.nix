{
  lib,
  ...
}:
let
  # A font is only meaningful once a family is chosen; the size is optional and
  # falls back to the global default when null.
  fontType = lib.types.submodule {
    options = {
      family = lib.mkOption {
        type = lib.types.str;
        description = "Font family name, e.g. \"JetBrainsMono Nerd Font\".";
      };
      size = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Point size. null inherits `theme.font.size`.";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = ''
          Package providing the family, installed for every theme that names it.
          Needed because a family that is not in the store cannot be selected at
          runtime. null when the family ships with a package already installed.
        '';
      };
    };
  };

  cursorType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "XCursor theme name, e.g. \"catppuccin-mocha-dark-cursors\".";
      };
      package = lib.mkOption {
        type = lib.types.package;
        description = "Package providing the cursor theme.";
      };
    };
  };

  iconsType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "GTK icon theme name, e.g. \"Papirus-Dark\".";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package providing the icon theme, when it is not already installed.";
      };
    };
  };
in
{
  # `theme` holds *which* palette to select, not the colours themselves.
  # Colours live in Noctalia, which is the single source of truth and
  # re-renders every enabled app template on a change.
  #
  # Fonts, cursor and icons cannot be re-rendered by Noctalia, so `theme-set`
  # writes them into the runtime files apps read (GTK settings.ini, fontconfig,
  # xsettingsd, the niri cursor include). Every package a theme names is built
  # into the store by this module, so switching never needs a rebuild.
  #
  # Declared in the home-manager scope on purpose: every consumer is a
  # `homeManager` class module. den's `den.schema.user` lives on the host-side
  # user entity, whose values are forwarded to `home-manager.users.<name>`, so
  # an option declared there is not visible as `config.theme` inside a
  # homeManager module. Imported by modules/aspects/workstation/theme.
  options.theme = lib.mkOption {
    description = ''
      Named themes selected by `theme-set` / `theme-menu`.

      Supersedes the older static palette keys (`background`, `surface`,
      `accent`, `colors.*`, ...), which nothing read: Noctalia already owns
      colour derivation and re-rendering.
    '';
    type = lib.types.submodule {
      options = {
        # Named, switchable themes consumed by `theme-set` / `theme-menu`.
        themes = lib.mkOption {
          description = "Named themes selectable with `theme-set <name>`.";
          type = lib.types.attrsOf (
            lib.types.submodule (
              { ... }:
              {
                options = {
                  description = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Short label shown in `theme-menu`.";
                  };
                  palette = lib.mkOption {
                    description = "Palette passed to `noctalia msg color-scheme-set`.";
                    type = lib.types.submodule {
                      options = {
                        kind = lib.mkOption {
                          type = lib.types.enum [
                            "builtin"
                            "community"
                            "custom"
                            "wallpaper"
                          ];
                          description = "Palette source, matching Noctalia's `[theme].source`.";
                          default = "builtin";
                        };
                        name = lib.mkOption {
                          type = lib.types.str;
                          description = ''
                            Palette name. For `builtin`: a name from
                            `noctalia theme --list-templates`'s palette catalog,
                            e.g. Ayu, Catppuccin, Dracula, Eldritch, Gruvbox,
                            Kanagawa, Noctalia, Nord, "Rosé Pine", Tokyo-Night.
                            For `community`: a name from the community palette
                            catalog. For `custom`: the palette basename in
                            `~/.config/noctalia/palettes/`.
                          '';
                        };
                      };
                    };
                    default = { };
                  };
                  mode = lib.mkOption {
                    type = lib.types.nullOr (lib.types.enum [ "dark" "light" ]);
                    default = null;
                    description = "Force a mode, or null to leave the current mode alone.";
                  };
                  wallpaper = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = ''
                      Absolute path of a wallpaper to set, or null to leave it
                      alone. A string rather than a path so wallpaper files that
                      live outside the store are not copied into it.
                    '';
                  };
                  font = lib.mkOption {
                    type = lib.types.nullOr fontType;
                    default = null;
                    description = "Per-theme font override; null inherits `theme.font`.";
                  };
                  cursor = lib.mkOption {
                    type = lib.types.nullOr cursorType;
                    default = null;
                    description = "Per-theme cursor override; null inherits `theme.cursor`.";
                  };
                  icons = lib.mkOption {
                    type = lib.types.nullOr iconsType;
                    default = null;
                    description = "Per-theme icon override; null inherits `theme.icons`.";
                  };
                };
              }
            )
          );
          default = { };
        };

        defaultTheme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Theme recorded by the first `home-manager switch`, so
            `theme-current` reports something before a manual switch.
          '';
        };

        # Global defaults, so a theme only spells out what it changes. A theme
        # may override any of these with its own `font` / `cursor` / `icons`.
        font = lib.mkOption {
          type = lib.types.nullOr fontType;
          default = null;
          description = "Default font applied by a theme unless it overrides it.";
        };
        cursor = lib.mkOption {
          type = lib.types.nullOr cursorType;
          default = null;
          description = "Default cursor applied by a theme unless it overrides it.";
        };
        icons = lib.mkOption {
          type = lib.types.nullOr iconsType;
          default = null;
          description = "Default icon theme applied by a theme unless it overrides it.";
        };

        # Post-switch reload hooks: apps that cannot pick up a new palette
        # without being restarted.
        restartApps = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "nautilus -q" ];
          description = ''
            Commands run after a theme change to restart apps that only read
            their colours at startup. Nautilus' `-q` flag is what makes it
            re-read its GTK theme. Set to `[ ]` to disable.
          '';
        };
      };
    };
    default = { };
  };
}
