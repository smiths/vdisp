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
    
    property variant filled: []

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: (parent) ? parent.horizontalCenter : undefined
        verticalCenter: (parent) ? parent.verticalCenter : undefined
    }

    // Title //////////////
    Text {
        id: consolidationSwellTitle
        text: "Enter Values"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
    Text {
        id: consolidationSwellSubtitle
        text: "Consolidation Swell"
        font.pixelSize: 15
        color: "#fff3e4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: consolidationSwellTitle.bottom 
            topMargin: 10
        }
    }
    ///////////////////////

    // Form ////////////////
    Item {
        id: consolidationSwellDataContainer

        // set width and height
        width: heaveSliderContainer.width
        height: heaveSliderContainer.height

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter 
        }

        // Heave Slider //////
        Item {
            id: heaveSliderContainer

            // BOUNDS
            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.3
            }

            property int sliderWidth: 0.8*(consolidationSwellDataBackground.width - heaveSliderLabel.width)
            property int labelGap: 5
            property int fontSize: 15 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            // set width and height
            width: heaveSliderLabel.width + sliderWidth + labelGap
            height: heaveSlider.height + heaveBeginText.height + heaveActiveText.height

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            // Label ////////
            Text {
                id: heaveSliderLabel
                text: "Heave: "
                color: "#fff3e4"
                font.pixelSize: parent.fontSize

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            /////////////////

            // Range Slider ///
            RangeSlider {
                id: heaveSlider
                clip: false

                // Values
                from: 0
                to: props.totalDepth
                first.value: props.totalDepth/4
                second.value: 3*props.totalDepth/4
                stepSize: 0.025
                snapMode: RangeSlider.SnapAlways  // TODO: toggle to RangeSlider.NoSnap with a snap to grid option?

                width: parent.sliderWidth
                height: 26

                first.onMoved: print(first.value)
                second.onMoved: print(second.value)

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: heaveSliderLabel.right
                    leftMargin: parent.labelGap
                }

                background: Rectangle {
                    x: heaveSlider.leftPadding
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: parent.width
                    implicitHeight: 4
                    width: heaveSlider.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: "#483434"

                    // Highlight inbetween range
                    Rectangle {
                        x: heaveSlider.first.visualPosition * parent.width
                        width: heaveSlider.second.visualPosition * parent.width - x
                        height: parent.height
                        color: "#EED6C4"
                        radius: 2
                    }

                    // Highlight active heave range
                    Rectangle {
                        x: heaveSlider.second.visualPosition * parent.width
                        width: parent.width - x
                        height: parent.height
                        color: "#fff3e4"
                        radius: 2
                    }
                }

                first.handle: Rectangle {
                    x: heaveSlider.leftPadding + heaveSlider.first.visualPosition * (heaveSlider.availableWidth - width)
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: "#fff3e4"

                    Text {
                        id: heaveBeginText
                        text: "Begin: " + heaveSlider.first.value.toFixed(3)
                        color: "#fff3e4"
                        font.pixelSize: heaveSliderContainer.fontSize
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.bottom
                            topMargin: heaveSliderContainer.labelGap
                        }
                    }
                }

                second.handle: Rectangle {
                    x: heaveSlider.leftPadding + heaveSlider.second.visualPosition * (heaveSlider.availableWidth - width)
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: "#fff3e4"

                    Text {
                        id: heaveActiveText
                        text: "Active: " + heaveSlider.second.value.toFixed(3)
                        color: "#fff3e4"
                        font.pixelSize: heaveSliderContainer.fontSize
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.top
                            bottomMargin: heaveSliderContainer.labelGap
                        }
                    }
                }
            }
            ///////////////////
        }
        //////////////////////

        // Items /////////////
        
        //////////////////////
    }
    ////////////////////////////////

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
                if(consolidationSwellDataBackground.formFilled)
                    enterDataStackView.push(consolidationSwellDataBackground.nextScreen)
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
