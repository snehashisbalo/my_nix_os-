{ ... }:
{
  den.aspects.shell.fish = {
    homeManager = { pkgs, ... }: {
      programs.bash = {
        enable = true;
        initExtra = ''
        '';
      };

      programs.fish = {
        enable = true;
        shellAliases = {
          pls = "sudo";
          cat = "bat --paging=never";
        };
        shellAbbrs = {
          upp = "sudo nixos-rebuild switch --flake /etc/nixos#compulex";
          upb = "sudo nixos-rebuild boot --flake /etc/nixos#compulex";
          upbuild = "nixos-rebuild build --flake /etc/nixos#compulex";
          upgc = "sudo nix-collect-garbage -d";
        };
        plugins = [
          {
            name = "done";
            src = pkgs.fishPlugins.done.src;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge.src;
          }
        ];
        interactiveShellInit = ''
          set -g fish_greeting ""
        '';
      };
    };
  };
}
