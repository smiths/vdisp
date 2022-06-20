import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Item {
    id: enterDataScreen

    Rectangle{
        id: backgroundRect
        color: "#483434"
        anchors.fill: parent
    }

    // Back arrow
    Image {
        id: backArrow
        width: 25
        height: 32 + (50-32)*(vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        source: "../Assets/back.png"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left 
            right: enterDataStackView.left
            leftMargin: 5
            rightMargin: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(enterDataStackView.depth >= 2)
                    enterDataStackView.pop()
                else
                    mainLoader.source = "../MenuScreen/MenuScreen.qml"
            }
        }
    }

    // Next arrow
    Image {
        id: nextArrow
        width: 25
        height: 32 + (50-32)*(vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        source: "../Assets/next.png"
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right 
            left: enterDataStackView.right
            leftMargin: 5
            rightMargin: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // If current form is filled, go to next screen
                if(enterDataStackView.currentItem.formFilled)
                    enterDataStackView.push(enterDataStackView.currentItem.nextScreen)
            }
        }

        // Just testing formFilled
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            color: (enterDataStackView.currentItem.formFilled) ? "green" : "red"
        }
    }

    // Add "progress bar" at bottom of screen

    StackView {
        id: enterDataStackView
        width: 0.85 * parent.width
        height: 0.9 * parent.height
        anchors.centerIn: parent
        initialItem: "EnterDataStage1.qml"
    }
}