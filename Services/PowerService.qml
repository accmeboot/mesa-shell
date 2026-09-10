pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  function run(command: string): void {
    process.command = ["sh", "-c", command];
    process.running = true;
  }

  function suspend(): void {
    root.run("systemctl suspend");
  }

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
