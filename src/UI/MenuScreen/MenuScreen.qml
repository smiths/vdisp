import QtQuick 2.0
import org.julialang 1.0

Item {
    id: menuScreen

    Rectangle{
        id: backgroundRect
        color: "#483434"
        anchors.fill: parent
    }

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
    Item {
        property int buttonWidth: 305
        property int buttonHeight: 50
        property int buttonSpacing: 40
        id: menuButtons
        width: buttonWidth
        height: buttonHeight*3 + buttonSpacing*2
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: enterDataButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
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
                source: "../Assets/play.png"
            }

            Text {
                id: enterDataButtonLabel
                text: "Enter Data"
                font.pixelSize: 25
                color: "#FFF3E4"
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
        }

        Rectangle {
            id: settingsButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
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
                source: "../Assets/settings.png"
            }

            Text {
                id: settingsButtonLabel
                text: "Settings"
                font.pixelSize: 25
                color: "#FFF3E4"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: settingsButtonIcon.right
                    leftMargin: 20
                }
            }
        }

        Rectangle {
            id: exitButton
            width: menuButtons.buttonWidth
            height: menuButtons.buttonHeight
            radius: 5
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
                source: "../Assets/exit.png"
            }

            Text {
                id: exitButtonLabel
                text: "Exit Application"
                font.pixelSize: 25
                color: "#FFF3E4"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: exitButtonIcon.right
                    leftMargin: 20
                }
            }
        }
        
    }
}