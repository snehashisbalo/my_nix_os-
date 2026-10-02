# compulex — Guide & Reference

Everything about this machine: what it is, how the config is wired, and the
exact commands to install, delete and change things.

- **Host:** `compulex` · **User:** `scythe` · **Flake:** `/etc/nixos`
- **Desktop:** Niri (Wayland) + Noctalia (shell) · **Display manager:** SDDM
- **Remote:** `git@github.com:snehashisbalo/my_nix_os-.git` (branch `master`)

---

## 0. Command cheat sheet

```bash
# ---- build / apply -------------------------------------------------------
upp                       # = rebuild switch  (fish abbr, see §5)
upbuild                   # = rebuild build   — evaluates + compiles, changes nothing
upgc                      # = nix-collect-garbage -d
sudo nixos-rebuild switch --rollback     # back out of a bad switch
sudo nixos-rebuild list-generations      # every generation, newest last

# ---- theme ---------------------------------------------------------------
theme-menu                # pick a theme (Mod+Shift+Ctrl+Space)
theme-set <name>          # e.g. theme-set catppuccin-mocha-dark
theme-cycle               # next theme      (Mod+Shift+C)
theme-current             # what is active
theme-reapply             # re-render apps without changing palette
theme-next-wallpaper      # next wallpaper  (Mod+Ctrl+Space)

# ---- desktop -------------------------------------------------------------
Mod+K                     keybinding cheatsheet
Mod+Space                 app launcher
Alt+Tab                   window switcher
Mod+Ctrl+V                clipboard history
Mod+Ctrl+L                lock screen
Mod+Return                kitty terminal
Mod+Shift+T               ghostty terminal

# ---- package managers ----------------------------------------------------
nix search nixpkgs <name>             # look something up
nix shell nixpkgs#<name>              # use it for one shell, nothing installed
nix shell nixpkgs#<name> -c <cmd>     # run one command
nix run nixpkgs#<name>                # run an app
nix develop -c <cmd>                  # inside a project flake
flatpak install flathub <app.id>      # sandboxed GUI app
```

> **Read this before you rebuild:** `sudo nixos-rebuild switch --flake
> /etc/nixos#compulex` **does not work on this box** — see §5.2.

---

## 1. The machine

| | |
|---|---|
| CPU | Intel Core i3-8130U (Kaby Lake-R, 2.20 GHz / 3.00 boost) |
| GPU | Intel UHD Graphics 620 (VAAPI enabled) |
| RAM | 16 GiB |
| Kernel | `linuxPackages_zen` (`7.2.7-zen1`) |
| Nix | 2.34.8, flakes + `nix-command` enabled |
| Bootloader | systemd-boot, EFI vars |
| Swap | zram (7.8 GiB) + `/swap` on `sdb2` |
| Disks | `sdb3` → `/` (228 GiB), `sdb1` → `/boot` (1 GiB), `sda1` → `/home/scythe/hdd` (931 GiB) |
| Display | laptop panel `eDP-1` 1920x1080 @ 59.96 Hz, scale 1.0 |
| Store size | ~40 GiB in `/nix/store` |
| Timezone | `Asia/Dhaka` |
| Groups | `users`, `wheel`, `networkmanager` |
| Trusted users | `root` only |

**Desktop stack**

| Layer | What |
|---|---|
| Login | SDDM with the `qylock-clockwork` theme (`assets/sddm/`) |
| Compositor | Niri (scrollable-tiling Wayland) |
| Shell | Noctalia — bar, launcher, notifications, clipboard, panels, OSD |
| Colour source | Noctalia palette → rendered into every app config |
| Display server | Wayland, `NIXOS_OZONE_WL=1`, xwayland-satellite for X11 apps |
| Panels | `1920x1080` laptop display only; no external outputs configured |

---

## 2. Repository layout

