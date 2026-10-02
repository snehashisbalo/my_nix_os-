{
  den,
  ...
}:
{
  den.aspects.tools.nvim = {
    homeManager =
      { pkgs, lib, ... }:
      {
        # `dotfiles/nvim` lives in this repo. Home Manager cannot symlink the
        # working tree directly (a Nix path would be copied read-only into the
        # store, and lazy.nvim needs to rewrite lazy-lock.json), so the config
        # is linked by path at activation. Keep the repo at /etc/nixos — that is
        # where the flake is deployed (see GUIDE.md).
        home.activation.linkNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          nvim_src="/etc/nixos/dotfiles/nvim"
          if [ ! -d "$nvim_src" ]; then
            echo "linkNvim: $nvim_src is missing; leaving ~/.config/nvim alone" >&2
          else
            if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
              run rm -rf "$HOME/.config/nvim"
            fi
            run ln -sfn "$nvim_src" "$HOME/.config/nvim"
          fi
        '';

        # The colours come from this config's own `catppuccin` plugin spec
        # (lua/plugins/colorschemes/catppuccin.lua), with the active flavour
        # persisted in `theme.json`. `theme-set` does not repaint nvim: run
        # `:Lazy reload` or restart to pick up a different colourscheme.
        home.packages = with pkgs; [
          neovim
          ripgrep
          fd
          lazygit
          gcc
          unzip
        ];
      };
  };
}
