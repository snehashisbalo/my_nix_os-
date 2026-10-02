{ ... }:
{
  den.aspects.workstation.sound = {
    nixos = { pkgs, ... }: {
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        wireplumber.extraConfig."10-disable-hw-volume" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_output.*";
                }
              ];
              actions.update-props = {
                "api.alsa.soft-mixer" = true;
                "api.alsa.ignore-dB" = true;
              };
            }
          ];
        };
      };
    };
  };
}
