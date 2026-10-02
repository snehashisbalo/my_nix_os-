{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
  ];

  # Expose the den library for debugging (`nix eval .#den`).
  flake.den = den;

  # Every user gets home-manager by default. Override per-user via
  # `den.hosts.<sys>.<host>.users.<name>.classes = [ ... ];`.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Applied to every host/user/home. Per-host overrides still win.
  den.default = {
    nixos.system.stateVersion = lib.mkDefault "26.05";
    homeManager.home.stateVersion = lib.mkDefault "26.05";

    includes = [
      # Sets networking.hostName from `den.hosts.<sys>.<host>.hostName`.
      den.batteries.hostname

      # Provide `inputs'` / `self'` (system pre-selected) as module args.
      den.batteries.inputs'
      den.batteries.self'
    ];
  };

  # Hosts and users are declared in their own
  # modules/hosts/<host>/ and modules/users/<user>/ files.
}
