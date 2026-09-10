pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  function run(command: string): void {
    process.command = ["sh", "-c", command];
    process.running = true;
  }

  // matches the lock_cmd in hypridle.conf, so a running swaylock is not stacked
  function lock(): void {
    root.run("pidof swaylock || swaylock -f");
  }

  function suspend(): void {
    root.run("systemctl suspend");
  }

  // sway owns the session, so ending it drops back to the display manager
  function exitSession(): void {
    root.run("swaymsg exit");
  }

  function reboot(): void {
    root.run("systemctl reboot");
  }

  function shutdown(): void {
    root.run("systemctl poweroff");
  }

  Process {
    id: process
  }
}
