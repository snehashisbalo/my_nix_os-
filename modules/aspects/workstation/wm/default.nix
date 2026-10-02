{ den, ... }:
{
  den.aspects.workstation.wm = {
    includes = with den.aspects.workstation.wm; [
      fonts
      graphical
      gtk
      keyd
      niri
      session
    ];
  };
}