```
/etc/nixos/
├── flake.nix                  # inputs + mkFlake { import-tree ./modules }
├── flake.lock                 # pinned revisions — commit this
├── GUIDE.md                   # this file
├── README.md                  # short intro
├── assets/
│   ├── fastfetch/Easy.png     # fastfetch logo art
│   ├── sddm/qylock-clockwork/ # login theme
│   └── wallpapers/nullscapes.png
├── patches/
│   └── noctalia-bar-capsule-blur.patch   # C++ patch applied to noctalia
├── dotfiles/nvim/             # the Neovim config — a live working tree (§7)
└── modules/                   # EVERYTHING here is auto-imported
    ├── parts.nix              # flake-parts: target systems
    ├── den.nix                # den library + global defaults
    ├── entities/theme.nix     # the `theme` option (palettes, font, cursor, icons)
    ├── hosts/compulex/
    │   ├── default.nix        # declares the host; zram, systemd-boot, NetworkManager
    │   └── hardware.nix       # generated disk/CPU config — DO NOT hand-edit
    ├── users/scythe.nix       # the user aspect: home.packages, theme.themes, mime types
    └── aspects/
        ├── core/common.nix       # nix settings, timezone, fonts, system packages
        ├── workstation/
        │   ├── default.nix       # includes gaming printing sound wm theme + Zen kernel
        │   ├── gaming.nix        # nix-ld, flatpak, steam, gamemode
        │   ├── printing.nix
        │   ├── sound.nix         # pipewire, wireplumber, rtkit
        │   ├── theme/default.nix # theme-set/menu/cycle + all palette rendering
        │   └── wm/
        │       ├── default.nix   # includes niri fonts graphical gtk keyd session
        │       ├── fonts.nix     # JetBrainsMono Nerd Font
        │       ├── graphical.nix # wayland CLI tools, xwayland-satellite
        │       ├── gtk.nix       # gtk.css only — settings.ini is runtime-owned
        │       ├── keyd.nix      # Mod+C/V/X clipboard interception
        │       ├── session.nix   # SDDM, portals, gnome-keyring, greetd bits
        │       └── niri/         # default.nix + binds/input/layout/window-rules .kdl
        ├── terminals/            # ghostty, kitty
        ├── shell/                # fish (abbrs), starship (prompt)
        ├── tools/                # git mpv noctalia nvim satty system vesktop yazi
        └── browsers/             # firefox
```

**Nothing outside `modules/` is imported explicitly.** Adding a `.nix` file
anywhere under `modules/` is enough — `import-tree` picks it up.

---

## 3. The mental model

Three layers, and one rule that prevents 90% of the pain here:

1. **NixOS (system)** — bootloader, kernel, services, `environment.systemPackages`.
   Files in `modules/**` `nixos = { ... }`.
2. **Home Manager (user)** — `~/.config/*`, `home.packages`. Files in
   `modules/**` `homeManager = { ... }`.
3. **`nix` CLI** — `nix shell`, `nix develop`, `nix run`. Nothing persists.

> ### The golden rule
> If a file says **"Generated by Home Manager / DO NOT EDIT"**, edit the `.nix`
> that produced it and rebuild. Hand-editing a generated file causes the
> famous **"Existing file … would be clobbered"** failure on the next switch.
>
> The one deliberate exception is `gtk-{3,4}.0/settings.ini`, which Home
> Manager is configured **not** to own so that `theme-set` can rewrite it at
> runtime. Everything in it still comes from the theme module.

### How an aspect works

A host and a user are both just *aspects*. An aspect is a reusable chunk:

```nix
{ den, ... }:
{
  den.aspects.<group>.<name> = {
    includes = [ den.aspects.other.aspect ];   # composition
    nixos       = { pkgs, ... }: { /* -> system */ };
    homeManager = { pkgs, ... }: { /* -> your home */ };
  };
}
```

`<group>/default.nix` is just an aggregator listing its group’s members.

### How it wires together

```
flake.nix  ──mkFlake──>  import-tree ./modules
                              │
  den.default ───────────────┤ applies to every host + user
                              ├─ den.batteries.hostname      -> networking.hostName
                              ├─ den.batteries.inputs'       -> `inputs` arg in modules
                              └─ den.batteries.self'
                              │
  hosts/compulex  ────────────┤ den.aspects.compulex
  │  includes workstation.default ─> gaming printing sound wm theme
  │  users.scythe = { }
  │
  users/scythe ───────────────┤ den.aspects.scythe
     includes core.default, browsers.default, terminals.default,
               shell.default, tools.default
               + den.batteries.define-user / primary-user / host-aspects
                    │
                    └─ host-aspects forwards the host's homeManager keys onto you
```

### Where should a change go?

| Change | File |
|---|---|
| Disk, CPU, bootloader, host services | `modules/hosts/compulex/` |
| A system service or system-wide binary | an aspect’s `nixos`, or `aspects/core/common.nix` |
| A program just for you | an aspect’s `home.packages`, or `users/scythe.nix` |
| Your personal apps list, themes, mime types | `modules/users/scythe.nix` |
| Desktop, bar, keybindings | `aspects/workstation/**` |
| An app’s config file | the aspect that already owns that app (§6.3) |
| Neovim | `dotfiles/nvim/` (§7) |

