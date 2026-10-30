{ den, ... }:
{
  den.aspects.tools.default = {
    includes = with den.aspects.tools; [
      atuin
      doom-emacs
      git
      mpv
      noctalia
      nvim
      satty
      superfile
      system
      vesktop
      yazi
    ];
  };
}
