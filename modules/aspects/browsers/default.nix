{ den, ... }:
{
  den.aspects.browsers.default = {
    includes = with den.aspects.browsers; [
      firefox
    ];
  };
}
