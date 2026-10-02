{ den, ... }:
{
  den.aspects.shell.default = {
    includes = with den.aspects.shell; [
      fish
      starship
    ];
  };
}
