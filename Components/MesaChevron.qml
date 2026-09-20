import QtQuick
import QtQuick.Layouts

import qs.Services

MesaIcon {
  id: root

  property bool expanded: false

  Layout.alignment: Qt.AlignVCenter

  name: "pan-end"
  size: ConfigService.iconSizeSmall
  rotation: root.expanded ? -90 : 90
}
