import Quickshell
import QtQuick

QtObject {
  id: root

  property bool visible: true
  property string text: ""
  property string icon: ""
  property bool enabled: true
  property bool isSeparator: false
  property bool hasChildren: false
  property bool slider: false
  property real value: 0
  property bool checkable: false
  property bool radio: false
  property bool checked: false

  readonly property int buttonType: {
    if (!root.checkable) return QsMenuButtonType.None;

    return root.radio ? QsMenuButtonType.RadioButton : QsMenuButtonType.CheckBox;
  }
  readonly property int checkState: root.checked ? Qt.Checked : Qt.Unchecked

  signal triggered()
  signal adjusted(real value)
}
