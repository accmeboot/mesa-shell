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
- [`gsettings`](https://gitlab.gnome.org/GNOME/glib) from glib2 with gsettings-desktop-schemas (dark theme follows and toggles `org.gnome.desktop.interface color-scheme`)
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) (optional)
- [`fuser`](https://gitlab.com/psmisc/psmisc) from psmisc (optional, camera detection for apps opening `/dev/video*` directly)
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

`install.sh` installs the packages above from the Arch repos (sway itself is left to the compositor setup), enables NetworkManager and bluetooth, writes the GTK3/GTK4/fontconfig theme files (see Theming), copies `config.example.json` to `config.json` unless it exists, links the repo to `~/.config/quickshell/mesa-shell` and `mshell` to `~/.local/bin`, and runs `mshell build`. It uses `pacman -Syu`, never `-S`: installing against a stale package database is a partial upgrade.

Start it from the sway config. sway sets `XDG_CURRENT_DESKTOP=sway`, which picks the sway backend:

```
exec mshell run

bindsym $mod+d exec mshell dmenu toggle
bindsym $mod+p exec mshell panel toggle audio
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
  - audio, network, battery, bluetooth and control each open their own panel from the bar
  - the control panel holds the brightness slider, the dark theme and do-not-disturb toggles and the session actions (lock, suspend, log out, restart, shut down)
  - the dark theme toggle switches the desktop's `color-scheme` setting, and the shell follows that setting whoever changes it
  - privacy indicators for microphone, camera and screen share, with a panel listing the apps using them
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

`mshell`'s own commands must never share a name with an IPC target, or the target becomes unreachable through it. The one exception is `dmenu`: with no function it runs the picker, with one (`mshell dmenu toggle`) it goes to the IPC target.

## Theming

There are two palettes, `dark` and `light`. Each one starts from a base16 scheme (`theme/schemes/<name>.yaml`, or a path) and can have a wallpaper.

`mshell build`:

1. retints each scheme toward its wallpaper (`theme/retint.py`). A scheme without a wallpaper is used as is
2. writes the shell's `colors.dark` and `colors.light` into `config.json`
3. renders every file in `theme/templates/` into `~/.local/state/mshell/{dark,light}/` (see [Templates](#templates))
4. if gsettings is writable, sets the GTK fonts that live there rather than in a file (`font-name`, `monospace-font-name`) and runs `mshell apply` for the current polarity
5. signals the apps that don't watch their files to reload: ghostty (`SIGUSR2`) and nvim (`SIGUSR1`)

Files are rewritten in place, so anything watching them (such as the shell watching `config.json`) sees the change.

`mshell wall <dark|light> [image]` sets `wallpaper.<polarity>` and builds. Without an image it opens yazi in `wallpaper.dir` as a file picker (`Enter` picks, `q` cancels).

### Dark and light

Both palettes are always rendered; the build doesn't track which one is active. Apps follow the desktop's color-scheme setting (`org.gnome.desktop.interface color-scheme`). Some do that on their own. For the rest, the shell runs `mshell apply <polarity>` on startup and whenever the setting changes.

| App | How it switches |
| --- | --- |
| GTK4 / libadwaita | On its own. `~/.config/gtk-4.0/gtk.css` imports both palettes, each wrapped in `@media (prefers-color-scheme: ...)` |
| ghostty, nvim | On their own |
| GTK3 | `apply` sets `gtk-theme` to `base16-dark` / `base16-light` (adw-gtk3 with the palette on top). GTK3 has no color-scheme preference, so each palette is a separate theme |
| Qt | `apply` links `qt5ct.conf` / `qt6ct.conf` to the polarity's `qtct.conf`, which sets the color scheme, icon theme and fonts. qt5ct/qt6ct reload on their own. Needs `QT_QPA_PLATFORMTHEME=qt5ct` in the session (qt6ct also answers to that name) |
| Icons | `apply` sets `icon-theme` to `iconTheme.<polarity>` |
| sway | `apply` points `~/.local/state/mshell/current` at the polarity and sends its `sway` file (the `client.*` border colors) to the running sway. Include `~/.local/state/mshell/current/sway` in the sway config so a reload or a new session picks it up too |

Fonts don't depend on the polarity. `~/.config/fontconfig/fonts.conf` includes the rendered `fonts.conf`, which puts the configured fonts in front of `sans-serif`, `serif` and `monospace`. They are inserted right before the generic name, not at the top of the list, so a font an app asks for by name still wins.

`install.sh` writes the GTK3 themes every time. It writes the GTK4 and fontconfig configs only if they don't exist yet.

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

An open panel takes keyboard focus and selects its first interactive element, drawn as a fill in the highlight colour. Selection follows the mouse too: hovering an interactive row selects it, and opens that row's menu if it has one.

Panels are built from rows. A row either acts on its own or opens a menu, and `Down`/`Up` move between rows until a menu is open, at which point they move within it.

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

Sliders live inside menus, except for brightness, which sits directly in the control panel. That one takes the selection itself, and `Left`/`h` and `Right`/`l` then decrease and increase it. Either kind moves in 1% steps.

### Menu text entry

A menu entry can be a text field, such as the Wi-Fi password prompt. While one is selected, printable keys type into it, so `h`, `j`, `k` and `l` insert characters rather than navigating. The arrow keys still navigate.

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
