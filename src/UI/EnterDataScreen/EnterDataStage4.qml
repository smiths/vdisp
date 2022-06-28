import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: consolidationSwellDataBackground

    function isFilled(){
        return false
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    // Next screen 
    property string nextScreen: "EnterDataStage" + (4 + props.model) + ".qml"

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: (parent) ? parent.horizontalCenter : undefined
        verticalCenter: (parent) ? parent.verticalCenter : undefined
    }

    // Title //////////////
    Text {
        id: soilLayerTitle
        text: "Enter Data"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
    ///////////////////////

    // Continue Button ///
    Rectangle {
        id: continueButton
        width: parent.width/6
        height: 25
        radius: 12
        color: (parent.formFilled) ? "#fff3e4" : "#9d8f84"
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(materialPropertiesFormBackground.formFilled)
                    enterDataStackView.push(materialPropertiesFormBackground.nextScreen)
            }
        }
        Text {
            id: continueButtonText
            text: "Continue"
            font.pixelSize: 13
            anchors {
                verticalCenter: continueButtonIcon.verticalCenter
                right: continueButtonIcon.left
                rightMargin: 5
            }
        }
        Image {
            id: continueButtonIcon
            source: "../Assets/continue.png"
            width: 19
            height: 19
            anchors {
                left: parent.horizontalCenter
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }
    }
    //////////////////////
}