---

## 4. Build, apply, roll back

```bash
# compile + evaluate, touch nothing  <-- run this first, always
nixos-rebuild build --flake 'path:/etc/nixos#compulex'

# apply now, and make it the boot default
sudo nixos-rebuild switch --flake 'path:/etc/nixos#compulex'

# apply now, boot default unchanged
sudo nixos-rebuild test --flake 'path:/etc/nixos#compulex'

# only on next reboot
sudo nixos-rebuild boot --flake 'path:/etc/nixos#compulex'
```

| Command | Use when |
|---|---|
| `build` | checking for errors. Safest; makes `./result`. |
| `test` | you want to try it but keep the old boot default. |
| `switch` | normal day-to-day. |
| `boot` | you’ll reboot soon. |

**Rollback**

```bash
sudo nixos-rebuild list-generations          # find the good number
sudo nixos-rebuild switch --flake 'path:/etc/nixos#compulex' --rollback   # previous
sudo nixos-rebuild switch --flake 'path:/etc/nixos#compulex' --rollback   # older still
```

A NixOS generation **includes** its Home Manager generation, so rolling back
rolls back your dotfiles too. systemd-boot also lists old generations in the
boot menu — pick one there if the system won’t come up.

`./result` and `./result-*` are symlinks into `/nix/store`. They are build
artifacts and are **not** tracked by git.

**Home Manager is a NixOS module here**, so there is no separate
`home-manager` CLI. Use the NixOS commands above.

---

## 5. Two things that will bite you

### 5.1 New files must be `git add`ed

The flake is evaluated **purely** from the git tree, so a new file that isn’t
tracked is invisible to Nix:

```
error: Path 'modules/aspects/shell/starship.toml' in the repository "/etc/nixos"
is not tracked by Git.
```

```bash
git -C /etc/nixos add <newfile>     # always
```

### 5.2 `--flake` must use `path:` here

`/etc/nixos` is owned by `scythe`, not root. Two failure modes follow:

| What you type | What happens |
|---|---|
| `sudo nixos-rebuild switch --flake /etc/nixos#compulex` | `repository path '/etc/nixos' is not owned by current user (libgit2 error code = 7)` |
| `nixos-rebuild switch --flake /etc/nixos#compulex` (no sudo) | builds fine, then `creating symlink "/nix/var/nix/profiles/…" Permission denied` — it cannot escalate without a tty |
| `sudo nixos-rebuild switch --flake 'path:/etc/nixos#compulex'` | **works** |

`path:` tells Nix to use the directory directly instead of going through git,
so the ownership check is skipped. The trade-off: uncommitted edits **are**
included, and the build is no longer pinned to a git revision — which for
local work is what you want anyway. Commit before you care about provenance.

---

## 6. Packages

### 6.1 Where a package should live

| | Use | Why |
|---|---|---|
| **System-wide** | `environment.systemPackages` in `aspects/core/common.nix` | available to every user, on `$PATH` early |
| **Just you** | `home.packages` in an aspect or `users/scythe.nix` | the normal choice for an app or CLI you use |

Rule of thumb: **user apps → Home Manager**, **services / daemons / system
libraries → NixOS**.

### 6.2 Install

```nix
# in modules/users/scythe.nix, inside homeManager
home.packages = with pkgs; [
  btop
  cava
  # ← add it here
];
```

```nix
# in modules/aspects/core/common.nix, inside nixos
environment.systemPackages = with pkgs; [
  git
  wget
  # ← or here
];
```

Then:

```bash
upbuild      # check
upp         # apply
```

### 6.3 Delete

1. Remove the line from the list.
2. `upp`.
3. The old store path stays until GC — `upgc`.

There is no uninstall command for declarative packages. Deleting the line
*is* the uninstall.

### 6.4 Everything currently installed

**System packages** — `aspects/core/common.nix`:
`git` `vim` `neovim` `wget` `curl` `pciutils` `fzf` `brave` `opencode`
`nodejs` `vimPlugins.LazyVim`
(plus the NixOS defaults NixOS itself pulls in: `nix`, `bash`, `less`, `nano`,
`sudo`, `man-db`, `iproute2`, `iputils`, `openssh`, `curl`, `bash-completion`,
`acl`, `attr`, `rsync`, `strace`, `bzip2`, `xz`, `zstd`, `gnugrep`, `gnused`,
`findutils`, `diffutils`, `patch`, `procps`, `coreutils`, `util-linux`, …)

