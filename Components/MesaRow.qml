import QtQuick
import QtQuick.Layouts

import qs.Services

Rectangle {
  id: root

  property string label
  property color labelColor: ThemeService.colors.foreground
  property string sublabel
  property string value
  property color valueColor: ThemeService.colors.on_surface
  property Component leading: null
  property bool indented: false
  property bool interactive: false
  property bool selected: false
  property bool wideTrailing: false

  default property alias trailing: trailingRow.data

  readonly property int leadingSize: Math.round(ConfigService.font.size * 0.5)

  signal clicked()

  Layout.fillWidth: true

  implicitHeight: Math.max(content.implicitHeight + ConfigService.padding * 2, ConfigService.controlHeight)
  color: root.selected ? ThemeService.colors.surface : "transparent"

  activeFocusOnTab: root.interactive

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()

  MouseArea {
    anchors.fill: parent

    enabled: root.interactive
    hoverEnabled: root.interactive
    cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

    onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    onClicked: root.clicked()
  }

  RowLayout {
    id: content

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.gap
    anchors.rightMargin: ConfigService.gap

    spacing: 0

    Item {
      id: leadingSlot

      Layout.alignment: Qt.AlignVCenter

      visible: root.leading !== null || root.indented
      implicitWidth: root.leadingSize
      implicitHeight: root.leadingSize

      Loader {
        anchors.centerIn: parent

        active: root.leading !== null
        sourceComponent: root.leading
      }
    }

    ColumnLayout {
      id: labels

      Layout.fillWidth: true
      Layout.leftMargin: leadingSlot.visible ? ConfigService.gap : 0

      visible: !root.wideTrailing || root.label !== "" || root.sublabel !== ""

      spacing: 0

      MesaText {
        Layout.fillWidth: true

        visible: root.label !== ""
        text: root.label
        color: root.labelColor
        elide: Text.ElideRight
      }

      MesaText {
        Layout.fillWidth: true

        visible: root.sublabel !== ""
        text: root.sublabel
        color: ThemeService.colors.on_surface
        elide: Text.ElideRight
      }
    }

    MesaText {
      id: valueText

      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: labels.visible ? ConfigService.gap : 0

      visible: root.value !== ""
      text: root.value
      color: root.valueColor
    }

    RowLayout {
      id: trailingRow

      Layout.fillWidth: root.wideTrailing
      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: trailingRow.implicitWidth > 0 && (labels.visible || valueText.visible) ? ConfigService.gap : 0

      spacing: ConfigService.gapSmall
    }
  }

  MesaFocusRing {}
}
