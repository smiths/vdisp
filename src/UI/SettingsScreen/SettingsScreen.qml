import QtQuick 2.0
import QtQuick.Controls 2.12

Rectangle {
    id: settingsScreen
    color: "#483434"
    
    width: mainLoader.width 
    height: mainLoader.height

    // Back Button
    Image {
        id: backButton
        anchors {
            left: parent.left
            top: parent.top
            topMargin: 10
            leftMargin: 10
        }
        width: 40
        height: 40
        source: "../Assets/back.png"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(settingsStackView.depth >= 2)
                    settingsStackView.pop()
                else
                    mainLoader.source = "../MenuScreen/MenuScreen.qml"
            }
        }
    }

    StackView {
        id: settingsStackView
        anchors.fill: settingsScreen
        initialItem: "SettingsMainMenu.qml"
    }
}