**Your packages** — `users/scythe.nix`:
`btop` `cava` `cbonsai` `ffmpeg` `jq` `peaclock` `pipes-rs` `psmisc`
`python3` `wget` `file-roller` `linux-wallpaperengine` `loupe` `nautilus`
`protonup-qt` `telegram-desktop` `vesktop`

**Your packages** — by aspect:

| Aspect | Packages |
|---|---|
| `tools/nvim` | `neovim` `ripgrep` `fd` `lazygit` `gcc` `unzip` |
| `tools/git` | `git` (config at `~/.gitconfig`) |
| `tools/system` | `fastfetch` `bat` `eza` `zoxide` `man-db` |
| `tools/mpv` | `mpv-with-scripts` |
| `tools/yazi` | `yazi` |
| `tools/noctalia` | `noctalia` (patched — see `patches/`) |
| `tools/satty` | `satty` |
| `tools/vesktop` | `vesktop` |
| `shell/fish` | `fish` `bash-interactive` (abbrs: `pls`, `cat`, `upp`, `upb`, `upbuild`, `upgc`) |
| `shell/starship` | `starship` (the prompt itself is Noctalia-rendered, §8.3) |
| `terminals/kitty` | `kitty` |
| `terminals/ghostty` | `ghostty` |
| `browsers/firefox` | `firefox` |
| `wm/graphical` | `brightnessctl` `grim` `imv` `matugen` `playerctl` `slurp` `swaybg` `wayland-protocols` `wayland-utils` `wf-recorder` `wl-clipboard` `wl-clip-persist` `wtype` `xwayland-satellite` |
| `wm/niri` | `wl-clip-persist` (+ the `swayidle` display-blank service) |
| `wm/fonts` | `nerd-fonts.jetbrains-mono` |
| `workstation/theme` | `qt6ct` `adw-gtk3` `xsettingsd` + every package any `theme.*` names (`papirus-icon-theme`, `catppuccin-cursors`, …) |
| `workstation/gaming` | `steam` `steam-run` `gamemode` `gpu-screen-recorder` |

Verify what is actually installed, rather than trusting this table:

```bash
nix eval --json 'path:/etc/nixos#nixosConfigurations.compulex.config.home-manager.users.scythe.home.packages' \
  --apply 'ps: map (p: p.pname or "?") ps' | tr ',' '\n' | tr -d '[]" ' | sort

nix-store -q --references /run/current-system | grep -v '^/nix/store/[a-z0-9]*-[0-9]' | head -50
```

### 6.5 Imperative installs — know they exist, prefer declarative

```bash
nix profile install nixpkgs#ripgrep     # into ~/.nix-profile
nix profile list
nix profile remove ripgrep
```

This is **not** tracked in the repo and is trivially forgotten. `~/.nix-profile`
is managed by Home Manager. Use `home.packages`.

### 6.6 Packages from another flake

`flake.nix` already has inputs: `noctalia`, `spicetify-nix`, `nixpkgs-satellite`,
`den`, `import-tree`, `flake-parts`, `home-manager`, `wrapper-modules`.
`den.batteries.inputs'` makes `inputs` available as a module argument:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

`nixpkgs.config.allowUnfree = true` is already global, so unfree packages just
work.

---

## 7. Config files

### 7.1 The four routes

Pick whichever fits; all four are legitimate.

**1. A Home Manager module.** Best when one exists:

```nix
programs.kitty = { enable = true; extraConfig = "font_size 12"; };
programs.fish  = { enable = true; shellAbbrs.gg = "git status"; };
```
In use already: `programs.fish`, `programs.kitty`, `programs.ghostty`,
`programs.yazi`, `programs.mpv`, `programs.git`, `programs.fastfetch`,
`programs.noctalia`, `programs.satty`, `programs.starship`, `programs.bat`,
`programs.bash`, `programs.direnv` (not enabled).

**2. Inline text via `xdg.configFile` / `home.file`:**

```nix
xdg.configFile."app/config.toml".text = ''
  key = "value"
'';
```

**3. From a file already in the repo.** This is the pattern used for Noctalia’s
templates (`aspects/workstation/theme/templates/`):

```nix
xdg.configFile."noctalia/templates/mpv.conf".source =
  pkgs.writeText "mpv.conf" (builtins.readFile ./templates/mpv.conf);
```

> Use `./relative` or `builtins.readFile ./relative`, **never an absolute path**.
> Pure evaluation rejects `/etc/nixos/...` even though it is inside the repo
> (`access to absolute path … is forbidden in pure evaluation mode`). See §5.2
> and §11.2.

**4. System files:**

```nix
environment.etc."app/config".text = "…";
```

