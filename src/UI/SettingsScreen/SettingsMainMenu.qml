import QtQuick 2.0

Item {
    ListModel {
        id: settingsMenuModel
        ListElement { menuText: "Unit System"; iconSource: "../Assets/512/settings-selected.png" }
        ListElement { menuText: "Constants"; iconSource: "../Assets/pencil.png" }
        ListElement { menuText: "Help"; iconSource: "../Assets/64/input-file-selected.png" }
        ListElement { menuText: "About"; iconSource: "../Assets/128/add-selected.png" }
    }

     Rectangle {
        id: stackViewBackground
        width: parent.width * .8
        height: parent.height * .8
        anchors.centerIn: parent
        color: "#6B4F4F"
        radius: 5
    }

    ListView {
        id: settingsListView
        anchors.fill: stackViewBackground
        model: settingsMenuModel
        interactive: false   // Prevents "flicking"
        delegate: Rectangle {
            id: mainButton
            width: settingsListView.width
            height: settingsListView.height/4
            color: "#6B4F4F"
            border.color: "#FFF3E4"
            border.width: 3
            radius: 5
            
            Image {
                id: iconImage
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 30
                }
                source: iconSource
                width: 48; height: 48
            }

            Text {
                id: mainText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: iconImage.right
                    leftMargin: 40
                }
                color: "#FFF3E4"
                font.pixelSize: 40
                text: menuText
            }

            MouseArea{
                anchors.fill: parent
                onPressed: {
                    mainButton.color = "#FFF3E4"
                    mainText.color = "#6B4F4F"
                }
                onReleased: {
                    mainButton.color = "#6B4F4F"
                    mainText.color = "#FFF3E4"
                }
                onClicked: {
                    if(menuText === "Unit System"){
                        settingsStackView.push("Options.qml")
                    }else if(menuText === "Help"){
                        settingsStackView.push("Help.qml")
                    }
                }
            }
        }
    }
}