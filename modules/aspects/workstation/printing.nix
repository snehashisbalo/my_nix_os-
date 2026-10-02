{ ... }:
{
  den.aspects.workstation.printing = {
    nixos = { pkgs, ... }: {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          cups-filters
        ];
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      programs.system-config-printer.enable = true;
    };
  };
}