### 7.2 Taking over a file another module owns

```nix
xdg.configFile."vesktop/settings/quickCss.css" = {
  force = lib.mkForce true;
  text = ''@import url("../themes/noctalia.theme.css");'';
};
```

`force = true` also wins over leftover *unmanaged* files sitting at the same
path — but clean those up first, or you will be confused about which version is
live.

### 7.3 Which aspect owns which config

| Config | Owned by | Live at |
|---|---|---|
| fish | `shell/fish.nix` | `~/.config/fish/` |
| starship prompt | `shell/starship.nix` + Noctalia template | `~/.local/state/starship/starship.toml` |
| kitty | `terminals/kitty.nix` | `~/.config/kitty/` |
| ghostty | `terminals/ghostty.nix` | `~/.config/ghostty/config` |
| niri | `wm/niri/` | `~/.config/niri/*.kdl` |
| Neovim | **`dotfiles/nvim/`** | `~/.config/nvim` → symlink into the repo |
| GTK | `wm/gtk.nix` (css only) + `theme` (settings.ini) | `~/.config/gtk-{3,4}.0/` |
| Noctalia | `tools/noctalia.nix` | `~/.config/noctalia/` |
| mpv, yazi, fastfetch, vesktop, starship, terminal seqs | `workstation/theme` templates | rendered by Noctalia on every theme change |

### 7.4 Neovim

The config lives in this repo at `dotfiles/nvim` and is **symlinked** to
`~/.config/nvim` at activation, because lazy.nvim needs to rewrite
`lazy-lock.json` and a store copy would be read-only.

```bash
cd /etc/nixos/dotfiles/nvim     # edit here, not in ~/.config/nvim
nvim                            # run it — it is the same directory
```

- LazyVim + lazy.nvim, ~164 Lua files under `lua/`
- `theme.json` records the active colorscheme and transparency flag
- The Catppuccin Mocha spec is in **`lua/config/lazy.lua`**, not in
  `lua/plugins/` — read the comment there before moving it
- `lua/plugins/lsp/` is the only part of `lua/plugins/` that currently loads;
  see §11.1 before touching the rest

Open a **new terminal** after a switch if you changed `home.sessionVariables`.

---

## 8. The theme system

**Noctalia is the single source of truth for colour.** A theme switch is one
command and needs no rebuild.

```bash
theme-menu      # themed launcher picker
theme-set <name>
theme-cycle
theme-current
theme-reapply            # re-render apps, keep the palette
theme-next-wallpaper
```

### 8.1 Defining a theme

Themes live in `modules/users/scythe.nix` under `theme.themes`. Each entry
names a Noctalia palette and may override the global font / cursor / icons:

```nix
theme = {
  defaultTheme = "catppuccin-mocha-dark";

  font   = { family = "JetBrainsMono Nerd Font"; size = 11; package = pkgs.nerd-fonts.jetbrains-mono; };
  cursor = { name = "catppuccin-mocha-dark-cursors"; package = pkgs.catppuccin-cursors.mochaDark; };
  icons  = { name = "Papirus"; package = pkgs.papirus-icon-theme; };

  themes = {
    catppuccin-mocha-dark = {
      description = "Catppuccin Mocha Dark — custom, dark";
      palette.kind = "custom";                       # builtin | community | custom | wallpaper
      palette.name = "Catppuccin Mocha Dark";
      wallpaper = "/home/scythe/Pictures/Wallpapers/catppuccin-mocha-dark.jpg";
    };
    catppuccin = {
      description = "Catppuccin — builtin, dark";
      palette.kind = "builtin";
      palette.name = "Catppuccin";
    };
    # … tokyo-night, nord, gruvbox, rose-pine, oxocarbon, kanagawa, noctalia, nullscapes
  };
};
```

The option schema is `modules/entities/theme.nix` — read it before adding keys.

Every theme is **dark**. `mode` is typed as `lib.types.enum [ "dark" ]`, so
writing `"light"` is a **build-time type error**, not a runtime surprise.

### 8.2 Custom palettes

`palette.kind = "custom"` loads `~/.config/noctalia/palettes/<name>.json`.
The format is Material-3 roles plus a `terminal` block:

