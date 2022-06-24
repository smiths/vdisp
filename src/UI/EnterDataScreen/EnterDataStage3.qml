import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: soilLayerFormBackground

    function isProperBounds(){
        bounds.sort(function(a, b){return a - b});
        for(var i = 1; i < bounds.length; i++){
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
            var obj = slider.createObject(mainSliderBackground, {index: i, value: val, stepSize: 0.025})
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

        Repeater {
            id: labelsRepeater
            model: props.materials

            width: parent.width
            height: parent.height

            delegate: Item {
                property double layerHeight: (soilLayerFormBackground.calculatedBounds) ? (soilLayerFormBackground.bounds[index+1]-soilLayerFormBackground.bounds[index]) / soilLayerFormBackground.totalDepth * mainSliderBackground.height  : 0
                property double boxHeight: 0.7*layerHeight
              
                width: 0.9 * mainSliderBackground.width
                height: boxHeight
                x: mainSliderBackground.width/2 - width/2
                y: (soilLayerFormBackground.calculatedBounds) ? (soilLayerFormBackground.bounds[index]/soilLayerFormBackground.totalDepth)*mainSliderBackground.height + layerHeight/2 - boxHeight/2: 0

                // Just for testing
                Rectangle{
                    anchors.fill: parent 
                    color: "red"
                    radius: 3
                    opacity: 0
                }

                // Layer type selection
                ComboBox {
                    id: materialDropdown
                    model: props.materialNames
                    anchors {
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: 0.6 * parent.width
                    font.pixelSize: 18
                    property bool loaded: false
                    onCurrentIndexChanged: {
                        if(!loaded){
                            // The ComboBox loading also emits current index change signal
                            loaded = true
                        }else{
                            // Update value
                            // props.center = (currentIndex === 0) ? true : false
                        }
                    }
                    // Text of dropdown list
                    delegate: ItemDelegate {
                        width: materialDropdown.width
                        contentItem: Text {
                            text: modelData
                            color: "#483434"
                            font: materialDropdown.font
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: materialDropdown.highlightedIndex === index
                        required property int index
                        required property var modelData
                    }
                    indicator: Canvas {
                        id: materialCanvas
                        x: materialDropdown.width - width - 10
                        y: materialDropdown.height / 2 - 3
                        width: 12
                        height: 8
                        contextType: "2d"
                        Connections {
                            target: materialDropdown
                            function onPressedChanged() { materialCanvas.requestPaint(); }
                        }
                        onPaint: {
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            // Color of arrow
                            context.fillStyle = materialDropdown.pressed ? "#e8e4e4" : "#483434";
                            context.fill();
                        }
                    }
                    // Text in main box
                    contentItem: Text {
                        text: materialDropdown.displayText
                        font: materialDropdown.font
                        color: materialDropdown.pressed ? "#989494" : "#483434"
                        verticalAlignment: Text.AlignVCenter
                        // elide: Text.ElideRight
                        anchors {
                            left: parent.left
                            leftMargin: 10
                        }
                    }
                    // Background of main box
                    background: Rectangle {
                        height: formMiddle.itemHeight
                        color: "#fff3e4"
                        border.color: "#483434"
                        border.width: 1
                        radius: 5
                    }
                    popup: Popup {
                        y: materialDropdown.height - 1
                        width: materialDropdown.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: materialDropdown.popup.visible ? materialDropdown.delegateModel : null
                            currentIndex: materialDropdown.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                        background: Rectangle {
                            color: "#fff3e4"
                            radius: 2
                        }
                    }
                }
                ////////////////////////
            }
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
                    soilLayerFormBackground.calculatedBounds = false
                    var depth = parseFloat(text)
                    // Update Total Depth Value
                    soilLayerFormBackground.totalDepth = depth
                    // Update Bounds
                    soilLayerFormBackground.bounds = [depth]
                    for(var i = 0; i < props.materials - 1; i++){
                        soilLayerFormBackground.bounds.push(soilLayerFormBackground.values[i] * depth)
                    }
                    soilLayerFormBackground.bounds.push(0.0)
                    soilLayerFormBackground.calculatedBounds = true
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