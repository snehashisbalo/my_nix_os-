{ ... }:
{
  den.aspects.shell.fish = {
    homeManager = { pkgs, ... }: {
      programs.bash = {
        enable = true;
        initExtra = ''
          [[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
        '';
      };

      programs.fish = {
        enable = true;
        shellAliases = {
          pls = "sudo";
          cat = "bat --paging=never";
          gpush = "git push origin";
          gpull = "git pull origin";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          rebuild = "sudo nixos-rebuild switch --flake path:/etc/nixos#compulex";
          ll = "ls -al";
        };
        functions = {
          gcm = ''
            set -l msg (string join ' ' -- $argv)
            git commit -m "$msg"
          '';
          cd = ''
            builtin cd $argv
            and ls -al
          '';
        };
        shellAbbrs = {
          # `path:` is required: /etc/nixos is owned by scythe, so libgit2
          # refuses the plain flake reference and nixos-rebuild cannot escalate
          # without a tty. See GUIDE.md §5.2.
          upp = "sudo nixos-rebuild switch --flake path:/etc/nixos#compulex";
          upb = "sudo nixos-rebuild boot --flake path:/etc/nixos#compulex";
          upbuild = "nixos-rebuild build --flake path:/etc/nixos#compulex";
          upgc = "sudo nix-collect-garbage -d";
          uptheme = "theme-menu";
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
