{ inputs, ... }:
{
  den.aspects.workstation.wm.graphical = {
    nixos = { pkgs, ... }: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        # Intel UHD 620: VAAPI hardware video acceleration.
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      environment.systemPackages = with pkgs; [
        libnotify
        mesa
      ];
    };

    homeManager =
      { pkgs, ... }:
      let
        # Package fix for xwayland-satellite (see flake.nix input).
        satellitePkgs = import inputs.nixpkgs-satellite {
          inherit (pkgs.stdenv.hostPlatform) system;
        };
      in
      {
        home.packages = with pkgs; [
          brightnessctl
          grim
          imv
          matugen
          playerctl
          slurp
          swaybg
          wayland-protocols
          wayland-utils
          wf-recorder
          wl-clipboard
          wl-clip-persist
          wtype
        ] ++ [ satellitePkgs.xwayland-satellite ];
      };
  };
}
