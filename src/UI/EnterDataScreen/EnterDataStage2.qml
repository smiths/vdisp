import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: materialPropertiesFormBackground

    function isFilled(){
        // Replace when page is ready
        return false
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property string nextScreen: "EnterDataStage3.qml"

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }

    // Title
    Text {
        id: enterDataTitle
        text: "Enter Material Properties"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
}