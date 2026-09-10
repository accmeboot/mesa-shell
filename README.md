# mesa-shell

A minimal status bar, notification daemon, quick settings panel and lockscreen
for [Quickshell](https://github.com/outfoxxed/quickshell), built for Sway.

The settings panel is a `wlr-layer-shell` surface pinned to the top right
corner, laid out like a quick settings menu: a home view where each section is
one line showing its status, with the volume and brightness sliders inline, and
a sub-view per section reached through the `>` chevrons. A footer bar mirroring
the title row holds the lock, suspend, restart and shutdown buttons; restart and
shutdown ask for confirmation first. It opens on the focused Sway output, and
closes on `Escape` or a click anywhere else on the desktop.

The lockscreen covers every output with the wallpaper, dimmed, and the user
name above a password field in the middle. It is an `ext-session-lock-v1` lock,
so if the shell dies while locked the compositor keeps the session locked rather
than exposing it. `Enter` submits the password, `Escape` clears it, and a wrong
password turns the field's border to `colors.critical`. The bottom right corner
shows the clock followed by exit session, restart and shutdown buttons.

![mesa-shell](assets/screenshot.png)

## Dependencies

| Dependency | Used for |
| --- | --- |
| [Quickshell](https://github.com/outfoxxed/quickshell) | The runtime the whole shell is built on |
| `qt6.qt5compat` | `Qt5Compat.GraphicalEffects`, used to recolour the SVG icons |
| Sway | Workspaces and binding mode over the Sway IPC socket; the bar and notifications are `wlr-layer-shell` surfaces |
| UPower | Battery widget and the About view's battery details |
| PipeWire | Audio view: sinks, sources, playback and recording streams |
| NetworkManager | Network widget and the Wi-Fi / Ethernet views |
| BlueZ | Bluetooth view: adapters, pairing, connecting |
| PAM | Lockscreen: the password is checked against the `login` service in `/etc/pam.d` |
| systemd | The suspend, restart and shutdown buttons — `systemctl suspend`, `reboot` and `poweroff` |
| `brightnessctl` | Display view: reading and setting the backlight. Optional — where no `/sys/class/backlight` device exists (desktops, external monitors over DisplayPort/HDMI) the brightness slider is hidden and the rest of the Display view still works |

The shell registers itself as the `org.freedesktop.Notifications` service, so it
will not show notifications while another daemon (mako, dunst, ...) holds that
name.

Any font available to fontconfig works — no Nerd Font glyphs are used; every
icon is an SVG in `assets/`.

## IPC

Quickshell names a config after the directory it sits in, so cloning this repo
as `mesa-shell` registers it under that name rather than as the `default`
config. Every command therefore needs `-c mesa-shell`; without it you get
`Could not find "default" config directory or shell.qml in any valid config path.`

Handlers are reachable through `qs -c mesa-shell ipc call <target> <function>`.
Run `qs -c mesa-shell ipc show` to list them from a running instance.

### `dmenu` — the launcher in the bar

```bash
qs -c mesa-shell ipc call dmenu open
qs -c mesa-shell ipc call dmenu close
qs -c mesa-shell ipc call dmenu toggle
```

### `settingsWindow` — the quick settings panel

```bash
qs -c mesa-shell ipc call settingsWindow open
qs -c mesa-shell ipc call settingsWindow close
qs -c mesa-shell ipc call settingsWindow toggle
```

`view` opens the panel straight onto a sub-view — `audio`, `display`,
`network`, `bluetooth` or `about`. Any other name lands on the home view.

```bash
qs -c mesa-shell ipc call settingsWindow view network
```

### `lock` — the lockscreen

```bash
qs -c mesa-shell ipc call lock lock
qs -c mesa-shell ipc call lock isLocked
```

There is no `unlock` — only the password ends the lock. Point an idle daemon at
`lock` instead of swaylock, e.g. for hypridle:

```
general {
  lock_cmd = qs -c mesa-shell ipc call lock lock
  before_sleep_cmd = loginctl lock-session
}
```

File watching is paused while locked: a reload hands the lock to a fresh
instance that starts unlocked, which would release it. Save a file again after
unlocking to pick up edits made while the screen was locked.

### `config` — re-read `config.json`

```bash
qs -c mesa-shell ipc call config reload
```

The config file is watched and reloaded on change, so this is only needed when
something writes it in a way the watcher misses.

### Sway keybindings

```
bindsym $mod+d exec qs -c mesa-shell ipc call dmenu toggle
bindsym $mod+p exec qs -c mesa-shell ipc call settingsWindow toggle
bindsym $mod+n exec qs -c mesa-shell ipc call settingsWindow view network
```

## Installation

Clone the repository into your Quickshell config directory. The directory name
becomes the config name:

```bash
git clone git@github.com:accmeboot/mesa-shell.git ~/.config/quickshell/mesa-shell
```

That leaves `~/.config/quickshell/mesa-shell/shell.qml` in place.

Create a config from the example:

```bash
cp ~/.config/quickshell/mesa-shell/config.example.json \
   ~/.config/quickshell/mesa-shell/config.json
```

`config.json` holds the colours, font, wallpaper, `spacing` and `border`
values. It is watched at runtime, so edits apply without restarting.

Run it:

```bash
qs -c mesa-shell
```

To start it with Sway, add this to your Sway config:

```
exec qs -c mesa-shell -d
```

## Configuration

`config.json` lives next to `shell.qml` and is watched at runtime, so saving it
re-applies immediately. Every key is optional — anything you leave out falls
back to the default below.

### `colors`

The palette is eight semantic roles rather than a fixed set of hues, so a value
is chosen by what it signals, not by what colour it is. `colors.dark` and
`colors.light` each hold all eight roles; the shell draws with the set that
matches the current polarity (see `defaultPolarity`).

| Key | Dark default | Light default | Used for |
| --- | --- | --- | --- |
| `background` | `#1d2021` | `#fbf1c7` | Bar, panel and menu backgrounds |
| `surface` | `#3c3836` | `#ebdbb2` | Raised fills — buttons, dropdowns, hovered and opened rows, the panel's title and footer bars |
| `on_surface` | `#504945` | `#d5c4a1` | Every border, and text for secondary values (`Unknown`, `Not paired`) or disabled controls |
| `foreground` | `#d5c4a1` | `#3c3836` | Primary text and icons |
| `highlight` | `#83a598` | `#076678` | Accent — focused workspace, the hovered dropdown option, text selection, slider fill |
| `ok` | `#b8bb26` | `#79740e` | Healthy state — connected, paired, enabled, normal threshold band |
| `attention` | `#fabd2f` | `#b57614` | Transitional or warning state — connecting, pairing, scanning, warning threshold band |
| `critical` | `#fb4934` | `#9d0006` | Failure or urgent state — disconnected, errors, urgent notifications, critical threshold band |

### `font`

| Key | Type | Default | Used for |
| --- | --- | --- | --- |
| `font.name` | string | `JetBrainsMono Nerd Font` | Any family fontconfig can resolve |
| `font.size` | number | `12` | Point size; icon sizes are derived from it |

### `wallpaper`

| Key | Type | Default | Used for |
| --- | --- | --- | --- |
| `wallpaper` | string | `assets/sway.png` | Path to the image drawn on the background layer. Absolute paths, `~/...` and paths relative to the shell directory all work. Set it to `""` for no image — the layer stays filled with `colors.background` |

The wallpaper is a `wlr-layer-shell` surface on the background layer, one per
output, so nothing else needs to paint the desktop. It is input-transparent and
claims no exclusive zone, so tiling is unaffected. The image is cropped to fill
the output and decoded at that resolution; an image whose aspect ratio is far
from the screen's is upscaled after the crop, so match it roughly.

Changing the path swaps the image without a gap — `Image.retainWhileLoading`
keeps the current one on screen until the new file has finished decoding, so a
large image or a path that fails to load never blanks the desktop.

`config.json` is watched for edits, but a symlink being *replaced* — how
Home Manager and its specialisations install the file — does not raise a change
event. Call the IPC handler after switching to pick the new file up:

```bash
qs -c mesa-shell ipc call config reload
```

Keep an `output * bg <color> solid_color` line in the Sway config as a fallback
— it covers the frames before the shell maps its surfaces, and is what shows
whenever the shell is not running.

### `defaultPolarity`

| Key | Type | Default | Used for |
| --- | --- | --- | --- |
| `defaultPolarity` | string | `dark` | The palette the shell starts with — `dark` or `light` |

It is read once, when the shell starts. From then on the theme button in the bar
owns the polarity, and reloading `config.json` does not reset it.

### `hooks`

| Key | Type | Default | Used for |
| --- | --- | --- | --- |
| `hooks.onDarkThemeSet` | string | `""` | Shell command run when the theme button switches to dark |
| `hooks.onLightThemeSet` | string | `""` | Shell command run when the theme button switches to light |

A click switches the palette immediately and then runs the matching hook through
`sh -c`. While a hook is still running further clicks are ignored. Leave a hook
empty to only switch the shell's own colours.

### Metrics

| Key | Type | Default | Used for |
| --- | --- | --- | --- |
| `spacing` | number | `10` | The base unit in pixels. Widget padding, row heights and the gaps between items derive from it, so raising it loosens the whole shell at once |
| `border` | number | `1` | Border width in pixels for every bordered element |

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
