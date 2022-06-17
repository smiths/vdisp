import QtQuick 2.12
import QtQuick.Window 2.12
import org.julialang 1.0

Window {
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    maximumWidth: 1200
    maximumHeight: 900
    visible: true
    title: qsTr("VDisp")

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "./MenuScreen/MenuScreen.qml"
    }
}