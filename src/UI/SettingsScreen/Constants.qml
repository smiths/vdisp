import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: constantsBackground
    
    width: vdispWindow.width * .8
    height: vdispWindow.height * .8
    
    anchors.centerIn: settingsStackView

    property bool minLayerValueUpdated: false
    property bool gammawValueUpdated: false

    color: "#6B4F4F"
    radius: 5
    
    // Title ///////////////////////
    Text {
        id: constantsTitle
        
        text: "Constants"
        color: "#fff3e4"
        font.pixelSize: 32 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 10
        }
    }
    ///////////////////////////////

    // Form of Constants //////////
    Item {
        id: constantsForm

        width: gammawLabel.width + labelGap + itemWidth
        height: itemHeight*2 + itemGap

        anchors.centerIn: parent

        property int itemWidth: 150
        property int itemHeight: 24
        property int labelGap: 10
        property int itemGap: 20

        // GAMMA W //////////////
        Text {
            id: gammawLabel

            textFormat: Text.RichText
            text: "Unit Weight of Water, γ<sub>w</sub>: "

            color: "#fff3e4"
            font.pixelSize: 16

            anchors.verticalCenter: gammawTextbox.verticalCenter
        }
        Rectangle {
            id: gammawTextbox
            width: constantsForm.itemWidth
            height: constantsForm.itemHeight
            color: "#fff3e4"
            radius: 5

            anchors {
                left: gammawLabel.right
                leftMargin: constantsForm.labelGap
            }

            TextInput {
                id: gammawInput

                color: "#483434"
                font.pixelSize: 18
                
                selectByMouse: true
                clip: true

                width: text ? text.width : gammawInputPlaceholder.width
                
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }

                validator: DoubleValidator{
                    bottom: 0.000001
                    // Should we have top limit ?
                }

                onTextChanged: {
                    if (acceptableInput) constantsBackground.gammawValueUpdated = true
                    else constantsBackground.gammawValueUpdated = false
                }

                // Placeholder Text
                property string placeholderText: ""
                Component.onCompleted: placeholderText = (props.units === 0) ? (props.GAMMA_W[0]*10000).toFixed(1) : props.GAMMA_W[props.units].toFixed(4)
                Text {
                    id: gammawInputPlaceholder
                    property string unitString: props.units === 0 ? " N/m^3" : " tcf"
                    text: gammawInput.placeholderText  + unitString
                    font.pixelSize: 18
                    color: "#483434"
                    opacity: 0.9
                    visible: !gammawInput.text
                }
            }
            // Units
            Text{
                text: (props.units === 0) ? " N/m^3" : " tcf"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: gammawInput.right
                    leftMargin: 1
                    verticalCenter: gammawInput.verticalCenter
                }
                visible: gammawInput.text
            }
        }
        //////////////////////////

        // MIN_LAYER_SIZE ////////
        Text {
            id: minLayerSizeLabel

            text: "Minimum Layer Size: "

            color: "#fff3e4"
            font.pixelSize: 16

            anchors.verticalCenter: minLayerSizeTextbox.verticalCenter
        }
        Rectangle {
            id: minLayerSizeTextbox
            width: constantsForm.itemWidth
            height: constantsForm.itemHeight
            color: "#fff3e4"
            radius: 5

            anchors {
                left: minLayerSizeLabel.right
                leftMargin: constantsForm.labelGap

                top: gammawTextbox.bottom
                topMargin: constantsForm.itemGap
            }

            TextInput {
                id: minLayerSizeInput

                color: "#483434"
                font.pixelSize: 18
                
                selectByMouse: true
                clip: true

                width: text ? text.width : minLayerSizeInputPlaceholder.width
                
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }

                validator: DoubleValidator{
                    bottom: 0.000001
                    top: (props.units === 0) ? 10 : 32.8084 // 1m = 3.28084ft
                }

                onTextChanged: {
                    if (acceptableInput) constantsBackground.minLayerValueUpdated = true
                    else constantsBackground.minLayerValueUpdated = false
                }

                // Placeholder Text
                property string placeholderText: ""
                Component.onCompleted: placeholderText = props.MIN_LAYER_SIZE[props.units].toFixed(4)
                Text {
                    id: minLayerSizeInputPlaceholder
                    property string unitString: props.units === 0 ? " m" : " ft"
                    text: minLayerSizeInput.placeholderText  + unitString
                    font.pixelSize: 18
                    opacity: 0.9
                    color: "#483434"
                    visible: !minLayerSizeInput.text
                }
            }

            // Units
            Text{
                text: (props.units === 0) ? " m" : " ft"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: minLayerSizeInput.right
                    leftMargin: 1
                    verticalCenter: minLayerSizeInput.verticalCenter
                }
                visible: minLayerSizeInput.text
            }
        }
        //////////////////////////
    }
    ///////////////////////////////

    // Update Button //////////////
    Rectangle {
        id: updateButton
        
        width: parent.width/6
        height: 25
        radius: 12
        
        color: (constantsBackground.gammawValueUpdated | constantsBackground.minLayerValueUpdated) ? "#fff3e4" : "#9d8f84"        

        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // UPDATE GAMMA W
                if(constantsBackground.gammawValueUpdated){
                    var CONVERSION = 0.0000031829401427921 // 1 N/m^3 = 0.0000031829401427921 tcf, see https://www.convertunits.com/from/N/m3/to/ton/cubic+foot+[short]
                    var gammaw = parseFloat(gammawInput.text)
                    if(props.units === 0){
                        props.GAMMA_W = [gammaw / 10000, gammaw * CONVERSION]
                    }else{
                        props.GAMMA_W = [(gammaw / CONVERSION)/10000, gammaw]
                    }
                    gammawInput.placeholderText = (props.units === 0) ? gammaw.toFixed(1) : gammaw.toFixed(4)
                    constantsBackground.gammawValueUpdated = false
                }
                // UPDATE MIN LAYER SIZE
                if(constantsBackground.minLayerValueUpdated){
                    var CONVERSION = 3.28084 // 1m = 3.28084ft
                    var val = parseFloat(minLayerSizeInput.text)
                    if(props.units === 0){
                        props.MIN_LAYER_SIZE = [val, val*CONVERSION]
                    }else{
                        props.MIN_LAYER_SIZE = [val/CONVERSION, val]
                    }
                    minLayerSizeInput.placeholderText = val.toFixed(4)
                    constantsBackground.minLayerValueUpdated = false
                }
            }
        }

        Text {
            id: updateButtonText
            text: "Update"
            color: "#483434"
            font.pixelSize: 13
            anchors.centerIn: parent
        }
    }
    //////////////////////////////
}