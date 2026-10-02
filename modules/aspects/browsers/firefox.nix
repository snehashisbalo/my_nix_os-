{ ... }:
{
  den.aspects.browsers.firefox = {
    homeManager = { pkgs, lib, ... }: {
      programs.firefox.enable = true;

      # NOTE: the profile directory name (mrf4l2sq.default) is machine
      # specific — replace it with your real profile (see about:profiles).
      home.file.".config/mozilla/firefox/mrf4l2sq.default/user.js" = {
        force = lib.mkForce true;
        text = ''
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("layers.acceleration.force-enabled", true);
          user_pref("browser.tabs.firefox-view", false);
        '';
      };

      home.file.".config/mozilla/firefox/mrf4l2sq.default/chrome/userChrome.css" = {
        force = lib.mkForce true;
        text = ''
          /* Nullscapes Minimal Glass Theme */
          :root {
            --toolbar-bgcolor: rgba(8, 11, 22, 0.75) !important;
            --tab-selected-bgcolor: rgba(27, 36, 55, 0.85) !important;
            --lwt-accent-color: #080B16 !important;
            --lwt-text-color: #E8EDFF !important;
            --arrowpanel-background: #141B29 !important;
            --arrowpanel-color: #E8EDFF !important;
            --arrowpanel-border-color: #616771 !important;
          }

          #navigator-toolbox {
            background-color: rgba(8, 11, 22, 0.75) !important;
            backdrop-filter: blur(16px) !important;
            border-bottom: 1px solid rgba(97, 103, 113, 0.25) !important;
          }

          .tabbrowser-tab .tab-background {
            border-radius: 10px !important;
            margin-block: 4px !important;
          }

          .tabbrowser-tab[selected="true"] .tab-background {
            background: #1B2437 !important;
            border: 1px solid #678FE4 !important;
          }

          #urlbar-background {
            border-radius: 12px !important;
            background-color: rgba(20, 27, 41, 0.8) !important;
            border: 1px solid rgba(97, 103, 113, 0.3) !important;
          }

          #urlbar[focused="true"] > #urlbar-background {
            border-color: #678FE4 !important;
            box-shadow: 0 0 0 1px #678FE4 !important;
          }

          * {
            scrollbar-color: #678FE4 #080B16 !important;
            scrollbar-width: thin !important;
          }
        '';
      };
    };
  };
}
