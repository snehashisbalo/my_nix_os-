{ inputs, ... }:
{
  den.aspects.tools.doom-emacs = {
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

        programs.doom-emacs = {
          enable = true;

          # Doom is built from this repo, like dotfiles/nvim. Edit the files in
          # dotfiles/doom/ and rebuild; there is no `doom sync` step.
          doomDir = ../../../dotfiles/doom;

          # Pure GTK build: works natively on Wayland/Niri.
          emacs = pkgs.emacs-pgtk;

          extraBinPackages = [
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.nixfmt
          ];
        };
      };
  };
}
