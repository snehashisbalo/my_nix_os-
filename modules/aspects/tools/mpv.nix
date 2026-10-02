{ ... }:
{
  den.aspects.tools.mpv = {
    homeManager =
      { pkgs, config, ... }:
      {
        programs.mpv = {
          enable = true;
          scripts = with pkgs.mpvScripts; [
            uosc
            thumbfast
            mpris
          ];
          config = {
            osc = false;
            osd-bar = false;
            border = false;
            hwdec = "auto-safe";
            vo = "gpu-next";
            gpu-context = "wayland";
            save-position-on-quit = true;
            sub-auto = "fuzzy";
            sub-font = "JetBrainsMono Nerd Font";
            sub-font-size = 36;
            sub-border-size = 2.5;
            # Colours (subs, OSD, uosc) come from the Noctalia user template
            # "mpv", written to ~/.config/mpv/noctalia.conf. mpv merges it on
            # top of this file, so `theme-set` repaints it live. Absolute path
            # because mpv does not expand ~ in `include` on every build.
            include = "${config.home.homeDirectory}/.config/mpv/noctalia.conf";
          };
          scriptOpts.uosc = {
            timeline_style = "bar";
            timeline_line_width = 3;
            timeline_size = 32;
            progress = "always";
            progress_size = 3;
            controls = "menu,subtitles<has_many_subtitles>,audio<has_many_audio>,video<has_many_video>,gap,prev,play-pause,next,gap,fullscreen";
            opacity = "timeline=0.85,controls=0.85,timeline_persisted=0.6";
          };
        };
      };
  };
}
