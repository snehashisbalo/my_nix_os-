{ ... }:
{
  den.aspects.workstation.gaming = {
    nixos = { pkgs, ... }: {
      programs.nix-ld.enable = true;
      programs.gamemode.enable = true;
      programs.gpu-screen-recorder.enable = true;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;

        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];

        extraPackages = with pkgs; [
          catppuccin-cursors.mochaDark
        ];
      };

      services.flatpak.enable = true;
    };
  };
}
