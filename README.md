# mesa-shell

Status bar, notification daemon and lockscreen for [Quickshell](https://github.com/outfoxxed/quickshell), built for [sway](https://swaywm.org).

![mesa-shell](assets/screenshots/desktop.png)

More screenshots in [`assets/screenshots`](assets/screenshots).

## Dependencies

- [quickshell](https://github.com/outfoxxed/quickshell)
  - upower: [`Quickshell.Services.UPower`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.UPower/)
  - pipewire: [`Quickshell.Services.Pipewire`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/)
  - networkmanager: [`Quickshell.Networking`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/)
  - bluez: [`Quickshell.Bluetooth`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/)
  - pam: [`Quickshell.Services.Pam`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pam/)
- [`bluetoothctl`](https://github.com/bluez/bluez) from bluez (pairing agent)
- [sway](https://swaywm.org): [`Quickshell.I3`](https://quickshell.org/docs/v0.3.1/types/Quickshell.I3/), `swaymsg`
- [systemd](https://github.com/systemd/systemd)
- [`gsettings`](https://gitlab.gnome.org/GNOME/glib) from glib2 with gsettings-desktop-schemas (dark theme)
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) (optional)
- [`fuser`](https://gitlab.com/psmisc/psmisc) from psmisc (optional, camera detection)
- [`socat`](http://www.dest-unreach.org/socat/) (`mshell dmenu` only)
- [`jq`](https://jqlang.org) (`mshell`)
- [python](https://www.python.org) with [numpy](https://numpy.org) and [pillow](https://python-pillow.github.io) (`mshell build`'s retint)
- [`yazi`](https://github.com/sxyazi/yazi) (optional, `mshell wall`'s picker)
- [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) (optional, the default `iconTheme`)
- [Terminess Nerd Font](https://www.nerdfonts.com) (optional, the default `font` in `config.example.json`)
- [adw-gtk3](https://github.com/lassekongo83/adw-gtk3) and [qt5ct](https://sourceforge.net/projects/qt5ct/)/[qt6ct](https://github.com/trialuser02/qt6ct) (theming GTK3 and Qt apps)

## Installation

```bash
git clone git@github.com:accmeboot/mesa-shell.git ~/setup/mesa-shell
~/setup/mesa-shell/install.sh
```

Start it from the sway config:

```
exec mshell run

bindsym $mod+d exec mshell dmenu toggle
bindsym $mod+p exec mshell panel toggle audio
bindsym $mod+Shift+p exec mshell panel toggle microphone
bindsym $mod+n exec mshell panel toggle network
bindsym $mod+c exec mshell panel toggle bluetooth
bindsym $mod+t exec mshell panel toggle tray
bindsym $mod+q exec mshell panel toggle control
bindsym $mod+grave exec mshell theme toggle
bindsym $mod+backslash exec mshell notifications toggle
bindsym $mod+bracketleft exec mshell notifications dismissLast
bindsym $mod+bracketright exec mshell notifications dismissAll
```

## Modules

- **Bar**: workspaces, binding mode, launcher, clock and tray
  - click a workspace to switch to it
  - the current binding mode (`resize`, ...) shows next to the workspaces while it isn't `default`
  - audio, microphone, network, battery, bluetooth and control each open their own panel from the bar
  - the audio panel holds the output devices and playback streams, the microphone panel the input devices and recording streams
  - the control panel holds the brightness slider, the dark theme and do-not-disturb toggles and the session actions (lock, suspend, log out, restart, shut down)
  - the dark theme toggle switches the desktop's `color-scheme` setting, and the shell follows that setting whoever changes it
  - a privacy indicator while the microphone, camera or screen share is in use, with a panel listing each app and what it uses
- **Notifications**: `org.freedesktop.Notifications` daemon
- **Lock**: `ext-session-lock-v1` lockscreen
- **Wallpaper**: background layer

### Panels

| Network | Bluetooth |
| --- | --- |
| ![Network panel](assets/screenshots/network.png) | ![Bluetooth panel](assets/screenshots/bluetooth.png) |
| **Audio** | **Control** |
| ![Audio panel](assets/screenshots/audio.png) | ![Control panel](assets/screenshots/control.png) |
| **Battery** | **Privacy** |
| ![Battery panel](assets/screenshots/battery.png) | ![Privacy panel](assets/screenshots/privacy.png) |
| **Launcher** | **Notification** |
| ![dmenu launcher](assets/screenshots/dmenu.png) | ![Notification](assets/screenshots/notification.png) |
| **Tray menu** | **Lock screen** |
| ![Tray menu](assets/screenshots/tray-menu.png) | ![Lock screen](assets/screenshots/lock.png) |

## mshell

```
mshell run [qs args...]             start the shell (qs -c mesa-shell)
mshell build                        generate both palettes, render templates, write colors into config.json
mshell status                       show the built palettes
mshell wall <dark|light> [image]    set a polarity's wallpaper and build
mshell apply [dark|light]           point GTK3, Qt and the icon theme at a polarity (default: current)
mshell dmenu                        pick one of stdin's lines in the bar launcher and print it
mshell <target> <function> [args]   qs -c mesa-shell ipc call <target> <function> [args]
mshell ipc ...                      qs -c mesa-shell ipc ... (e.g. mshell ipc show)
```

## Theming

There are two palettes, `dark` and `light`. Each one starts from a base16 scheme (`theme/schemes/<name>.yaml`, or a path), retinted toward its wallpaper if it has one. `mshell build` regenerates both and themes the shell, the apps below and the [templates](#templates).

`mshell wall <dark|light>` without an image opens a yazi picker in `wallpaper.dir` (`Enter` picks, `q` cancels).

### Dark and light

Everything switches together with the desktop's color-scheme setting, whether it's changed from the control panel, `mshell theme toggle` or elsewhere.

| Themed | Notes |
| --- | --- |
| GTK3, GTK4 / libadwaita | |
| Qt | needs `QT_QPA_PLATFORMTHEME=qt5ct` in the session |
| Icons | `iconTheme.<polarity>` |
| ghostty, nvim | |
| sway borders | `include ~/.local/state/mshell/current/sway` in the sway config |
| Fonts | the configured fonts become the default `sans-serif`, `serif` and `monospace` |

### Templates

`theme/templates/<path>` renders to `~/.local/state/mshell/<polarity>/<path>`. Only plain `{{name}}` substitution is supported, with no mustache sections.

| Variable | Value |
| --- | --- |
| `{{base0D-hex}}`, `{{base0D-rgb-r}}`, `{{base0D-dec-r}}`, `{{scheme-name}}`, `{{scheme-variant}}`, ... | everything in the [base16 builder spec](https://github.com/tinted-theming/home/blob/main/builder.md) |
| `{{highlight-hex}}`, `{{highlight-rgb-r}}`, ... | the highlight color, in the same formats as the base colors. Picked from the wallpaper, or `base0D` without one |
| `{{output-dir}}` | the directory the polarity's files are rendered into |
| `{{wallpaper}}` | the polarity's wallpaper |
| `{{icon-theme}}` | `iconTheme.<polarity>` |
| `{{font-sans}}`, `{{font-serif}}`, `{{font-mono}}` | the configured fonts |
| `{{font-size-applications}}`, `{{font-size-desktop}}`, `{{font-size-terminal}}` | the configured font sizes |

## IPC

| Target | Functions |
| --- | --- |
| `panel` | `open <name>`, `close`, `toggle <name>` |
| `dmenu` | `open`, `close`, `toggle` |
| `lock` | `lock`, `isLocked` |
| `theme` | `toggle`, `isDark` |
| `notifications` | `toggle`, `isDoNotDisturb`, `dismissLast`, `dismissAll` |
| `config` | `reload` |

Panel names: `audio`, `network`, `bluetooth`, `battery`, `control`, `tray`, `privacy`. `privacy` only opens while a microphone, camera or screen share is in use.

```bash
mshell panel toggle audio
```

## Keyboard navigation

An open panel takes keyboard focus. Hovering a row selects it too, and opens its menu if it has one.

| Key | Action |
| --- | --- |
| `Down`, `j` | next row, or next entry while a menu is open |
| `Up`, `k` | previous row, or previous entry while a menu is open |
| `Right`, `l` | open the selected row's menu |
| `Left`, `h` | close the open menu |
| `Shift+Right`, `Shift+l` | increase the open menu's slider |
| `Shift+Left`, `Shift+h` | decrease the open menu's slider |
| `Enter`, `Space` | activate the selection |
| `Escape` | close the panel |

The brightness slider in the control panel is adjusted with `Left`/`h` and `Right`/`l` while selected. Sliders move in 1% steps.

### Menu text entry

In text fields, such as the Wi-Fi password prompt, `h`, `j`, `k` and `l` type rather than navigate; the arrow keys still navigate.

| Key | Action |
| --- | --- |
| `Backspace` | delete the last character |
| `Ctrl+Backspace`, `Ctrl+u` | clear the field |
| `Enter` | submit, once the field is not empty |

### Tray menus

`panel toggle tray` opens the first tray menu.

| Key | Action |
| --- | --- |
| `Down`, `j` | next entry |
| `Up`, `k` | previous entry |
| `l` | open submenu |
| `h` | back to the parent menu |
| `Shift+l`, `Shift+Right` | next tray menu |
| `Shift+h`, `Shift+Left` | previous tray menu |
| `Enter`, `Space` | activate entry |
| `Escape` | close the menu |

### Launcher

| Key | Action |
| --- | --- |
| `Down`, `Right`, `Tab`, `Ctrl+j`, `Ctrl+l` | next item |
| `Up`, `Left`, `Shift+Tab`, `Ctrl+k`, `Ctrl+h` | previous item |
| `Enter` | run the selection, or the typed command |
| `Escape` | close |

## Config

`config.json` next to `shell.qml`, see `config.example.json`. Every key is optional. It configures both the shell and `mshell`; run `mshell build` after changing the theming keys. `colors` is written by `mshell build`, so edits to it last until the next build; change `scheme` instead.

Paths are absolute, `~/` or relative to the repo.

| Key | Default | Notes |
| --- | --- | --- |
| `scheme.{dark,light}` | `default-dark` / `default-light` | `theme/schemes/<name>.yaml`, or a path |
| `iconTheme.{dark,light}` | `Papirus-Dark` / `Papirus-Light` | |
| `retint.rotate` | `15` | `retint.py --rotate` |
| `retint.tint` | `0.15` | `retint.py --tint` |
| `retint.maxRampChroma` | `0.030` | `retint.py --max-ramp-chroma` |
| `colors.{dark,light}.background` | `#16181a` / `#faf8f3` | |
| `colors.{dark,light}.surface` | `#26282a` / `#eae8e3` | |
| `colors.{dark,light}.on_surface` | `#36383a` / `#dad8d3` | |
| `colors.{dark,light}.foreground` | `#d6d9da` / `#393834` | |
| `colors.{dark,light}.highlight` | `#81adc7` / `#78b1ba` | |
| `colors.{dark,light}.ok` | `#8eba7a` / `#b3af62` | |
| `colors.{dark,light}.attention` | `#ead086` / `#ead086` | |
| `colors.{dark,light}.critical` | `#a94459` / `#a94b27` | |
| `font.name` | `""` | `""` uses the fontconfig default |
| `font.size` | `""` | pt, `""` uses the fontconfig default |
| `font.serif` | `""` | templates only |
| `font.mono` | `""` | templates only |
| `font.applicationsSize` | `""` | pt, templates and GTK only |
| `font.terminalSize` | `""` | pt, templates only |
| `wallpaper.{dark,light}` | `assets/wallpaper-dark.png` / `assets/wallpaper-light.jpg` | `""` for none |
| `wallpaper.dir` | `~/Pictures` | where `mshell wall` opens its picker |
| `dateTimeFormat` | `ddd d MMM HH:mm` | `Qt.formatDateTime` |
| `spacing` | `10` | px |
| `border` | `1` | px |

## dmenu

`mshell dmenu` shows stdin lines in the bar launcher and prints the chosen one. Prints nothing on cancel.

```bash
printf 'a\nb\n' | mshell dmenu
```

As the xdg-desktop-portal-wlr screen chooser:

```ini
[screencast]
chooser_type=dmenu
chooser_cmd=/path/to/mshell dmenu
```

## License

[Apache 2.0](LICENSE)
