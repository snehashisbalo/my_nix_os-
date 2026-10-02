{
  den,
  ...
}:
{
  den.aspects.workstation.wm.gtk = {
    homeManager =
      { pkgs, lib, ... }:
      {
        # Home Manager's `gtk` module ALWAYS writes gtk-{3,4}.0/settings.ini as a
        # symlink into the store, which makes runtime theme switching impossible
        # (the file could not be rewritten). It is therefore disabled here and
        # only the Noctalia CSS import is managed; settings.ini is owned by
        # `theme-runtime-apply` (see aspects/workstation/theme), which writes
        # the per-theme font, icon theme, cursor and GTK theme name.
        #
        # `gtk.enable` also normally installs cursor/icon packages; those come
        # from `theme.*` instead, so every theme's assets are in the store.
        xdg.configFile = {
          "gtk-3.0/gtk.css".text = ''@import url("noctalia.css");'';
          "gtk-4.0/gtk.css".text = ''@import url("noctalia.css");'';
        };

        home.sessionVariables = {
          MOZ_ENABLE_WAYLAND = "1";
        };
      };
  };
}
