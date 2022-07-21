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
        
        property string folder: vdispWindow.getImageFolder(width, 32, 512)
        source: "../Assets/" + folder + "/next.png"

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left 
            leftMargin: 5
        }

        rotation: 180  // Back arrow just reuses the next arrow icon but flipped

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
        
        property string folder: vdispWindow.getImageFolder(width, 32, 512)
        source: "../Assets/" + folder + "/next.png"
        
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
                    if(enterDataStackView.depth > 3) {
                        if(enterDataStackView.currentItem.nextScreen){
                            mainLoader.source = enterDataStackView.currentItem.nextScreen
                            /*
                               Since we can't directly call a function from Julia (until the bug in CxxWrap.jl and QML.jl is fixed),
                            I'm forced to create an Observable() variable in Julia and pass it into props. When this variable updates
                            to true, I will execute the Julia subroutine from the Julia code. 
                               If user comes back from output screen and updates input, props.createOutputData will already be true, 
                            thus we have to change it to false, then back to true, just to force an update on the Julia side
                            */
                            props.createOutputData = false
                            props.createOutputData = true
                        }else{
                            Qt.quit()
                            props.finishedInput = true
                        }
                    }
                    // Else, go to next stage of data entry
                    enterDataStackView.push(enterDataStackView.currentItem.nextScreen)
                }else{
                    enterDataStackView.currentItem.highlightErrors = true
                }
            }
        }
    }

    // Progress Bar ///
    Item {
        id: progressBarContainer

        property int barGap: 20
        property int barWidth: 40
        property int barHeight: 5

        width: 4 * barWidth + 3 * barGap
        height: barHeight

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 10 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        }

        Repeater {
            id: progressBarRepeater
            model: 4

            anchors.fill: parent

            delegate: Rectangle {
                x: index*(progressBarContainer.barWidth + progressBarContainer.barGap)
                y: 0

                width: progressBarContainer.barWidth
                height: progressBarContainer.barHeight

                color: (index < enterDataStackView.depth) ? "#fff3e4" : "#9D8F84"
                radius: 3
            }
        }
    }
    //////////////////

    StackView {
        id: enterDataStackView
        width: 0.85 * parent.width
        height: 0.9 * parent.height
        anchors.centerIn: parent
        initialItem: "EnterDataStage1.qml"
    }
}