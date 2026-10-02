{
  description = "scythe's NixOS configuration (compulex)";

  # Same caches as shinyflakes (niri + noctalia have no upstream cache).
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs.cachix.org"
      "https://niri-nix.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # den + import-tree drive the convention-based, aspect-oriented layout.
    import-tree.url = "github:denful/import-tree";
    den.url = "github:denful/den";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # xwayland-satellite package fix for Niri (matches the Spike-dotfiles rice).
    nixpkgs-satellite.url = "github:nixos/nixpkgs/edfd59b795cd752c36d2dae60870cffcd23d3fb1";

    # Noctalia desktop shell (custom capsule-blur patch lives in ./patches).
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spotify theming for the Nullscapes palette.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
