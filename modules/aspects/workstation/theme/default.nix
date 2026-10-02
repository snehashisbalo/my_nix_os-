{
  den,
  ...
}:
{
  den.aspects.workstation.theme = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.theme;

        # `builtins.attrNames` is already sorted, so `theme-set`, `theme-menu`
        # and the usage text all agree on order.
        themeNames = builtins.attrNames cfg.themes;

        stateDir = "${config.xdg.stateHome}/theme";
        configDir = config.xdg.configHome;
        dataDir = config.xdg.dataHome;

        nvimThemeFile = "${config.xdg.stateHome}/nvim/noctalia/theme.lua";
        nvimThemeDir = builtins.dirOf nvimThemeFile;
        oscCacheFile = "${config.xdg.cacheHome}/noctalia/terminal-sequences";
        oscCacheDir = builtins.dirOf oscCacheFile;

        # Font, cursor and icon themes can be defaulted once and overridden per
        # theme, so a named theme only spells out what it changes.
        effFont = t: if t.font != null then t.font else cfg.font;
        effCursor = t: if t.cursor != null then t.cursor else cfg.cursor;
        effIcons = t: if t.icons != null then t.icons else cfg.icons;

        fontFamilyOf =
          t:
          let
            f = effFont t;
          in
          if f == null then "" else f.family;

        fontSizeOf =
          t:
          let
            f = effFont t;
            own = if f == null then null else f.size;
          in
          toString (
            if own != null then
              own
            else if cfg.font != null && cfg.font.size != null then
              cfg.font.size
            else
              10
          );

        cursorNameOf =
          t:
          let
            c = effCursor t;
          in
          if c == null then "" else c.name;

        iconNameOf =
          t:
          let
            i = effIcons t;
          in
          if i == null then "" else i.name;

        # A bash `case` so `theme-set` needs no TOML parser at runtime.
        # Every value is shell-escaped: palette names contain spaces and accents.
        paletteCase = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            n: t:
              "    ${lib.escapeShellArg n})"
              + " kind=${lib.escapeShellArg t.palette.kind};"
              + " name=${lib.escapeShellArg t.palette.name};"
              + " font_family=${lib.escapeShellArg (fontFamilyOf t)};"
              + " font_size=${lib.escapeShellArg (fontSizeOf t)};"
              + " cursor_theme=${lib.escapeShellArg (cursorNameOf t)};"
              + " icon_theme=${lib.escapeShellArg (iconNameOf t)};"
              + lib.optionalString (t.mode != null) " mode=${lib.escapeShellArg t.mode};"
              + lib.optionalString (t.wallpaper != null) " wallpaper=${lib.escapeShellArg "${t.wallpaper}"};"
              + " ;;"
          ) cfg.themes
        );

        validNames = lib.escapeShellArg (lib.concatStringsSep " " themeNames);

        # `theme-menu` shows labels, but `theme-set` takes names, so the menu
        # needs a label -> name mapping. `description` defaults to "", so the
        # fallback checks for empty rather than relying on `or`.
        menuLabel =
          n:
          let
            description = cfg.themes.${n}.description;
          in
          if description == "" then n else description;

        menuLines = lib.concatMapStringsSep "\n" (n: lib.escapeShellArg (menuLabel n)) themeNames;

        menuLabels = map menuLabel themeNames;

        menuCase = lib.concatStringsSep "\n" (
          map (n: "    ${lib.escapeShellArg (menuLabel n)}) theme=${lib.escapeShellArg n} ;;") themeNames
        );

        # Restart commands are joined with newlines: concatenating them without a
        # separator produces `&nohup ...`, which is a bash syntax error.
        restartCommands = lib.concatMapStringsSep "\n" (
          cmd: "nohup ${cmd} >/dev/null 2>&1 &"
        ) cfg.restartApps;

        stateFile = "${stateDir}/current";

        # Built outside the activation string: a `''` string nested inside
        # another `''` string's interpolation is fragile to read.
        seedDefault = lib.optionalString (cfg.defaultTheme != null) (
          "printf '%s\\n' ${lib.escapeShellArg cfg.defaultTheme} >${lib.escapeShellArg stateFile}"
        );

        # Runtime font/cursor/icon values for the default theme, recorded once at
        # activation so `theme-runtime-apply` has something to read before the
        # first manual switch.
        seedExtras =
          let
            t = if cfg.defaultTheme != null then cfg.themes.${cfg.defaultTheme} or null else null;
          in
          lib.optionalString (t != null) ''
            printf '%s\n' ${lib.escapeShellArg (fontFamilyOf t)} >${lib.escapeShellArg "${stateDir}/font-family"}
            printf '%s\n' ${lib.escapeShellArg (fontSizeOf t)} >${lib.escapeShellArg "${stateDir}/font-size"}
            printf '%s\n' ${lib.escapeShellArg (cursorNameOf t)} >${lib.escapeShellArg "${stateDir}/cursor-theme"}
            printf '%s\n' ${lib.escapeShellArg (iconNameOf t)} >${lib.escapeShellArg "${stateDir}/icon-theme"}
            printf '%s\n' ${lib.escapeShellArg (if t.mode != null then t.mode else "dark")} >${lib.escapeShellArg "${stateDir}/mode"}
          '';

        # Template ids are validated at build time, so no TOML escaping is needed.
        templatesToml = lib.concatStringsSep "\n" [
          "# Managed by home-manager: modules/aspects/workstation/theme"
          "#"
          "# Load order is defaults -> ~/.config/noctalia/*.toml ->"
          "# ~/.local/state/noctalia/settings.toml, so the GUI overlay in"
          "# settings.toml still wins. Any template enabled there must be"
          "# disabled in the GUI for this file to be authoritative."
          "[theme.templates]"
          "enable_builtin_templates = true"
          "enable_community_templates = true"
          ""
          "# `niri` writes ~/.config/niri/noctalia.kdl, which the niri config"
          "# already includes. `qt` writes the qt5ct/qt6ct colour scheme files;"
          "# the static qt6ct.conf that points qt6ct at them is managed in Nix."
          "builtin_ids = [ \"niri\", \"kitty\", \"ghostty\", \"gtk3\", \"gtk4\", \"qt\", \"btop\", \"cava\" ]"
          ""
          "# Kept from before the user templates below existed. "
          "community_ids = [ \"opencode\", \"fzf\" ]"
          ""
          "# Apps home-manager owns directly use user templates instead: their"
          "# inputs live in this repo, need no network, and their hooks touch"
          "# only files home-manager does not manage."
          ""
          "[theme.templates.user.nvim-base16]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/nvim-base16.lua\""
          "output_path = \"$XDG_STATE_HOME/nvim/noctalia/theme.lua\""
          "post_hook = \"pkill -SIGUSR1 nvim >/dev/null 2>&1 || true\""
          ""
          "[theme.templates.user.terminal-sequences]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/terminal-sequences\""
          "output_path = \"$XDG_CACHE_HOME/noctalia/terminal-sequences\""
          "# The rendered file must be redirected INTO tee: the hook is just a"
          "# shell command, so without this tee would read nothing and send no"
          "# escape codes at all."
          "post_hook = \"tee /dev/pts/[0-9]* < $XDG_CACHE_HOME/noctalia/terminal-sequences >/dev/null 2>&1 || true\""
          ""
          "[theme.templates.user.starship]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/starship.toml\""
          "output_path = \"$XDG_STATE_HOME/starship/starship.toml\""
          ""
          "[theme.templates.user.mpv]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/mpv.conf\""
          "output_path = \"$XDG_CONFIG_HOME/mpv/noctalia.conf\""
          ""
          "[theme.templates.user.yazi]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/yazi-flavor.toml\""
          "output_path = \"$XDG_CONFIG_HOME/yazi/flavors/noctalia.yazi/flavor.toml\""
          ""
          "[theme.templates.user.fastfetch]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/fastfetch.jsonc\""
          "output_path = \"$XDG_CONFIG_HOME/fastfetch/config.jsonc\""
          ""
          "[theme.templates.user.vesktop]"
          "input_path = \"$XDG_CONFIG_HOME/noctalia/templates/vesktop.css\""
          "output_path = \"$XDG_CONFIG_HOME/vesktop/themes/noctalia.theme.css\""
        ];

        mkThemeScript =
          name: text:
          pkgs.writeShellApplication {
            inherit name text;
            runtimeInputs = [
              config.programs.noctalia.package
              pkgs.coreutils
            ];
          };

        # Every cursor/icon/font package any theme names is built into the
        # store, so `theme-set` can switch without a rebuild.
        pkgOf = x: if x == null then null else (x.package or null);
        themeDefs = lib.attrValues cfg.themes ++ [
          {
            inherit (cfg) font cursor icons;
          }
        ];
        themePackages = lib.unique (
          lib.filter (p: p != null) (
            map (d: pkgOf d.font) themeDefs
            ++ map (d: pkgOf d.cursor) themeDefs
            ++ map (d: pkgOf d.icons) themeDefs
          )
        );
      in
      {
        # The `theme.*` option itself (entities/theme.nix) is declared here:
        # homeManager class modules need the option in the home-manager scope.
        imports = [ ../../../entities/theme.nix ];

        # Catch config mistakes at build time rather than at the first
        # `theme-set`: an unnamed palette would silently pick nothing, and a
        # duplicated menu label would make `theme-menu` unreachable.
        assertions = [
          {
            assertion = cfg.themes != { };
            message = "theme.themes is empty: `theme-set` would have nothing to switch between.";
          }
          {
            assertion = lib.all (t: t.palette.name != "") (lib.attrValues cfg.themes);
            message = ''
              Every entry in theme.themes needs a palette.name. Run
              `noctalia theme --list-templates` for builtin palettes.
            '';
          }
          {
            assertion =
              cfg.defaultTheme == null || builtins.elem cfg.defaultTheme themeNames;
            message = ''
              theme.defaultTheme = ${lib.showOption (cfg.defaultTheme)} but no such
              theme is defined. Available: ${lib.concatStringsSep ", " themeNames}
            '';
          }
          {
            assertion =
              lib.all (label: lib.length (lib.filter (l: l == label) menuLabels) == 1) menuLabels;
            message = ''
              theme.themes descriptions must be unique: `theme-menu` maps the
              selected label back to a theme name. Duplicates among:
              ${lib.concatStringsSep ", " (lib.filter (l: lib.length (lib.filter (x: x == l) menuLabels) > 1) (lib.unique menuLabels))}
            '';
          }
        ];

        # qt6ct reads the colour scheme generated by the built-in `qt` template,
        # which writes ~/.config/qt6ct/colors/noctalia.conf. That file is
        # runtime-generated, so it is never a store symlink; only the static
        # qt6ct.conf that points at it is managed here.
        #
        # home-manager 0.11+ nests everything under `qt`, and honours
        # `color_scheme_path` only when `custom_palette` is true.
        # `platformTheme.name = "qt6ct"` only sets QT_QPA_PLATFORMTHEME, so the
        # package is added below.
        qt = {
          enable = true;
          platformTheme.name = "qt6ct";

          qt6ctSettings.Appearance = {
            color_scheme_path = "~/.config/qt6ct/colors/noctalia.conf";
            custom_palette = true;
          };
        };

        xdg.configFile = {
          "noctalia/templates.toml" = {
            source = pkgs.writeText "noctalia-templates.toml" templatesToml;
            force = true;
          };

          "noctalia/templates/nvim-base16.lua".source =
            pkgs.writeText "nvim-base16.lua" (builtins.readFile ./templates/nvim-base16.lua);

          "noctalia/templates/terminal-sequences".source =
            pkgs.writeText "terminal-sequences" (builtins.readFile ./templates/terminal-sequences);

          "noctalia/templates/starship.toml".source =
            pkgs.writeText "starship.toml" (builtins.readFile ./templates/starship.toml);

          "noctalia/templates/mpv.conf".source =
            pkgs.writeText "mpv.conf" (builtins.readFile ./templates/mpv.conf);

          "noctalia/templates/yazi-flavor.toml".source =
            pkgs.writeText "yazi-flavor.toml" (builtins.readFile ./templates/yazi-flavor.toml);

          "noctalia/templates/fastfetch.jsonc".source =
            pkgs.writeText "fastfetch.jsonc" (builtins.readFile ./templates/fastfetch.jsonc);

          "noctalia/templates/vesktop.css".source =
            pkgs.writeText "vesktop.css" (builtins.readFile ./templates/vesktop.css);
        };

        # Fresh checkouts have no generated files. Noctalia creates the parent
        # directories, but seeding empty placeholders means `dofile()` and the
        # terminal `include`s always resolve, and gives templates something to
        # overwrite on the first `theme-reapply`.
        home.activation.noctaliaThemePlaceholders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${lib.escapeShellArg stateDir} ${lib.escapeShellArg nvimThemeDir} ${lib.escapeShellArg oscCacheDir}
          # Seed empty placeholders so `dofile()`, the terminal `include`s and
          # the starship/mpv `include`s always resolve before the first render.
          for placeholder in ${lib.escapeShellArg nvimThemeFile} ${lib.escapeShellArg oscCacheFile} ${lib.escapeShellArg "${config.xdg.stateHome}/starship/starship.toml"} ${lib.escapeShellArg "${configDir}/mpv/noctalia.conf"}; do
            mkdir -p "$(dirname "$placeholder")"
            [ -e "$placeholder" ] || : >"$placeholder"
          done

          # Record the configured default once, so `theme-current` reports
          # something useful before the first manual switch, and so the runtime
          # font/cursor/icon state exists for the first activation.
          if [ ! -f ${lib.escapeShellArg stateFile} ]; then
            ${seedDefault}
          fi
          if [ ! -f ${lib.escapeShellArg "${stateDir}/font-family"} ]; then
            ${seedExtras}
          fi

          # Apply the runtime font/cursor/icon files. Best-effort: a missing
          # tool must not fail a switch.
          if command -v theme-runtime-apply >/dev/null 2>&1; then
            theme-runtime-apply >/dev/null 2>&1 || true
          fi

          # Re-render templates now so a fresh machine matches the default
          # palette immediately. Deferred: Noctalia may not be running yet
          # during activation, and the placeholders above stand in until it is.
          if command -v noctalia >/dev/null 2>&1; then
            (sleep 2; noctalia msg templates-apply >/dev/null 2>&1 || true) &
          fi
        '';

        home.packages =
          [
            pkgs.qt6Packages.qt6ct
            pkgs.adw-gtk3
            pkgs.xsettingsd
          ]
          ++ themePackages
          ++ [
            # Writes the runtime files (GTK settings.ini, fontconfig,
            # xsettingsd, XCursor index, the niri cursor include) that a theme
            # switch changes. Kept separate from `theme-set` so `theme-reapply`
            # and the activation seed can use it too.
            (pkgs.writeShellApplication {
              name = "theme-runtime-apply";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.fontconfig
                pkgs.glib
                pkgs.procps
                pkgs.util-linux
              ];
              text = ''
                # Best-effort by design: every step is optional (a missing
                # dconf, a stopped xsettingsd) and must never fail a switch or
                # a theme change. writeShellApplication turns on `set -e`.
                set +e

                STATE_DIR=${lib.escapeShellArg stateDir}
                CONFIG_DIR=${lib.escapeShellArg configDir}
                DATA_DIR=${lib.escapeShellArg dataDir}

                read_state() {
                  if [ -r "$STATE_DIR/$1" ]; then cat "$STATE_DIR/$1"; fi
                }

                family=$(read_state font-family)
                size=$(read_state font-size)
                icon_theme=$(read_state icon-theme)
                cursor_theme=$(read_state cursor-theme)

                [ -n "$size" ] || size=10

                # Every theme is dark, so GTK always uses the dark variant.
                gtk_theme=adw-gtk3-dark

                write_settings() {
                  target="$1"
                  mkdir -p "$(dirname "$target")"
                  # A rebuild may have relinked this as a store symlink; writing
                  # through it would try to mutate /nix/store, so replace it.
                  if [ -L "$target" ]; then rm -f "$target"; fi
                  {
                    echo "[Settings]"
                    echo "gtk-application-prefer-dark-theme=true"
                    echo "gtk-button-images=true"
                    echo "gtk-cursor-blink=true"
                    echo "gtk-cursor-blink-time=1000"
                    [ -n "$cursor_theme" ] && echo "gtk-cursor-theme-name=$cursor_theme"
                    echo "gtk-cursor-theme-size=20"
                    echo "gtk-decoration-layout=icon:minimize,maximize,close"
                    echo "gtk-enable-animations=true"
                    [ -n "$family" ] && echo "gtk-font-name=$family $size"
                    [ -n "$icon_theme" ] && echo "gtk-icon-theme-name=$icon_theme"
                    echo "gtk-menu-images=true"
                    echo "gtk-modules=colorreload-gtk-module"
                    echo "gtk-primary-button-warps-slider=true"
                    echo "gtk-sound-theme-name=ocean"
                    echo "gtk-theme-name=$gtk_theme"
                    echo "gtk-toolbar-style=3"
                    echo "gtk-xft-dpi=98304"
                  } >"$target"
                }

                write_settings "$CONFIG_DIR/gtk-3.0/settings.ini"
                write_settings "$CONFIG_DIR/gtk-4.0/settings.ini"

                # Alias the generic families onto the theme font so every app
                # asking for sans-serif follows the theme, not just GTK ones.
                if [ -n "$family" ]; then
                  mkdir -p "$CONFIG_DIR/fontconfig"
                  printf '%s\n' \
                    '<?xml version="1.0"?>' \
                    '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' \
                    '<fontconfig>' \
                    "  <alias><family>sans-serif</family><prefer><family>$family</family></prefer></alias>" \
                    "  <alias><family>system-ui</family><prefer><family>$family</family></prefer></alias>" \
                    '</fontconfig>' >"$CONFIG_DIR/fontconfig/fonts.conf"
                  fc-cache -f >/dev/null 2>&1 || true
                fi

                # XSettings for toolkits that still read it.
                if command -v xsettingsd >/dev/null 2>&1; then
                  mkdir -p "$CONFIG_DIR/xsettingsd"
                  {
                    [ -n "$family" ] && echo "Gtk/FontName \"$family $size\""
                    [ -n "$icon_theme" ] && echo "Gtk/IconThemeName \"$icon_theme\""
                    [ -n "$cursor_theme" ] && echo "Gtk/CursorThemeName \"$cursor_theme\""
                    echo "Gtk/ThemeName \"$gtk_theme\""
                    echo "Xft/DPI 98304"
                  } >"$CONFIG_DIR/xsettingsd/xsettingsd.conf"
                  if pgrep -x xsettingsd >/dev/null 2>&1; then
                    pkill -x xsettingsd >/dev/null 2>&1 || true
                    (setsid xsettingsd >/dev/null 2>&1 &) || true
                  fi
                fi

                # XCursor looks the theme name up through icons/default.
                if [ -n "$cursor_theme" ]; then
                  cursor_dir="$DATA_DIR/icons/default"
                  mkdir -p "$cursor_dir"
                  printf '%s\n' \
                    '[Icon Theme]' \
                    'Name=Default' \
                    'Comment=Noctalia cursor' \
                    "Inherits=$cursor_theme" >"$cursor_dir/index.theme"
                fi

                # niri watches its includes, so a live cursor change just works.
                # The file is always written, even without a cursor, so the
                # config's `include "theme.kdl"` never points at nothing.
                mkdir -p "$CONFIG_DIR/niri"
                {
                  echo "// Rendered by theme-runtime-apply. DO NOT EDIT."
                  if [ -n "$cursor_theme" ]; then
                    echo "cursor {"
                    echo "    xcursor-theme \"$cursor_theme\""
                    echo "    xcursor-size 20"
                    echo "}"
                  fi
                } >"$CONFIG_DIR/niri/theme.kdl"

                # Best-effort for toolkits that read GSettings (no-op without dconf).
                gsettings set org.gnome.desktop.interface font-name "$family $size" >/dev/null 2>&1 || true
                [ -n "$icon_theme" ] && gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" >/dev/null 2>&1 || true
                [ -n "$cursor_theme" ] && gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" >/dev/null 2>&1 || true
                gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true
              '';
            })

            (mkThemeScript "theme-set" ''
              STATE_DIR=${lib.escapeShellArg stateDir}
              STATE_FILE="$STATE_DIR/current"

              usage() {
                echo "usage: theme-set <theme>" >&2
                echo "  available: ${validNames}" >&2
                exit 2
              }

              if [ "$#" -ne 1 ]; then
                usage
              fi
              requested="$1"

              mkdir -p "$STATE_DIR"

              kind=""
              name=""
              mode=""
              wallpaper=""
              font_family=""
              font_size=""
              cursor_theme=""
              icon_theme=""
              case "$requested" in
              ${paletteCase}
                *)
                  echo "theme-set: unknown theme: $requested" >&2
                  echo "  available: ${validNames}" >&2
                  exit 1
                  ;;
              esac

              if [ -z "$name" ]; then
                echo "theme-set: no palette defined for $requested" >&2
                exit 1
              fi

              # Noctalia persists the palette choice itself, so this survives both
              # a reboot and a `home-manager switch`.
              noctalia msg color-scheme-set "$kind" "$name"

              # Every theme is dark (`mode` is always "dark", see
              # entities/theme.nix), so this always pins Noctalia to dark mode.
              noctalia msg theme-mode-set "$mode"

              if [ -n "$wallpaper" ] && [ -e "$wallpaper" ]; then
                noctalia msg wallpaper-set "$wallpaper"
              fi

              # Record the runtime font/cursor/icon choices, then apply them to
              # the files apps read. `theme-runtime-apply` reads these back.
              printf '%s\n' "$font_family" >"$STATE_DIR/font-family"
              printf '%s\n' "$font_size" >"$STATE_DIR/font-size"
              printf '%s\n' "$cursor_theme" >"$STATE_DIR/cursor-theme"
              printf '%s\n' "$icon_theme" >"$STATE_DIR/icon-theme"
              printf '%s\n' "$mode" >"$STATE_DIR/mode"
              theme-runtime-apply

              # Noctalia already re-renders on a palette change; being explicit
              # covers the case where only the mode or wallpaper moved.
              noctalia msg templates-apply

              printf '%s\n' "$requested" >"$STATE_FILE"

              # Apps that only read their colours at startup.
              ${restartCommands}

              echo "theme: $requested (palette=$kind/$name)"
              echo "  mode: $mode"
              if [ -n "$font_family" ]; then
                echo "  font: $font_family $font_size"
              fi
              if [ -n "$cursor_theme" ]; then
                echo "  cursor: $cursor_theme"
              fi
              if [ -n "$icon_theme" ]; then
                echo "  icons: $icon_theme"
              fi
            '')
            (mkThemeScript "theme-menu" ''
              # noctalia's own dmenu bridges to its themed launcher, so this needs
              # no external dmenu runner. It returns the chosen LABEL, which is
              # mapped back to the theme name.
              selection=$(printf '%s\n' ${menuLines} | noctalia dmenu -p "Theme")
              if [ -z "$selection" ]; then
                exit 0
              fi

              theme=""
              case "$selection" in
              ${menuCase}
                *)
                  echo "theme-menu: unrecognised selection: $selection" >&2
                  exit 1
                  ;;
              esac

              exec theme-set "$theme"
            '')
            (mkThemeScript "theme-cycle" ''
              STATE_DIR=${lib.escapeShellArg stateDir}
              STATE_FILE="$STATE_DIR/current"
              mkdir -p "$STATE_DIR"

              if [ -r "$STATE_FILE" ]; then
                current=$(cat "$STATE_FILE")
              else
                current=""
              fi

              # Order as defined
              order=(${lib.concatMapStringsSep " " (n: lib.escapeShellArg n) themeNames})

              next=""
              found=0
              for t in "''${order[@]}"; do
                if [ "$found" -eq 1 ]; then
                  next="$t"; found=2; break
                fi
                if [ "$t" = "$current" ]; then
                  found=1
                fi
              done
              if [ "$found" -ne 2 ]; then
                # wrap around to first
                next="''${order[0]}"
              fi

              exec theme-set "$next"
            '')
            (mkThemeScript "theme-current" ''
              if [ -r ${lib.escapeShellArg stateFile} ]; then
                cat ${lib.escapeShellArg stateFile}
              else
                noctalia msg color-scheme-get || true
              fi
            '')
            (mkThemeScript "theme-next-wallpaper" ''
              exec noctalia msg wallpaper-next
            '')
            (mkThemeScript "theme-reapply" ''
              # Re-render templates and re-apply the runtime font/cursor/icon
              # files without changing the palette. Use after adding a template,
              # after a rebuild, or when an app missed a change.
              theme-runtime-apply
              noctalia msg templates-apply
            '')
          ];
      };
  };
}
