# mesa-shell

Status bar, notification daemon, quick settings panel and lockscreen for [Quickshell](https://github.com/outfoxxed/quickshell), built for Sway.

![mesa-shell](assets/screenshot.png)

## Dependencies

- [quickshell](https://github.com/outfoxxed/quickshell)
  - upower: [`Quickshell.Services.UPower`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.UPower/)
  - pipewire: [`Quickshell.Services.Pipewire`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/)
  - networkmanager: [`Quickshell.Networking`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/)
  - bluez: [`Quickshell.Bluetooth`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/)
  - pam: [`Quickshell.Services.Pam`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pam/)
- [`qt6-5compat`](https://archlinux.org/packages/extra/x86_64/qt6-5compat/)
- [sway](https://github.com/swaywm/sway)
- [systemd](https://github.com/systemd/systemd)
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) (optional)
- [`socat`](http://www.dest-unreach.org/socat/) (`scripts/mesa-dmenu` only)

## Installation

```bash
git clone git@github.com:accmeboot/mesa-shell.git ~/.config/quickshell/mesa-shell
cp ~/.config/quickshell/mesa-shell/config.example.json ~/.config/quickshell/mesa-shell/config.json
```

Sway config:

```
exec qs -c mesa-shell -d
bindsym $mod+d exec qs -c mesa-shell ipc call dmenu toggle
bindsym $mod+p exec qs -c mesa-shell ipc call settingsWindow toggle
```

### NixOS

Flake input:

```nix
inputs.mesa-shell = {
  url = "github:accmeboot/mesa-shell";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Home Manager (`inputs` passed via `extraSpecialArgs`):

```nix
{ inputs, ... }: {
  imports = [ inputs.mesa-shell.homeManagerModules.default ];

  programs.mesa-shell = {
    enable = true;
    settings = { }; # written to config.json, same keys as below
  };

  # replaces `exec qs -c mesa-shell -d`
  programs.quickshell.systemd = {
    enable = true;
    target = "sway-session.target";
  };
}
```

NixOS services used by the modules:

```nix
services.upower.enable = true;
services.pipewire.enable = true;
networking.networkmanager.enable = true;
hardware.bluetooth.enable = true;
```

## Modules

- **Bar**: workspaces, mode, launcher, tray, CPU, RAM, battery, network, notifications, theme, clock
- **Notifications**: `org.freedesktop.Notifications` daemon
- **Settings**: audio, display, network, bluetooth, about, power
- **Lock**: `ext-session-lock-v1` lockscreen
- **Wallpaper**: background layer

## IPC

```bash
qs -c mesa-shell ipc call <target> <function>
```

| Target | Functions |
| --- | --- |
| `dmenu` | `open`, `close`, `toggle` |
| `settingsWindow` | `open`, `close`, `toggle`, `view <audio\|display\|network\|bluetooth\|about>` |
| `lock` | `lock`, `isLocked` |
| `config` | `reload` |

## Config

`config.json` next to `shell.qml`, see `config.example.json`. Every key is optional.

| Key | Default | Notes |
| --- | --- | --- |
| `colors.{dark,light}.background` | `#1d2021` / `#fbf1c7` | |
| `colors.{dark,light}.surface` | `#3c3836` / `#ebdbb2` | |
| `colors.{dark,light}.on_surface` | `#504945` / `#d5c4a1` | |
| `colors.{dark,light}.foreground` | `#d5c4a1` / `#3c3836` | |
| `colors.{dark,light}.highlight` | `#83a598` / `#076678` | |
| `colors.{dark,light}.ok` | `#b8bb26` / `#79740e` | |
| `colors.{dark,light}.attention` | `#fabd2f` / `#b57614` | |
| `colors.{dark,light}.critical` | `#fb4934` / `#9d0006` | |
| `font.name` | `JetBrainsMono Nerd Font` | |
| `font.size` | `12` | |
| `wallpaper` | `assets/sway.png` | `""` for none |
| `dateTimeFormat` | `ddd d MMM HH:mm` | `Qt.formatDateTime` |
| `defaultPolarity` | `dark` | `dark` or `light` |
| `hooks.onDarkThemeSet` | `""` | shell command |
| `hooks.onLightThemeSet` | `""` | shell command |
| `spacing` | `10` | px |
| `border` | `1` | px |

## dmenu script

`scripts/mesa-dmenu` shows stdin lines in the bar launcher and prints the chosen one. Prints nothing on cancel.

```bash
printf 'a\nb\n' | scripts/mesa-dmenu
```

As the xdg-desktop-portal-wlr screen chooser:

```ini
[screencast]
chooser_type=dmenu
chooser_cmd=/path/to/mesa-dmenu
```

On NixOS:

```nix
xdg.portal.wlr.settings.screencast = {
  chooser_type = "dmenu";
  chooser_cmd = lib.getExe inputs.mesa-shell.packages.${pkgs.stdenv.hostPlatform.system}.mesa-dmenu;
};
```

## License

[Apache 2.0](LICENSE)