```json
{
  "dark": {
    "mPrimary": "#89b4fa", "mOnPrimary": "#010101",
    "mSecondary": "#f5c2e7", "mTertiary": "#94e2d5",
    "mError": "#f38ba8",
    "mSurface": "#010101", "mSurfaceVariant": "#181825",
    "mOnSurface": "#cdd6f4", "mOnSurfaceVariant": "#a6adc8",
    "mOutline": "#585b70", "mShadow": "#000000",
    "mHover": "#313244", "mOnHover": "#cdd6f4",
    "terminal": {
      "background": "#010101", "foreground": "#cdd6f4",
      "cursor": "#f5e0dc", "cursorText": "#010101",
      "selectionBg": "#f5e0dc", "selectionFg": "#010101",
      "normal":  { "black": "#45475a", "red": "#f38ba8", "green": "#a6e3a1", "yellow": "#f9e2af",
                   "blue": "#89b4fa", "magenta": "#f5c2e7", "cyan": "#94e2d5", "white": "#bac2de" },
      "bright":  { "black": "#585b70", "red": "#f38ba8", "green": "#a6e3a1", "yellow": "#f9e2af",
                   "blue": "#89b4fa", "magenta": "#f5c2e7", "cyan": "#94e2d5", "white": "#a6adc8" }
    }
  }
}
```

`light` may be omitted — Noctalia then uses `dark` for both modes.
Docs: <https://docs.noctalia.dev/noctalia/theming/palette/>

### 8.3 What a switch actually changes

**Noctalia re-renders every enabled template:**

| Template | Output |
|---|---|
| `niri` | `~/.config/niri/noctalia.kdl` — border, focus-ring, tab-indicator, insert-hint colours |
| `ghostty` | `~/.config/ghostty/themes/noctalia` |
| `kitty` | `~/.config/kitty/themes/noctalia.conf` |
| `gtk3` / `gtk4` | `~/.config/gtk-{3,4}.0/noctalia.css` |
| `btop` | `~/.config/btop/themes/noctalia.theme` |
| `cava`, `qt` | cava config, qt5ct/qt6ct colour scheme |
| *user:* `starship` | `~/.local/state/starship/starship.toml` |
| *user:* `mpv` | `~/.config/mpv/noctalia.conf` |
| *user:* `yazi` | `~/.config/yazi/flavors/noctalia.yazi/flavor.toml` |
| *user:* `fastfetch` | `~/.config/fastfetch/config.jsonc` |
| *user:* `vesktop` | `~/.config/vesktop/themes/noctalia.theme.css` |
| *user:* `terminal-sequences` | OSC colour queries, pushed into every open terminal |

These are enabled in `modules/aspects/workstation/theme/default.nix`
(`templatesToml`) and written to `~/.config/noctalia/templates.toml`.

**`theme-runtime-apply` writes the runtime files** that no template can own:

| File | Written from |
|---|---|
| `~/.config/gtk-{3,4}.0/settings.ini` | font, icon theme, cursor, GTK theme name |
| `~/.config/fontconfig/fonts.conf` | font family + size |
| `~/.config/xsettingsd/xsettingsd.conf` | same, for X11 toolkits |
| `~/.local/share/icons/default/` | icon theme index |
| `~/.config/niri/theme.kdl` | cursor theme + size (niri re-reads the include, no re-login) |
| `~/.local/state/theme/{current,font-family,font-size,cursor-theme,icon-theme,mode}` | the state files the above read back |

Every package a theme names is built into the store at build time, so switching
never needs a rebuild.

> **`xsettingsd` must be running** or GTK apps will not see theme changes.
> It is started from `~/.config/niri/autostart.sh`. If it has died:
> ```bash
> setsid xsettingsd >/dev/null 2>&1 </dev/null &
> ```

### 8.4 Icons

`theme.icons.name` is the GTK icon theme, applied globally (every theme
inherits) or per theme:

- `Papirus` — colourful, mid-tone. **Current default.**
- `Papirus-Dark` — greyscale-ish; fights a colourful palette.
- `Papirus-Light` — colourful but light.
- `breeze`, `Adwaita`, `HighContrast` — also in the store.

`pkgs.papirus-icon-theme` ships `Papirus`, `Papirus-Dark` and `Papirus-Light`
together, so switching between them needs no config change beyond `name`.

---

## 9. Desktop and keybindings

Full list: **Mod+K** in niri, or read
`modules/aspects/workstation/wm/niri/binds.kdl` (it is commented).

| Key | Action |
|---|---|
| `Mod+K` | keybinding cheatsheet |
| `Mod+Space` | app launcher |
| `Alt+Tab` | window switcher (hold) |
| `Mod+Return` | kitty |
| `Mod+Shift+T` | ghostty |
| `Mod+Ctrl+V` | clipboard history |
| `Mod+Escape` | session menu (logout / reboot / power off) |
| `Mod+Ctrl+L` | lock screen |
| `Mod+Shift+Ctrl+Space` | theme menu |
| `Mod+Shift+C` | next theme |
| `Mod+Ctrl+Space` | next wallpaper |

