import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property bool expanded: false

  Layout.fillWidth: true
  Layout.topMargin: root.expanded ? ConfigService.gapSmall : 0
  Layout.bottomMargin: root.expanded ? ConfigService.gapSmall : 0

  spacing: 0
}
