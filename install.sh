#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "run as your user, not root: mesa-shell links itself into your home" >&2
  exit 1
fi

cd "$(dirname "$(readlink -f "$0")")"

packages=(
  quickshell

  upower
  pipewire
  networkmanager
  bluez
  pam

  bluez-utils
  glib2
  gsettings-desktop-schemas
  brightnessctl
  psmisc
  socat

  jq
  python
  python-numpy
  python-pillow
  yazi
  papirus-icon-theme
  adw-gtk-theme
  qt5ct
  qt6ct
)

sudo pacman -Syu --needed "${packages[@]}"

sudo systemctl enable --now NetworkManager.service bluetooth.service

if [[ ! -e config.json ]]; then
  cp -p config.example.json config.json
fi

config="${XDG_CONFIG_HOME:-$HOME/.config}"
state="${XDG_STATE_HOME:-$HOME/.local/state}/base16"
themes="${XDG_DATA_HOME:-$HOME/.local/share}/themes"

quickshell="$config/quickshell"
mkdir -p "$quickshell"
if [[ -e $quickshell/mesa-shell && ! -L $quickshell/mesa-shell ]]; then
  echo "skipping $quickshell/mesa-shell: exists and is not a symlink" >&2
else
  ln -sfn "$PWD" "$quickshell/mesa-shell"
fi

for polarity in dark light; do
  base=adw-gtk3
  [[ $polarity == dark ]] && base=adw-gtk3-dark
  mkdir -p "$themes/base16-$polarity/gtk-3.0"
  cat >"$themes/base16-$polarity/gtk-3.0/gtk.css" <<EOF
@import url("file:///usr/share/themes/$base/gtk-3.0/gtk.css");
@import url("file://$state/$polarity/gtk3.css");
EOF
done

write_once() {
  if [[ -e $1 ]]; then
    echo "keeping existing $1"
    return
  fi
  mkdir -p "$(dirname "$1")"
  cat >"$1"
}

write_once "$config/gtk-4.0/gtk.css" <<EOF
@import url("file://$state/dark/gtk4.css");
@import url("file://$state/light/gtk4.css");
EOF

write_once "$config/fontconfig/fonts.conf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">$state/dark/fonts.conf</include>
</fontconfig>
EOF

bin="$HOME/.local/bin"
mkdir -p "$bin"
if [[ -e $bin/mshell && ! -L $bin/mshell ]]; then
  echo "skipping $bin/mshell: exists and is not a symlink" >&2
else
  ln -sfn "$PWD/mshell" "$bin/mshell"
fi

"$bin/mshell" build