`keyd` intercepts `Mod+C` / `Mod+V` / `Mod+X` for clipboard, so plain copy/paste
works everywhere.

Screenshots go to `~/Pictures/Screenshots/`; `grim` + `slurp` are installed, and
Noctalia's screenshot panel is wired to `satty`.

Swayidle blanks the displays after 900 s.

---

## 10. Dev environments

`programs.nix-ld` is **enabled** (in `aspects/workstation/gaming.nix`), so
prebuilt foreign binaries — rustup toolchains, manylinux wheels, game
binaries, downloaded executables — run correctly.

### 10.1 Ad-hoc

```bash
nix shell nixpkgs#cargo nixpkgs#rustc     # temporary shell
nix shell nixpkgs#hello -c hello          # one command
nix run nixpkgs#cowsay -- "moo"           # one app
nix-shell -p python3Packages.numpy         # classic
nix search nixpkgs ripgrep                # search
```

Pinned to a branch: `nix shell github:NixOS/nixpkgs/nixos-24.11#gcc`

### 10.2 Per project — `nix develop` (recommended)

```nix
# flake.nix in the project
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let system = "x86_64-linux"; pkgs = nixpkgs.legacyPackages.${system};
    in { devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ gcc gdb gnumake cmake pkg-config ];
      shellHook = ''echo "C/C++ ready"'';
    }; };
}
```

```bash
nix develop                # enter
nix develop -c make        # one command
git add flake.lock         # pin it — always commit this
```

Two projects can use completely different toolchains with zero conflict.

### 10.3 Auto-enter with direnv

```nix
programs.direnv = { enable = true; nix-direnv.enable = true; };
```

Then per project: `echo "use flake" > .envrc && direnv allow`.

### 10.4 By language

```bash
# Python — python3 is a home package here
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt        # works; nix-ld handles binary wheels

# Rust — not installed globally
nix shell nixpkgs#rustc nixpkgs#cargo
cargo new hello && cd hello && cargo run
nix shell nixpkgs#rustup && rustup toolchain install nightly   # nix-ld makes this work

# C/C++ — gcc is a home package here
nix develop -c bash
g++ -std=c++20 -O2 main.cpp -o main
```

### 10.5 Isolation ladder

