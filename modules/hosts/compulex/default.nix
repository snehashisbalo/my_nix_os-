{
  den,
  ...
}:
{
  # The single host in this flake.
  den.hosts.x86_64-linux.compulex = {
    users.scythe = { };
  };

  # A host is just an aspect: `includes` pulls in reusable aspects, and each
  # class key (`nixos`, `homeManager`, ...) contributes config to that class.
  den.aspects.compulex = {
    includes = [
      den.aspects.workstation.default
    ];

    nixos = { pkgs, ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";

      zramSwap.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.networkmanager.enable = true;
      services.resolved.enable = true;

      # Laptop: Intel i3-8130U (Kaby Lake-R, UHD Graphics 620).
      services.fwupd.enable = true;
      services.thermald.enable = true;
      services.fstrim.enable = true;

      # `networking.hostName` is set from `den.hosts...compulex` by
      # den.batteries.hostname — no need to set it here.
    };
  };
}
