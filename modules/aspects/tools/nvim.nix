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

        # The colours themselves arrive through the Noctalia "nvim-base16" user
        # template (see aspects/workstation/theme), which writes
        # <state>/nvim/noctalia/theme.lua. `lua/plugins/noctalia-base16.lua`
        # loads that file and re-applies on SIGUSR1, so a `theme-set` repaints
        # every running nvim without a restart.
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
