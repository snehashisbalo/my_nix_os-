{ ... }:
{
  den.aspects.core.common = {
    nixos = { pkgs, ... }: {
      # Keep flakes + the modern CLI on.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.warn-dirty = false;

      nixpkgs.config.allowUnfree = true;

      time.timeZone = "Asia/Dhaka";

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];

      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        pciutils
        curl
	neovim
	brave
	fzf
	opencode
	nodejs
	vimPlugins.LazyVim
      ];

      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
  };
}
