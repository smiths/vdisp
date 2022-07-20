import QtQuick 2.0
import org.julialang 1.0

Item {
    id: menuScreen

    Rectangle{
        id: backgroundRect
        color: "#483434"
        anchors.fill: parent
    }

    // Title //////////////
    Text {
        id: title
        text: "VDisp"
        color: "#EED6C4"
        font.pixelSize: 72
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 20
        }
    }
    Text {
        id: subtitle
        text: "Soil Settlment Analysis Software"
        color: "#EED6C4"
        font.pixelSize: 20
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: title.bottom
            topMargin: 10
        }
    }
    ////////////////////////

    Item {
        property int buttonWidth: 305 + 200 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int buttonHeight: 50 + 50 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        property int buttonSpacing: 40 + 30 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        id: menuButtons
        width: buttonWidth
        height: buttonHeight*3 + buttonSpacing*2
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        
        // Enter Data ////////
        Rectangle {
            id: enterDataButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
            focus: true

            Component.onCompleted: {
                forceActiveFocus()
            }
            
            color: "#6B4F4F"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            Image {
                id: enterDataButtonIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 40
                }
                width: 33
                height: 33
                property string fileExt: parent.activeFocus ? "-selected" : ""
                source: "../Assets/play" + fileExt + ".png"
            }

            Text {
                id: enterDataButtonLabel
                text: enterDataButton.activeFocus ? "<u>Enter Data<u>" : "Enter Data"
                font.pixelSize: 25
                color: enterDataButton.activeFocus ? "#FFF3E4" : "#EED6C4"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: enterDataButtonIcon.right
                    leftMargin: 20
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mainLoader.source = "../EnterDataScreen/EnterDataScreen.qml"
            }

            // Change focus
            KeyNavigation.up: exitButton
            KeyNavigation.down: settingsButton
            Keys.onReturnPressed: if(activeFocus) mainLoader.source = "../EnterDataScreen/EnterDataScreen.qml"
            Keys.onEnterPressed: if(activeFocus) mainLoader.source = "../EnterDataScreen/EnterDataScreen.qml"
        }
        /////////////////////

        // Settings ////////
        Rectangle {
            id: settingsButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
            focus: true
            color: "#6B4F4F"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: enterDataButton.bottom
                topMargin: menuButtons.buttonSpacing
            }

            Image {
                id: settingsButtonIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 40
                }
                width: 33
                height: 33
                property string fileExt: parent.activeFocus ? "-selected" : ""
                source: "../Assets/settings" + fileExt + ".png"
            }

            Text {
                id: settingsButtonLabel
                text: parent.activeFocus ? "<u>Settings<u>" : "Settings"
                font.pixelSize: 25
                color: parent.activeFocus ? "#FFF3E4" : "#EED6C4"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: settingsButtonIcon.right
                    leftMargin: 20
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mainLoader.source = "../SettingsScreen/SettingsScreen.qml"
            }

            // Change focus
            KeyNavigation.up: enterDataButton
            KeyNavigation.down: exitButton
            Keys.onReturnPressed: if(activeFocus) mainLoader.source = "../SettingsScreen/SettingsScreen.qml"
            Keys.onEnterPressed: if(activeFocus) mainLoader.source = "../SettingsScreen/SettingsScreen.qml"
        }
        ///////////////////

        // Exit ///////////
        Rectangle {
            id: exitButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
            focus: true

            color: "#6B4F4F"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: settingsButton.bottom
                topMargin: menuButtons.buttonSpacing
            }

            Image {
                id: exitButtonIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 40
                }
                width: 33
                height: 33
                property string fileExt: parent.activeFocus ? "-selected" : ""
                source: "../Assets/exit" + fileExt + ".png"
            }

            Text {
                id: exitButtonLabel
                text: parent.activeFocus ? "<u>Exit Application<u>" : "Exit Application"
                font.pixelSize: 25
                color: parent.activeFocus ? "#FFF3E4" : "#EED6C4"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: exitButtonIcon.right
                    leftMargin: 20
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }

            // Change focus
            KeyNavigation.up: settingsButton
            KeyNavigation.down: enterDataButton
            Keys.onReturnPressed: if(activeFocus) Qt.quit()
            Keys.onEnterPressed: if(activeFocus) Qt.quit()
        }
        ///////////////////
        
    }
}