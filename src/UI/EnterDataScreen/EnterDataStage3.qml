import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: soilLayerFormBackground

    function isProperBounds(){
        bounds.sort(function(a, b){return a - b});
        for(var i = 1; i < bounds.length; i++){
            // Check if layer is larger than min allowed size
            if((bounds[i] - bounds[i-1]) < minLayerSize) {
                return false
            }
        }
        return true
    }

    function isFilled(){
        return (calculatedBounds) ? isProperBounds() && depthInput.text && depthInput.acceptableInput : false
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property bool highlightErrors: false
    // If model = 0, next screen will be EnterDataStage4, model =1, EnterDataStage5, etc...
    property string nextScreen: "EnterDataStage" + (4 + props.model) + ".qml"

    property int titleMargin: 30
    property int continueMargin: 50
    property int depthLabelMargin: 10
    property int handleExtraWidth: 10

    property variant values: []
    property double totalDepth: 10.0
    property variant bounds: []
    property double minLayerSize: (props.units === 0) ? 0.0254 : 1/12  // Minimum layer sizes: 2.54cm/1inch
    property int maxSublayers: 50
    property bool calculatedBounds: false

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: (parent) ? parent.horizontalCenter : undefined
        verticalCenter: (parent) ? parent.verticalCenter : undefined
    }

    Component.onCompleted: {
        // If we had input file, and materials are still the same
        if(props.inputFileSelected && !props.materialCountChanged){
            totalDepth = props.totalDepth
            // Initialize bounds
            for(var i = 0; i < props.bounds.length; i++){
                bounds.push(props.bounds[i])
                if(i === 0 || i === props.bounds.length-1) continue
                
                // Calculate handle val
                var val = props.bounds[i]/props.totalDepth
                values.push(val)
                // Create handle component
                var slider = Qt.createComponent("LayerHandle.qml");
                var obj = slider.createObject(mainSliderBackground, {index: i, value: val, stepSize: 0.025})
            }
            calculatedBounds = true
        }else{ // Else, if a material was added or deleted, or there was no input file
            // Initialize subdivisions, soilLayerNums as empty
            var subs = []
            var soilNums = []

            totalDepth = props.totalDepth

            // Initialize bounds
            bounds.push(totalDepth)  // Add top bound
            for(var i = 0; i < props.materials - 1; i++){
                // Spread handles evenly to begin with
                var val = 1 - ((i+1) / props.materials)
                values.push(val)
                bounds.push(val*totalDepth)

                // Create handle component
                var slider = Qt.createComponent("LayerHandle.qml");
                var obj = slider.createObject(mainSliderBackground, {index: i, value: val, stepSize: 0.025})

                // Initialize subdivisions with value 2 everywhere
                subs = [...subs, 2]

                // Initialize soil layer numbers to index
                soilNums = [...soilNums, i+1]
            }
            bounds.push(0.0) // Add bottom bound
            props.bounds = [...bounds] // Update julia list of bounds
            calculatedBounds = true
            
            // There is one more subdivision than # of handles, add outside loop
            subs = [...subs, 2]
            props.subdivisions = [...subs]

            // There is one more soil layer than # of handles, add outside loop
            soilNums = [...soilNums, Math.floor(props.materials)] // For some reason without floor() it was a float value???
            props.soilLayerNumbers = [...soilNums]
        }
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

    // Depth to Ground Water Table //
    Slider {
        id: dgwtSlider
        from: 0
        to: soilLayerFormBackground.totalDepth
        stepSize: getStepSize()
        width: 30 + (55-30) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        height: mainSliderBackground.height - mainSliderBackground.radius
        orientation: Qt.Vertical

        property int textSize: 9 + (14-9) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        
        function getStepSize() {
            if(!soilLayerFormBackground.calculatedBounds) 
                return 0.25

            // Get index of layer handle is currently in
            var currentLayerIndex = 0
            var val = soilLayerFormBackground.totalDepth - value
            while(soilLayerFormBackground.bounds[currentLayerIndex+1] < val)
                currentLayerIndex+=1

            // Get current layers height
            var currentLayerHeight = soilLayerFormBackground.bounds[currentLayerIndex+1] - soilLayerFormBackground.bounds[currentLayerIndex]
            // Get dx
            var dx = currentLayerHeight / props.subdivisions[currentLayerIndex]


            return Math.max(0.001, dx)
        }

        Component.onCompleted: {
            if(props.inputFileSelected) value = props.totalDepth - props.depthToGroundWaterTable
            else value = soilLayerFormBackground.totalDepth/2
        }

        anchors {
            top: mainSliderBackground.top
            topMargin: mainSliderBackground.radius
            right: mainSliderBackground.left
        }

        onValueChanged: props.depthToGroundWaterTable = (props.totalDepth - value)

        // Invisible background
        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        handle: Item {
            id: dgwtSliderHandle
            width: parent.width
            height: width

            Rectangle {
                id: dgwtSliderHandleRect
                color: "#70A9FF"
                width: parent.width
                height: 5
                anchors.horizontalCenter: parent.horizontalCenter
                y: dgwtSlider.visualPosition * (dgwtSlider.availableHeight - height)
            }

            Rectangle{
                id: dgwtSliderHandleCircle
                width: parent.width
                height: width
                color: "#70A9FF"
                radius: 0.5*width
                anchors {
                    horizontalCenter: dgwtSliderHandleRect.left
                    verticalCenter: dgwtSliderHandleRect.verticalCenter
                }

                // DGWT Symbol ///
                Image {
                    source: "../Assets/GroundWaterTable.png"
                    anchors.centerIn: parent
                    width: 14 + 15 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
                    height: 19 + 15 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
                }
                //////////////////

                // Label
                Text {
                    id: dgwtSliderLabel
                    property string unitString: (props.units === 0) ? " m" : " ft"
                    text: "Depth to Ground\nWater Table: " + (soilLayerFormBackground.totalDepth - dgwtSlider.value).toFixed(2) + unitString
                    color: "#fff3e4"
                    font.pixelSize: dgwtSlider.textSize
                    anchors {
                        right: dgwtSliderHandleCircle.left
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                }  
            }              
        }
    }
    /////////////////////////////////

    // Foundation Depth //
    Slider {
        id: foundationDepthSlider
        from: 0
        to: soilLayerFormBackground.totalDepth
        stepSize: getStepSize()
        width: 30 + (55-30) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        height: mainSliderBackground.height - mainSliderBackground.radius
        orientation: Qt.Vertical

        property int textSize: 9 + (14-9) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

        function getStepSize() {
            if(!soilLayerFormBackground.calculatedBounds) 
                return 0.25

            // Get index of layer handle is currently in
            var currentLayerIndex = 0
            var val = soilLayerFormBackground.totalDepth - value
            while(soilLayerFormBackground.bounds[currentLayerIndex+1] < val)
                currentLayerIndex+=1

            // Get current layers height
            var currentLayerHeight = soilLayerFormBackground.bounds[currentLayerIndex+1] - soilLayerFormBackground.bounds[currentLayerIndex]
            // Get dx
            var dx = currentLayerHeight / props.subdivisions[currentLayerIndex]


            return Math.max(0.001, dx)
        }

        Component.onCompleted: {
            if(props.inputFileSelected) value = props.totalDepth - props.foundationDepth  // Don't forget that the slider value is "upside down"
            else value = 3*soilLayerFormBackground.totalDepth/4
        }

        anchors {
            top: mainSliderBackground.top
            topMargin: mainSliderBackground.radius
            left: mainSliderBackground.right
        }

        onValueChanged: props.foundationDepth = (props.totalDepth - value)

        // Invisible background
        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        handle: Item {
            id: foundationDepthSliderHandle
            width: parent.width
            height: width

            Rectangle {
                id: foundationDepthSliderHandleRect
                color: "#fff3e4"
                width: parent.width
                height: 5
                anchors.horizontalCenter: parent.horizontalCenter
                y: foundationDepthSlider.visualPosition * (foundationDepthSlider.availableHeight - height)
            }

            Rectangle{
                id: foundationDepthSliderHandleCircle
                width: parent.width
                height: width
                color: "#fff3e4"
                radius: 0.5*width
                anchors {
                    horizontalCenter: foundationDepthSliderHandleRect.right
                    verticalCenter: foundationDepthSliderHandleRect.verticalCenter
                }

                // Foundation Symbol ///
                Rectangle {
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                    border.color: "#483434"
                    border.width: 2
                    color: "transparent"
                }
                //////////////////

                // Label
                Text {
                    id: foundationDepthSliderLabel
                    property string unitString: (props.units === 0) ? " m" : " ft"
                    text: "Depth to Foundation: " + (soilLayerFormBackground.totalDepth - foundationDepthSlider.value).toFixed(2) + unitString
                    color: "#fff3e4"
                    font.pixelSize: foundationDepthSlider.textSize
                    anchors {
                        left: foundationDepthSliderHandleCircle.right
                        leftMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                }  
            }              
        }
    }
    /////////////////////////////////

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
                id: layerInfoItem

                property int inputHeight: 20
                property int inputGap: 10

                property double layerHeight: (soilLayerFormBackground.calculatedBounds) ? (soilLayerFormBackground.bounds[index+1]-soilLayerFormBackground.bounds[index]) / soilLayerFormBackground.totalDepth * mainSliderBackground.height  : 0
                property double boxHeight: 2*inputHeight + inputGap
                property bool tooSmall: layerHeight <= boxHeight + inputGap

                visible: !tooSmall
                width: 0.9 * mainSliderBackground.width
                height: layerHeight
                x: mainSliderBackground.width/2 - width/2
                y: (soilLayerFormBackground.calculatedBounds) ? (soilLayerFormBackground.bounds[index]/soilLayerFormBackground.totalDepth)*mainSliderBackground.height: 0

                // Subdivision Selection
                Item {
                    width: parent.width
                    height: boxHeight
                    y: (soilLayerFormBackground.calculatedBounds) ? layerHeight/2 - boxHeight/2: 0

                    // Layer type selection
                    ComboBox {
                        id: materialDropdown
                        model: props.materialNames
                        currentIndex: (props.inputFileSelected && !props.materialCountChanged) ? props.soilLayerNumbers[index]-1 : index
                        anchors {
                            top: parent.top
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
                                // Update soil layer numbers
                                var soilNums = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index){
                                        soilNums = [...soilNums, currentIndex+1]
                                    }else{
                                        soilNums = [...soilNums, props.soilLayerNumbers[i]]
                                    }
                                }
                                props.soilLayerNumbers = [...soilNums]
                            }
                        }
                        // Text of dropdown list
                        delegate: ItemDelegate {
                            width: materialDropdown.width
                            contentItem: Text {
                                text: modelData
                                color: highlighted ? "#6B4F4F" : "#483434"
                                font: materialDropdown.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: materialDropdown.highlightedIndex === index
                            
                            Rectangle {
                                visible: highlighted
                                anchors.fill: parent
                                color : "#fff3e4"
                                border.width: 2
                                border.color: "#483434"
                                radius: 2
                            }
                            
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
                                context.fillStyle = "#483434";
                                context.fill();
                            }
                        }
                        // Text in main box
                        contentItem: Text {
                            text: materialDropdown.displayText
                            font: materialDropdown.font
                            color: "#483434"
                            verticalAlignment: Text.AlignVCenter
                            // elide: Text.ElideRight
                            anchors {
                                left: parent.left
                                leftMargin: 10
                            }
                        }
                        // Background of main box
                        background: Rectangle {
                            height: layerInfoItem.inputHeight
                            color: "#fff3e4"
                            border.color: "#483434"
                            border.width: 1
                            radius: 5
                        }
                        popup: Popup {
                            y: materialDropdown.height - 1
                            width: materialDropdown.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 0
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: materialDropdown.popup.visible ? materialDropdown.delegateModel : null
                                currentIndex: materialDropdown.highlightedIndex
                            }
                            background: Rectangle {
                                color: "#fff3e4"
                                radius: 2
                                border.width: 2
                                border.color: "#483434"
                            }
                        }
                    }
                    ////////////////////////

                    // Subdivisions ////////
                    Item {
                        id: subdivisionGroup
                        property int labelGap: 6
                        width: subdivisionSpinbox.width + labelGap + subdivsionLabel.width
                        height: subdivisionSpinbox.height

                        anchors {
                            top: materialDropdown.bottom
                            topMargin: layerInfoItem.inputGap
                            horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: subdivsionLabel
                            text: "Subdivisions:"
                            color: "#483434"
                            font.pixelSize: 15
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                            }
                        }

                        SpinBox {
                            id: subdivisionSpinbox
                            editable: true
                            from: 2
                            to: soilLayerFormBackground.maxSublayers

                            font.pixelSize: 14

                            height: layerInfoItem.inputHeight
                            width: 75

                            Component.onCompleted: {
                                if(props.inputFileSelected && !props.materialCountChanged) {
                                    value = props.subdivisions[index]
                                }else{
                                    value = 2
                                }
                            }

                            onValueModified: {
                                var vals = []
                                for (var i = 0; i < props.subdivisions.length; i++){
                                    if(i === index){
                                        vals = [...vals, subdivisionSpinbox.value]
                                    }else{
                                        vals = [...vals, props.subdivisions[i]]
                                    }
                                }
                                props.subdivisions = [...vals]
                            }

                            validator: IntValidator{
                                bottom: 2
                            }

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: subdivsionLabel.right
                                leftMargin: parent.labelGap
                            }

                            contentItem: TextInput {
                                z: 2
                                text: subdivisionSpinbox.textFromValue(subdivisionSpinbox.value, subdivisionSpinbox.locale)
                                
                                width: text.width
                                height: text.height

                                font.pixelSize: subdivisionSpinbox.font.pixelSize
                                color: "#fff3e4"
                                selectionColor: "#21be2b"
                                selectedTextColor: "#ffffff"
                                
                                readOnly: !subdivisionSpinbox.editable
                                validator: subdivisionSpinbox.validator
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }

                            up.indicator: Rectangle {
                                x: subdivisionSpinbox.mirrored ? 0 : parent.width - width
                                height: parent.height
                                radius: 5
                                implicitWidth: 20
                                implicitHeight: layerInfoItem.inputHeight
                                color: subdivisionSpinbox.up.pressed ? "#6e4f4f" : "#483434"

                                Text {
                                    text: "+"
                                    font.pixelSize: subdivisionSpinbox.font.pixelSize * 2
                                    color: "#fff3e4"
                                    anchors.fill: parent
                                    fontSizeMode: Text.Fit
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            down.indicator: Rectangle {
                                x: subdivisionSpinbox.mirrored ? parent.width - width : 0
                                height: parent.height
                                radius: 5
                                implicitWidth: 20
                                implicitHeight: layerInfoItem.inputHeight
                                color: subdivisionSpinbox.down.pressed ? "#6e4f4f" : "#483434"

                                Text {
                                    text: "-"
                                    font.pixelSize: subdivisionSpinbox.font.pixelSize * 2
                                    color: "#fff3e4"
                                    fontSizeMode: Text.Fit
                                    anchors.centerIn: parent
                                }
                            }

                            background: Rectangle {
                                id: subdivisionSpinboxBg
                                width: parent.width
                                height: parent.height
                                color: "#483434"
                                radius: 5
                            }
                        }
                    }
                    ///////////////////////
                }
                ///////////////////////

                // Subdivision Markers //
                Repeater {
                    id: subdivisionMarkers
                    model: subdivisionSpinbox.value-1
                    height: layerInfoItem.layerHeight
                    
                    delegate: Item {
                        property double divisionSize: layerInfoItem.layerHeight / subdivisionSpinbox.value
                               
                        height: divisionSize
                        width: mainSliderBackground.width*0.05
                        anchors.right: parent.right
                        y: index*divisionSize

                        Rectangle {
                            color: "#483434"
                            anchors.left: parent.right
                            height: 2
                            width: parent.width
                            anchors.bottom: parent.bottom
                        }
                    }
                }
                ///////////////////////
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
        // Error highlighting
        Rectangle {
            visible: (soilLayerFormBackground.highlightErrors && (!depthInput.acceptableInput || !depthInput.text))
            opacity: 0.8
            anchors.fill: parent
            color: "transparent"
            border.color: "red"
            border.width: 1
            radius: 5
        }
        TextInput {
            id: depthInput
            width: text ? text.width : depthInputPlaceholder.width
            font.pixelSize: 18
            color: "#483434"
            anchors{
                left: parent.left
                leftMargin: 5
            }
            
            selectByMouse: true
            clip: true
            validator: DoubleValidator{
                // must be greater than a minimum size
                bottom: props.materials * soilLayerFormBackground.minLayerSize
            }
            property bool valueLoadedFromFile: false
            Component.onCompleted: {
                valueLoadedFromFile = true
                text = props.totalDepth
            }
            // Change for input handling
            onTextChanged: {
                if(acceptableInput && !valueLoadedFromFile) {
                    soilLayerFormBackground.calculatedBounds = false
                    
                    var depth = parseFloat(text)
                    var oldDepth = soilLayerFormBackground.totalDepth
                    var oldSliderValueFoundation = foundationDepthSlider.value
                    var oldSliderValueDGWT = dgwtSlider.value


                    // Update Total Depth Value
                    soilLayerFormBackground.totalDepth = depth
                    
                    // Update Julia property
                    props.totalDepth = depth

                    // Update slider values (updates Julia values automatically)
                    foundationDepthSlider.value = ((oldSliderValueFoundation/oldDepth)*depth)
                    dgwtSlider.value = ((oldSliderValueDGWT/oldDepth)*depth)
                    
                    // Update heave begin and active depth
                    props.heaveBegin = depth/4
                    props.heaveActive = 3*depth/4

                    // Update Bounds
                    soilLayerFormBackground.bounds = [depth]
                    for(var i = 0; i < props.materials - 1; i++){
                        soilLayerFormBackground.bounds.push(soilLayerFormBackground.values[i] * depth)
                    }
                    soilLayerFormBackground.bounds.push(0.0)
                    props.bounds = [...soilLayerFormBackground.bounds] // Update Julia list of bounds
                    soilLayerFormBackground.calculatedBounds = true
                }else{
                    valueLoadedFromFile = false
                }
            }
            // Placeholder Text
            property string placeholderText: "Enter Depth..."
            Text {
                id: depthInputPlaceholder
                text: depthInput.placeholderText
                font.pixelSize: 18
                color: "#483434"
                visible: !depthInput.text
            }
        }
        // Units
        Text{
            text: (props.units === 0) ? " m" : " ft"
            font.pixelSize: 18
            color: "#483434"
            anchors {
                left: depthInput.right
                leftMargin: 1
            }
            visible: depthInput.text
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
                if(soilLayerFormBackground.formFilled){
                    enterDataStackView.push(soilLayerFormBackground.nextScreen)
                }else{
                    soilLayerFormBackground.highlightErrors = true
                    // If the only problem is layer handles
                    if(depthInput.text && depthInput.acceptableInput){
                        // Give user a popup alert about which layer(s) are the problem
                        var unitsString = (props.units === 0) ? "m" : "ft"
                        layerErrorPopup.message = "One or more layers have height less than <b>MIN_LAYER_SIZE</b>(" + soilLayerFormBackground.minLayerSize.toFixed(3) + unitsString + ")"
                        layerErrorPopup.open()
                    }
                }
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

    // Layer Error Popup
    Popup {
        id: layerErrorPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape // | Popup.CloseOnPressOutsideParent

        width: popupPadding + layerErrorPopupText.width 
        height: popupPadding + layerErrorPopupTitle.height + layerErrorPopupText.height + layerErrorPopupButton.height + 2*layerErrorPopup.gap

        anchors.centerIn: parent

        property string message: ""
        property int gap: 10
        property int popupPadding: 40

        background: Rectangle {
            color: "#483434"
            radius: 10
        }

        contentItem: Item {
            id: layerErrorPopupContainer
            
            width: layerErrorPopupText.width 
            height: layerErrorPopupTitle.height + layerErrorPopupText.height + layerErrorPopupButton.height + 2*layerErrorPopup.gap
            
            anchors.centerIn: parent
            
            // Title
            Text{
                id: layerErrorPopupTitle
                font.pixelSize: 25
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                text: "Error: Invalid Layer Height"
            }

            // Message
            Text{
                id: layerErrorPopupText
                font.pixelSize: 18
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: layerErrorPopupTitle.bottom
                    topMargin: layerErrorPopup.gap
                }
                text: layerErrorPopup.message
            }

            // Close Button
            Rectangle {
                id: layerErrorPopupButton
                width: 100
                height: 20
                radius: 5
                color: "#fff3e4"

                Text{
                    text: "Ok"
                    font.pixelSize: 15
                    color: "#483434"
                    anchors.centerIn: parent
                }

                anchors{
                    top: layerErrorPopupText.bottom
                    topMargin: layerErrorPopup.gap
                    horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: layerErrorPopup.close()
                }
            }
        }
    }
    /////////////////////
}