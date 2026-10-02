{ den, ... }:
{
  den.aspects.workstation.default = {
    includes = with den.aspects.workstation; [
      bluetooth
      gaming
      printing
      sound
      wm
      theme
    ];

    # Linux Zen kernel for a low-latency desktop.
    nixos = { pkgs, ... }: {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
  };
}
