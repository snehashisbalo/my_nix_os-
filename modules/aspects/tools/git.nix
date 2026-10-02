{ ... }:
{
  den.aspects.tools.git = {
    homeManager = { pkgs, lib, ... }: {
      programs.git = {
        enable = true;
        # Set your identity when ready:
        # userName = "triplespike";
        # userEmail = "you@example.com";
      };

      home.file.".gitconfig" = {
        force = lib.mkForce true;
        text = ''
          [safe]
            directory = /etc/nixos
          [user]
            name = scythe
            email = you@example.com
        '';
      };
    };
  };
}
