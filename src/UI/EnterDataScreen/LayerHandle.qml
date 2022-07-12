import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Item {
    id: root
   
    // public
    property int index: 0
    property double maximum: 1
    property double value: 0
    property double minimum: 0
    property double stepSize: 1.0
   
    signal clicked(double value, int index);  
   
    // Make the handles slightly wider than background
    width: parent.width + 20
    height: parent.height
    anchors {
        top: parent.top
        bottom: parent.bottom 
        horizontalCenter: parent.horizontalCenter
    }
   
    Rectangle { // pill
        id: pill
       
        y: (value - minimum) / (maximum - minimum) * (root.height - pill.height) // pixels from value
        implicitWidth: parent.width
        implicitHeight: 15
        radius: 5
        color: "#483434"

        Text {
            property string unitString: (props.units === 0) ? " m" : " ft"
            anchors.centerIn: parent
            color: "#fff3e4"
            font.pixelSize: 13
            text: "Depth: " + (root.value*soilLayerFormBackground.totalDepth).toFixed(3) + unitString
        }
    }
   
    MouseArea {
        id: mouseArea

        anchors.fill: pill
   
        drag {
            target:   pill
            axis:     Drag.YAxis
            maximumY: root.height - pill.height
            minimumY: 0
        }
       
        onPositionChanged:  if(drag.active) setPixels(pill.y + 0.5 * pill.height) // drag pill
        onClicked: changeValuePopup.open()
    }
   
    // Change value popup
    Popup {
        id: changeValuePopup
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose // Only close when valid value has been entered

        width: 0.7*pill.width
        height: 40

        // Only absolute positioning was allowed
        y: pill.y - height - 10
        x: root.width/2 - width/2

        background: Rectangle {
            color: "#483434"
            radius: 10
        }

        contentItem: Item {
            id: changeValuePopupContainer

            width: changeValuePopupTextbox.width + gap + changeValuePopupEnter.width
            height: changeValuePopupTextbox.height
            
            x: changeValuePopup.width/2 - width/2
            y: changeValuePopup.height/2 - height/2

            property int gap: 10

            Item{
                anchors.centerIn: parent
                width: changeValuePopupTextbox.width + parent.gap + changeValuePopupEnter.width
                height: changeValuePopupTextbox.height
                
                // Input
                Rectangle {
                    id: changeValuePopupTextbox
                    color: "#fff3e4"
                    radius: 5

                    width: 120
                    height: 20

                    TextInput {
                        id: changeValuePopupInput
                        font.pixelSize: 18
                        color: "#483434"

                        width: text ? text.width : changeValuePopupPlaceholder.width
                        x: 5
                        
                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator{
                            bottom: soilLayerFormBackground.minLayerSize
                            top: props.totalDepth - soilLayerFormBackground.minLayerSize
                        }

                        Component.onCompleted: {
                            text = (root.value * props.totalDepth).toFixed(3)
                        }

                        property string placeholderText: "Enter Value..."
                        Text{
                            id: changeValuePopupPlaceholder
                            text: changeValuePopupInput.placeholderText
                            font.pixelSize: 18
                            color: "#483434"
                            visible: !changeValuePopupInput.text
                        }
                    }

                    // Units
                    Text{
                        text: (props.units === 0) ? " m" : " ft"
                        font.pixelSize: 18
                        color: "#483434"
                        anchors {
                            left: changeValuePopupInput.right
                            leftMargin: 1
                        }
                        visible: changeValuePopupInput.text
                    }
                }

                // Enter
                Rectangle {
                    id: changeValuePopupEnter
                    width: 50
                    height: 20
                    color: (changeValuePopupInput.text && changeValuePopupInput.acceptableInput) ? "#fff3e4" : "#9d8f84"
                    radius: 5
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: changeValuePopupTextbox.right
                        leftMargin: changeValuePopupContainer.gap
                    }
                    Text {
                        text: "Enter"
                        color: "#483434"
                        font.pixelSize: 15
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(changeValuePopupInput.text && changeValuePopupInput.acceptableInput){
                                var value = parseFloat(changeValuePopupInput.text) / props.totalDepth
                                updateValue(value)
                                changeValuePopup.close()
                            }
                        }
                    }
                }

                // TODO: Allow Submission By Clicking Enter
            }
        }
    }
    

    function setPixels(pixels) {
        // Calculate value
        var value = (maximum - minimum) / (root.height - pill.height) * (pixels - pill.height / 2) + minimum // value from pixels
        
        // Snap to grid
        // stepSize is in terms of value*totalDepth, but we are only adjusting value here
        var step = root.stepSize / soilLayerFormBackground.totalDepth
        var delta = (value*100)%(step*100)
        value = ((value*100)-delta)/100

        updateValue(value)
    }

    function updateValue(value){ 
        // Update handle value
        root.value = Math.min(Math.max(minimum, value))

        // Update property in soilLayerFormBackground
        if(props.inputFileSelected)
            soilLayerFormBackground.values[index-1] = Math.min(Math.max(minimum, value))
        else
            soilLayerFormBackground.values[index] = Math.min(Math.max(minimum, value))

        // Update Bounds
        soilLayerFormBackground.calculatedBounds = false
        soilLayerFormBackground.bounds = [soilLayerFormBackground.totalDepth]
        for(var i = 0; i < props.materials - 1; i++){
            soilLayerFormBackground.bounds.push(soilLayerFormBackground.values[i] * soilLayerFormBackground.totalDepth)
        }
        soilLayerFormBackground.bounds.push(0.0)
        props.bounds = [...soilLayerFormBackground.bounds]  // Update Julia list of bounds
        soilLayerFormBackground.calculatedBounds = true

        // Broadcast clicked signal (Get rid of this maybe, not really used?)
        clicked(Math.min(Math.max(minimum, value), maximum), index) 
    }
}
