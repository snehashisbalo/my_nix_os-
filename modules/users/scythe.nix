{
  den,
  ...
}:
{
  # A user is an aspect too. This one is referenced from
  # `den.hosts.x86_64-linux.compulex.users.scythe`.
  den.aspects.scythe = {
    includes = [
      # Provisions the OS account + home dir, and the home-manager home.
      den.batteries.define-user

      # Adds wheel + networkmanager groups.
      den.batteries.primary-user

      # Forwards host-defined `homeManager` keys onto this user.
      den.batteries.host-aspects

      # Shared system-wide config.
      den.aspects.core.default

      # Desktop + tools rice (ported from Spike-dotfiles).
      den.aspects.browsers.default
      den.aspects.terminals.default
      den.aspects.shell.default
      den.aspects.tools.default
    ];

    # OS-level user config. `isNormalUser`, `home`, `wheel` and
    # `networkmanager` are already provided by define-user / primary-user.
    nixos = { pkgs, ... }: {
      users.users.scythe.packages = with pkgs; [
        tree
      ];
    };

    # Home-manager config for scythe.
    homeManager =
      { pkgs, ... }:
      {
        programs.home-manager.enable = true;

        # Named themes for `theme-set <name>`. Colours live in Noctalia; this
        # only records which palette/wallpaper combination to select.
        #
        # Every theme runs in dark mode (the `mode` option only allows "dark"),
        # so no light palette or light cursor/icon override is defined here.
        #
        # `font`, `cursor` and `icons` are the global defaults applied by every
        # theme; a theme may override any of them. Every package named here is
        # built into the store, so switching never needs a rebuild.
        theme = {
          defaultTheme = "noctalia";

          font = {
            family = "JetBrainsMono Nerd Font";
            size = 11;
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          cursor = {
            name = "catppuccin-mocha-dark-cursors";
            package = pkgs.catppuccin-cursors.mochaDark;
          };
          icons = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };

          themes = {
            noctalia = {
              description = "Noctalia — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Noctalia";
            };
            nullscapes = {
              description = "Nullscapes — custom, dark";
              palette.kind = "custom";
              palette.name = "Nullscapes";
            };
            catppuccin = {
              description = "Catppuccin — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Catppuccin";
            };
            nord = {
              description = "Nord — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Nord";
            };
            gruvbox = {
              description = "Gruvbox — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Gruvbox";
            };
            tokyo-night = {
              description = "Tokyo Night — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Tokyo-Night";
            };
            rose-pine = {
              description = "Rosé Pine — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Rosé Pine";
            };
            oxocarbon = {
              description = "Oxocarbon — community, dark";
              palette.kind = "community";
              palette.name = "Oxocarbon";
            };
            kanagawa = {
              description = "Kanagawa — builtin, dark";
              palette.kind = "builtin";
              palette.name = "Kanagawa";
            };
          };
        };

        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        home.packages = with pkgs; [
          # CLI / utilities
          btop
          cava
          cbonsai
          ffmpeg
          jq
          peaclock
          pipes-rs
          psmisc
          python3
          wget

          # Applications
          file-roller
         linux-wallpaperengine
          loupe
          nautilus
          protonup-qt
          telegram-desktop
          vesktop
        ];

        xdg.enable = true;

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "application/xhtml+xml" = "firefox.desktop";
            "image/avif" = "org.gnome.Loupe.desktop";
            "image/bmp" = "org.gnome.Loupe.desktop";
            "image/gif" = "org.gnome.Loupe.desktop";
            "image/jpeg" = "org.gnome.Loupe.desktop";
            "image/png" = "org.gnome.Loupe.desktop";
            "image/svg+xml" = "org.gnome.Loupe.desktop";
            "image/webp" = "org.gnome.Loupe.desktop";
            "inode/directory" = "org.kde.dolphin.desktop";
            "text/html" = "firefox.desktop";
            "x-scheme-handler/discord" = "vesktop.desktop";
            "x-scheme-handler/file" = "org.kde.dolphin.desktop";
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
            "x-scheme-handler/sftp" = "org.kde.dolphin.desktop";
            "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
            "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
          };
        };

        xdg.userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
  };
}
