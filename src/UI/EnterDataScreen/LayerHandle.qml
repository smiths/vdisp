import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
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
            property string unitString: (props.units === 0) ? "m" : "ft"
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
        onClicked: setPixels(mouse.y) // tap tray
    }
   
    function setPixels(pixels) {
        // Calculate value
        var value = (maximum - minimum) / (root.height - pill.height) * (pixels - pill.height / 2) + minimum // value from pixels
        
        // Snap to grid
        // stepSize is in terms of value*totalDepth, but we are only adjusting value here
        var step = root.stepSize / soilLayerFormBackground.totalDepth
        var delta = (value*100)%(step*100)
        value = ((value*100)-delta)/100

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

        // Broadcast clicked signal
        clicked(Math.min(Math.max(minimum, value), maximum), index) 
    }
}
