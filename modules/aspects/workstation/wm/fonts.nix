{ ... }:
{
  den.aspects.workstation.wm.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
    };
  };
}
