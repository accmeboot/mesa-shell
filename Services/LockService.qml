pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick

Singleton {
  id: root

  readonly property string user: Quickshell.env("USER") ?? ""
  readonly property bool authenticating: pam.active

  property bool locked: false
  property bool failed: false

  property string password: ""

  function lock(): void {
    root.password = "";
    root.failed = false;
    root.locked = true;
  }

  function input(text: string): void {
    root.password = text;
    root.failed = false;
  }

  function submit(): void {
    if (pam.active || root.password === "") return;

    root.failed = false;
    pam.start();
  }

  PamContext {
    id: pam

    config: "login"

    onPamMessage: {
      if (pam.responseRequired) pam.respond(root.password);
    }

    onCompleted: result => {
      root.password = "";

      if (result === PamResult.Success) root.locked = false;
      else root.failed = true;
    }
  }

  IpcHandler {
    target: "lock"

    function lock(): void {
      root.lock();
    }

    function isLocked(): bool {
      return root.locked;
    }
  }
}
