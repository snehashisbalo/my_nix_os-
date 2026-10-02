{ den, ... }:
{
  den.aspects.tools.default = {
    includes = with den.aspects.tools; [
      git
      mpv
      noctalia
      nvim
      satty
      system
      vesktop
      yazi
    ];
  };
}
