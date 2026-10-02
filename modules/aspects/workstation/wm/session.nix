{ ... }:
{
  den.aspects.workstation.wm.session = {
    nixos =
      { pkgs, lib, ... }:
      {
        # X11 compatibility layer (needed by XWayland apps).
        services.xserver.enable = true;

        services.xserver.xkb = {
          layout = "us,ru";
          options = "grp:win_space_toggle";
          variant = "";
        };

        # SDDM display manager with the Ryoku qylock "clockwork/orbital" theme
        # (vendored under assets/sddm/qylock-clockwork).
        services.displayManager.sddm = {
          enable = true;
          wayland.enable = true;
          theme = "ryoku";
          package = lib.mkForce pkgs.kdePackages.sddm;
          extraPackages = with pkgs.kdePackages; [
            qt5compat
            qtdeclarative
            qtsvg
            qtmultimedia
            qtvirtualkeyboard
          ];
        };

        services.displayManager.defaultSession = lib.mkForce "niri";

        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gnome
            pkgs.xdg-desktop-portal-gtk
          ];
          config.niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          };
        };

        environment.systemPackages = with pkgs; [
          (pkgs.runCommand "sddm-theme-ryoku" { } ''
            mkdir -p $out/share/sddm/themes/ryoku
            cp -r ${../../../../assets/sddm/qylock-clockwork}/. $out/share/sddm/themes/ryoku/
          '')
        ];
      };
  };
}
