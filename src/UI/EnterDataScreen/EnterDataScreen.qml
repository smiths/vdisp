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
        width: height
        height: 32 + (50-32)*(vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        source: "../Assets/back.png"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left 
            leftMargin: 5
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
        width: height 
        height: 32 + (50-32)*(vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        source: "../Assets/next.png"
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right 
            rightMargin: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // If current form is filled, go to next screen
                if(enterDataStackView.currentItem.formFilled){
                    // If we are at 4th stage, move on to output
                    props.finishedInput = true
                    if(enterDataStackView.depth > 3) Qt.quit()
                    // Else, go to next stage of data entry
                    enterDataStackView.push(enterDataStackView.currentItem.nextScreen)
                }
            }
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