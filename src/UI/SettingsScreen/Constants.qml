import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: constantsBackground
    
    width: vdispWindow.width * .8
    height: vdispWindow.height * .8
    
    anchors.centerIn: settingsStackView

    property bool valueUpdated: false

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
                text: (props.units === 0) ? "9810 N/m^3" : "0.03125 tcf"

                color: "#483434"
                font.pixelSize: 18
                
                enabled: false
                selectByMouse: true
                clip: true

                width: text ? text.width : gammawInputPlaceholder.width
                
                anchors.centerIn: parent
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
                }

                onTextChanged: {
                    if (acceptableInput) constantsBackground.valueUpdated = true
                    else constantsBackground.valueUpdated = false
                }

                // Placeholder Text
                property string placeholderText: ""
                Component.onCompleted: placeholderText = props.MIN_LAYER_SIZE[props.units].toFixed(4)
                Text {
                    id: minLayerSizeInputPlaceholder
                    property string unitString: props.units === 0 ? " m" : " ft"
                    text: minLayerSizeInput.placeholderText  + unitString
                    font.pixelSize: 18
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
        
        color: (constantsBackground.valueUpdated) ? "#fff3e4" : "#9d8f84"        

        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // UPDATE MIN LAYER SIZE
                var val = parseFloat(minLayerSizeInput.text)
                if(props.units === 0){
                    props.MIN_LAYER_SIZE = [val, props.MIN_LAYER_SIZE[1]]
                }else{
                    props.MIN_LAYER_SIZE = [props.MIN_LAYER_SIZE[0], val]
                }
                minLayerSizeInput.placeholderText = val.toFixed(4)
                // Reset valueUpdated
                constantsBackground.valueUpdated = false
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