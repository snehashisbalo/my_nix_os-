# os — NixOS config (compulex)

Convention-based, **den**-driven NixOS configuration. The shape mirrors
shinyflakes' `modules/` tree (`hosts/`, `users/`, `entities/`,
`aspects/{core,workstation,terminals,shell,tools,browsers}`), reduced to a
single desktop host.

Niri + Noctalia + the Nullscapes rice are ported from `Spike-dotfiles`.

## Layout

```
os/
├── flake.nix                       # mkFlake (import-tree ./modules); den input
├── patches/
│   └── noctalia-bar-capsule-blur.patch   # C++ patch for the Noctalia capsule bar
├── assets/
│   ├── fastfetch/Easy.png          # Fastfetch art
│   └── wallpapers/nullscapes.png   # Static Nullscapes wallpaper
├── dotfiles/
│   └── nvim/                       # LazyVim config, symlinked to ~/.config/nvim
└── modules/                        # auto-imported by import-tree
    ├── parts.nix                   # flake-parts: systems
    ├── den.nix                     # den.flakeModule + global schema/defaults
    ├── entities/
    │   └── theme.nix               # named themes: palette + font/cursor/icons
    ├── hosts/
    │   └── compulex/
    │       ├── default.nix         # den.hosts.x86_64-linux.compulex + den.aspects.compulex
    │       └── hardware.nix        # den.aspects.compulex.nixos (generated HW)
    ├── users/
    │   └── scythe.nix              # den.aspects.scythe
    └── aspects/
        ├── core/
        │   ├── default.nix         # aggregator
        │   └── common.nix          # nix settings, timezone, base packages
        ├── workstation/
        │   ├── default.nix         # includes gaming/printing/sound/wm + Zen kernel
        │   ├── gaming.nix          # steam, gamemode, gpu-screen-recorder, flatpak, nix-ld
        │   ├── printing.nix        # cups, avahi
        │   ├── sound.nix           # pipewire + wireplumber
        │   └── wm/
        │       ├── default.nix
        │       ├── fonts.nix
        │       ├── graphical.nix   # graphics, Wayland session vars, pinned xwayland-satellite
        │       ├── gtk.nix         # GTK Noctalia CSS import (runtime owns settings.ini)
        │       ├── session.nix     # SDDM (Astronaut theme) + Niri session
        │       └── niri/
        │           ├── default.nix # niri + autostart + swayidle
        │           ├── input.kdl
        │           ├── layout.kdl
        │           ├── window-rules.kdl
        │           └── binds.kdl
        ├── terminals/{default,ghostty}.nix
        ├── shell/{default,fish,starship}.nix
        ├── tools/{default,git,mpv,noctalia,nvim,satty,system,vesktop,yazi}.nix
        └── browsers/{default,firefox}.nix
```

## Key idea: hosts and users are aspects

An **aspect** is a composable config unit. It has:

- `includes = [ ... ]` — other aspects to pull in (reuse + composition).
- class keys — `nixos = { ... }: { ... }`, `homeManager = { ... }: { ... }`.
  Each emits config into that class for the current scope.

A host (`den.aspects.compulex`) `includes` shared aspects
(`den.aspects.workstation.default`); a user (`den.aspects.scythe`)
`includes` the user-facing ones (`core`, `browsers`, `terminals`, `shell`,
`tools`) and forwards the host's `homeManager` keys via
`den.batteries.host-aspects`.

### Where things live

- **Machine-specific** → `hosts/compulex/default.nix` and `hardware.nix`.
- **Desktop rice** → `aspects/workstation/**` and `aspects/tools/**`.
- **User config** → `users/scythe.nix`.

### Adding a shared aspect

Create `modules/aspects/<group>/<name>.nix`:

```nix
{ den, ... }:
{
  den.aspects.<group>.<name> = {
    nixos = { pkgs, ... }: { /* ... */ };
  };
}
```

Then reference it from a host/user: `includes = [ den.aspects.<group>.<name> ]`.

## Notes on the rice port

- **Noctalia** uses home-manager's upstream `programs.noctalia` module; the
  flake input `noctalia` is only used to build the **patched** package
  (capsule-blur). Do **not** also import `inputs.noctalia.homeModules.default`
  — it would redeclare every option.
- The monitor output in `workstation/wm/niri/default.nix` is the laptop panel
  `eDP-1` (1920x1080@60). External HDMI is `HDMI-A-1` when plugged in.
- compulex is an Intel laptop (i3-8130U / UHD 620) — VAAPI drivers are enabled
  in `workstation/wm/graphical.nix`; there is no NVIDIA block.
- The Firefox profile dir (`mrf4l2sq.default`) is machine specific; adjust it.

## Building

```bash
# this config now lives at /etc/nixos (migrated from ~/os)
nixos-rebuild build --flake /etc/nixos#compulex
sudo nixos-rebuild switch --flake /etc/nixos#compulex

# eval a value
nix eval /etc/nixos#nixosConfigurations.compulex.config.networking.hostName
```
