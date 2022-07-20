import QtQuick 2.12
import QtQuick.Window 2.12
import org.julialang 1.0

Window {
    id: vdispWindow
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    maximumWidth: 1920
    maximumHeight: 1080
    visible: true
    title: qsTr("VDisp")

    function isMinHeight(){
        return height === minimumHeight
    }
    function isMinWidth(){
        return width === minimumWidth
    }
    function isMinSize(){
        return isMinHeight() && isMinWidth()
    }

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "./MenuScreen/MenuScreen.qml"
    }
}