1. **Ephemeral CLI** — `nix shell` / `nix run`. Nothing persists.
2. **Dev shell** — `nix develop`. Per-project toolchains. The sweet spot.
3. **Pinned flake** — commit `flake.lock`; reproducible forever.
4. **`nix build`** — produces `./result` without running.
5. **Flatpak** — sandboxed GUI apps with their own runtime:
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   flatpak install flathub com.spotify.Client
   ```
6. **Throwaway VM of this exact config**:
   ```bash
   nixos-rebuild build-vm --flake 'path:/etc/nixos#compulex'
   ./result/bin/run-compulex-vm
   ```
7. **Containers** — enable `boot.enableContainers` and
   `virtualisation.containers.enable`, then `sudo nixos-container create …`.

**Dev shells isolate build tooling. Containers/VMs/flatpak isolate runtimes,
services and untrusted apps.** Not interchangeable.

---

## 11. Known issues on this machine

### 11.1 `lua/plugins/` is only partly loaded

lazy.nvim’s `import` resolves a **module**, and only descends into a
subdirectory that contains an `init.lua`. `dotfiles/nvim/lua/plugins/` is laid
out as `<group>/<spec>.lua` and only `lsp/` has an `init.lua` — so **only
`plugins/lsp/*` loads**. The rest (25 colorscheme specs, blink, neo-tree,
telescope, lualine, …) and all of `lua/config/custom.lua` (`UI`, `Colors`,
`Icons`, `theme.json`, transparency, commands) are dead code.

That is why the Catppuccin spec is duplicated into `lua/config/lazy.lua` — it
is the only place it actually loads.

**Fixing this will activate a lot of previously dormant config in one go.** It
is not a theme change and should be its own deliberate task, verified with a
real nvim session.

### 11.2 Rebuilding is not quick

Noctalia is built from a patched source (`patches/`) and the whole desktop
stack rebuilds together. `nixos-rebuild build` first, then `switch` — the
second is cheap because nothing changed between them.

Caches are configured in `flake.nix`: `nix-community`, `nixpkgs`, `niri-nix`,
`noctalia`. Noctalia has no upstream cache, so its build is always local.

### 11.3 Store growth

No automatic GC. Old generations pin old store paths.

```bash
sudo nix-collect-garbage -d                                              # normal
sudo nix-collect-garbage -d --delete-older-than 0d                       # aggressive, careful
nix-store -q --references /run/current-system                            # what this gen needs
```

### 11.4 `scythe` is not a trusted Nix user

`nix.settings.trusted-users = [ "root" ]`. So building as `scythe` prints
`warning: ignoring untrusted substituter …` and ignores `trusted-public-keys`.
It still works — the caches are just not used for your builds. To fix:

```nix
nix.settings.trusted-users = [ "root" "scythe" ];
```

---

## 12. Troubleshooting

### 12.1 “Existing file … would be clobbered”

Home Manager will not overwrite a file it does not own. Cause: you hand-edited
a generated config, or an unmanaged leftover sits where HM wants to write.

```bash
# read the error — it names the exact files
rm ~/.config/fish/config.fish          # or: mv … config.fish.bak
upp
```

Or opt into backups / force in the owning module:

```nix
home-manager.backupFileExtension = "hm-backup";
xdg.configFile."app/x".force = true;
```

### 12.2 “access to absolute path … is forbidden in pure evaluation mode”

You referenced `/etc/nixos/...` from a module. Use a relative path literal
(`./templates/foo.toml`) or copy the file into the repo. Do **not** reach for
`--impure` as a habit — it makes builds non-reproducible.

### 12.3 “Path … is not tracked by Git”

`git add` the new file. See §5.1.

### 12.4 Build fails, system left half-applied

`nixos-rebuild` sets the profile before finishing activation. Fix the error and
re-run `switch`, or `switch --rollback`.

### 12.5 Theme changed but an app did not

```bash
theme-reapply              # re-render every template
theme-current              # confirm which theme
pgrep -a xsettingsd        # GTK apps need this running
pgrep -a noctalia          # and this
```

Still stale? The app caches its theme at startup — restart it. Nautilus
specifically needs `nautilus -q`, which `theme-set` runs for you via
`theme.restartApps`.

### 12.6 Neovim looks wrong

```bash
nvim --headless -c 'lua print(vim.g.colors_name)' -c 'qa!'   # which colorscheme
ls ~/.config/nvim                                          # should symlink into the repo
cd /etc/nixos/dotfiles/nvim && nvim                         # run from the real path
```

If it says `noctalia`, you are on a machine where the base16 overlay is still
installed — it was removed on 2026-10-02.

### 12.7 “unfree package” refused

`allowUnfree = true` is already global. A new flake input may need
`allowUnfreePredicate` in the module that uses it.

### 12.8 Dirty-tree warnings

Silenced: `nix.settings.warn-dirty = false` in `aspects/core/common.nix`.

---

## 13. Context for AI agents

- `/etc/nixos` is the **only** active NixOS config on this machine: a
  **den + flake-parts + import-tree** flake for host `compulex`, user `scythe`,
  output `nixosConfigurations.compulex`.
- **Edit `.nix` sources under `modules/`.** Never hand-edit generated
  `~/.config` or `/etc` files. The one runtime-owned exception is
  `gtk-{3,4}.0/settings.ini`, which `theme-set` rewrites deliberately.
- **Rebuild:** `sudo nixos-rebuild switch --flake 'path:/etc/nixos#compulex'`
  — the `path:` prefix is mandatory here (§5.2). Verify first with
  `nixos-rebuild build` or `nix flake check`.
- **New files must be `git add`ed** before Nix can see them (§5.1).
- Aspect shape: `den.aspects.<group>.<name>` with `includes`, `nixos`,
  `homeManager`. `<group>/default.nix` aggregates the group.
- User packages → an aspect’s `home.packages` or `users/scythe.nix`.
  System services/packages → an aspect’s `nixos`.
- Neovim lives in `dotfiles/nvim` in this repo, symlinked to `~/.config/nvim`.
  **Known issue:** only `lua/plugins/lsp/` loads (§11.1).
- Colour comes from **Noctalia**, not from Neovim — `theme-set` repaints
  kitty, ghostty, GTK, Qt, btop, cava, niri, starship, mpv, yazi, fastfetch and
  Vesktop.
- Dev tooling is per-project (`nix develop`). `gcc` and `python3` are home
  packages; `rustc`/`cargo`/`go` are not installed. `nix-ld` and `flatpak` are on.
- Keep evaluation pure (relative paths inside the repo) unless `--impure` is
  genuinely required.
