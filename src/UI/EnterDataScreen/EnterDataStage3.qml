import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: soilLayerFormBackground

    function isProperBounds(){
        bounds.sort(function(a, b){return a - b});
        print(bounds)
        for(var i = 1; i < bounds.length; i++){
            print((bounds[i] - bounds[i-1]))
            // Check if layer is larger than min allowed size
            if((bounds[i] - bounds[i-1]) < minLayerSize) return false
        }
        return true
    }

    function isFilled(){
        return (calculatedBounds) ? isProperBounds() : false
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    // If model = 0, next screen will be EnterDataStage4, model =1, EnterDataStage5, etc...
    property string nextScreen: "EnterDataStage" + (4 + props.model) + ".qml"

    property int titleMargin: 30
    property int continueMargin: 50
    property int depthLabelMargin: 10
    property int handleExtraWidth: 10

    property variant values: []
    property double totalDepth: 10.0
    property variant bounds: []
    property double minLayerSize: 0.1 * totalDepth
    property bool calculatedBounds: false

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: (parent) ? parent.horizontalCenter : undefined
        verticalCenter: (parent) ? parent.verticalCenter : undefined
    }

    Component.onCompleted: {
        bounds.push(totalDepth)
        for(var i = 0; i < props.materials - 1; i++){
            var val = 1 - ((i+1) / props.materials)
            values.push(val)
            bounds.push(val*totalDepth)
            var slider = Qt.createComponent("LayerHandle.qml");
            var obj = slider.createObject(mainSliderBackground, {index: i, value: val})
        }
        bounds.push(0.0)
        calculatedBounds = true
    }

    // Title //////////////
    Text {
        id: soilLayerTitle
        text: "Select Layers"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
    ///////////////////////

    // Main Slider Background
    Rectangle {
        id: mainSliderBackground
        width: 0.4 * parent.width
        color: "#fff3e4"
        border.color: "#483434"
        border.width: 6
        radius: 20
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: soilLayerTitle.bottom
            topMargin: soilLayerFormBackground.titleMargin
            bottom: continueButton.top
            bottomMargin: soilLayerFormBackground.continueMargin
        }
    }
    /////////////////////////

    // Total Depth of Soil Profile
    Text{
        text: "Total Depth: "
        id: depthLabel
        color: "#fff3e4"
        font.pixelSize: 18
        anchors {
            right: parent.horizontalCenter
            rightMargin: 3
            top: mainSliderBackground.bottom
            topMargin: parent.depthLabelMargin
        }
    }
    Rectangle {
        id: depthTextbox
        width: 120
        height: 20
        color: "#fff3e4"
        radius: 5
        anchors {
            left: parent.horizontalCenter
            leftMargin: 3
            verticalCenter: depthLabel.verticalCenter
        }
        TextInput {
            id: depthInput
            width: parent.width - 10
            font.pixelSize: 18
            color: "#483434"
            anchors.centerIn: parent
            
            selectByMouse: true
            clip: true
            validator: DoubleValidator{
                // must be positive
                bottom: 0
            }
            // Change for input handling
            onTextChanged: {
                if(acceptableInput) {
                    var depth = parseFloat(text)
                    // Update Total Depth Value
                    soilLayerFormBackground.totalDepth = depth
                    // Update Bounds
                    soilLayerFormBackground.bounds = [depth]
                    for(var i = 0; i < props.materials - 1; i++){
                        soilLayerFormBackground.bounds.push(soilLayerFormBackground.values[i] * depth)
                    }
                    soilLayerFormBackground.bounds.push(0.0)
                }
            }
            // Placeholder Text
            property string placeholderText: "Enter Depth..."
            Text {
                text: depthInput.placeholderText
                font.pixelSize: 18
                color: "#483434"
                visible: !depthInput.text
            }
        }
    }
    //////////////////////////////

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