{ ... }:
{
  den.aspects.workstation.bluetooth = {
    nixos = { ... }: {
      # BlueZ daemon + bluetoothctl (the bluez package lands in systemPackages
      # via this module). Noctalia's control center drives it over D-Bus.
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
  };
}
