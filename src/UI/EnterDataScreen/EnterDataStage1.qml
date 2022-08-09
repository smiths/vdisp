import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: enterDataFormBackground
    
    function isFilled(){
        return problemNameInput.text && widthInput.text && widthInput.acceptableInput && lengthInput.text && lengthInput.acceptableInput && appliedPressureInput.text && appliedPressureInput.acceptableInput
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property string nextScreen: "EnterDataStage2.qml"
    property bool highlightErrors: false

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
    }
    
    property int formTopMargin: 40 + (120-40) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int formMiddleMargin: 30 + (60-30) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int diagramMargin: 30 + (45-30) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int checkboxMargin: 20 + (35-20) * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    
    property double lengthValue: -1.0
    property double widthValue: -1.0
    property double min_ratio: 0.2
    property double max_ratio: 5.0
    
    property int checkboxSize: 18
    property int checkboxLabelGap: 6
    property int checkboxGap: 20
    
    // Signal for changing values based on input file
    JuliaSignals {
        // There was a limit for number of arguments a signal can accept (and the required data far surpassed this limit), so they are all passed into a single array
        signal inputFileAccepted(variant values)
        onInputFileAccepted: {
            // "Destructure" the array into variables with meaningful names
            var problemName = values[0]
            var model = values[1]
            var foundation = values[2]
            var appliedPressure = values[3]
            var appliedAt = values[4]
            var foundationWidth = values[5]
            var foundationLength = values[6]
            var outputIncrements = values[7]
            var saturatedAboveWaterTable = values[8]
            var materialNames = values[9]
            var specificGravity = values[10]
            var voidRatio = values[11]
            var waterContent = values[12]
            var materials = values[13]
            var totalDepth = values[14]
            var depthToGroundWaterTable = values[15]
            var foundationDepth = values[16]
            var bounds = values[17]
            var subdivisions = values[18]
            var soilLayerNumbers = values[19]
            var heaveBeginDepth = values[20]
            var heaveActiveDepth = values[21]
            var swellPressure = values[22]
            var swellIndex = values[23]
            var compressionIndex = values[24]
            var maxPastPressure = values[25]
            var timeAfterConstruction = values[26]
            var conePenetration = values[27]
            var elasticModulus = values[28]
            var units = values[29]
            
            // First switch to given unit system
            props.units = units

            // Update fields on this screen from input (the Julia variables get updated automatically in the onValueChanged signal of each Component)
            problemNameInput.text = problemName
            modelDropdown.currentIndex = model
            modelDropdown.loadedFromFile = false // So we keep track of when model loads from file into ComboBox
            foundationDropdown.currentIndex = foundation
            appliedPressureInput.text = appliedPressure
            appliedDropdown.currentIndex = appliedAt
            widthInput.text = foundationWidth
            lengthInput.text = foundationLength
            outputIncrementsCheckbox.checked = outputIncrements
            props.outputIncrements = outputIncrements
            saturationCheckbox.checked = saturatedAboveWaterTable
            props.saturatedAboveWaterTable = saturatedAboveWaterTable
            inputFromFileDelete.width = inputFromFileContainer.height/2
            var path = props.inputFile.split("/")
            var fileName = path[path.length - 1]
            inputFromFileText.text = fileName
            // Update julia variables so other screens are ready
            
            props.modelChanged = false
            props.materialCountChanged = false

            // Enter Data Stage 2 variables
            props.materials = materials
            var matNames = []
            for(var i = 0; i < materialNames.length; i++){
                matNames = [...matNames, materialNames[i]]
            }
            props.materialNames = [...matNames]
            var sg = []
            for(var i = 0; i < specificGravity.length; i++){
                sg = [...sg, specificGravity[i]]
            }
            props.specificGravity = [...sg]
            var vr = []
            for(var i = 0; i < voidRatio.length; i++){
                vr = [...vr, voidRatio[i]]
            }
            props.voidRatio = [...vr]
            var wc = []
            for(var i = 0; i < waterContent.length; i++){
                wc = [...wc, waterContent[i]]
            }
            props.waterContent = [...wc]

            // Enter Data Stage 3 variables
            props.totalDepth = totalDepth
            props.foundationDepth = foundationDepth
            props.depthToGroundWaterTable = depthToGroundWaterTable
            var b = []
            for(var i = 0; i < bounds.length; i++){
                b = [...b, bounds[i]]
            }
            props.bounds = [...b]
            var subs = []
            for(var i = 0; i < subdivisions.length; i++){
                subs = [...subs, subdivisions[i]]
            }
            props.subdivisions = [...subs]
            var soilLayNum = []
            for(var i = 0; i < soilLayerNumbers.length; i++){
                soilLayNum = [...soilLayNum, soilLayerNumbers[i]]
            }
            props.soilLayerNumbers = [...soilLayNum]

            // Enter Data Stage 4 (Consolidation/Swell)
            props.heaveBegin = heaveBeginDepth
            props.heaveActive = heaveActiveDepth
            var sp = []
            for(var i = 0; i < swellPressure.length; i++){
                sp = [...sp, swellPressure[i]]
            }
            props.swellPressure = [...sp]
            var si = []
            for(var i = 0; i < swellIndex.length; i++){
                si = [...si, swellIndex[i]]
            }
            props.swellIndex = [...si]
            var ci = []
            for(var i = 0; i < compressionIndex.length; i++){
                ci = [...ci, compressionIndex[i]]
            }
            props.compressionIndex = [...ci]
            var mpp = []
            for(var i = 0; i < maxPastPressure.length; i++){
                mpp = [...mpp, maxPastPressure[i]]
            }
            props.recompressionIndex = [...mpp]

            // Enter Data Stage 5 (Schmertmann)
            props.timeAfterConstruction = timeAfterConstruction
            var cp = []
            for(var i = 0; i < conePenetration.length; i++){
                cp = [...cp, conePenetration[i]]
            }
            props.conePenetration = [...cp]

            // Enter Data Stage 6 (Schmertmann Elastic)
            var em = []
            for(var i = 0; i < elasticModulus.length; i++){
                em = [...em, elasticModulus[i]]
            }
            props.elasticModulus = [...em]
        }

        signal inputFileRejected(variant message)
        onInputFileRejected: {
            props.inputFileSelected = false
            inputFromFileText.text = "Input From File"
            inputFromFileDelete.width = 0
            
            inputFileRejectedDialog.message = message
            inputFileRejectedDialog.open()
        }
    }

    Component.onCompleted: {
        if(props.inputFileSelected){
            problemNameInput.text = props.problemName
            modelDropdown.currentIndex = props.model
            foundationDropdown.currentIndex = props.foundation
            appliedPressureInput.text = props.appliedPressure
            appliedDropdown.currentIndex = (props.center) ? 0 : 1
            widthInput.text = props.foundationWidth
            lengthInput.text = props.foundationLength
            outputIncrementsCheckbox.checked = props.outputIncrements
            saturationCheckbox.checked = props.saturatedAboveWaterTable
            var path = props.inputFile.split("/")
            var fileName = path[path.length - 1]
            inputFromFileContainer.fileName = fileName
        }
    }

    // Add "Input From File"
    Item {
        id: inputFromFileContainer
        property string fileName: ""

        property int gap: 4   
        property int offset: 10    
        width: inputFromFileImage.width + inputFromFileText.width + gap
        height: 20 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

        anchors{
            left: parent.left
            leftMargin: offset
            top: parent.top
            topMargin: offset
        }

        Image {
            id: inputFromFileImage

            property string folder: vdispWindow.getImageFolder(width, 16, 64)
            source: "../Assets/" + folder + "/fileUpload.png"

            width: parent.height
            height: width

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }

        Text {
            id: inputFromFileText
            text: (props.inputFileSelected) ? inputFromFileContainer.fileName : "Input From File"
            font.pixelSize: 12 + 7 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
            color: parent.activeFocus ? "#fff3e4" : "#EED6C4"

            anchors {
                left: inputFromFileImage.right
                leftMargin: inputFromFileContainer.gap
                verticalCenter: parent.verticalCenter
            }
        }

        MouseArea{
            anchors.fill: parent
            onClicked: fileDialog.open()
        }
    }
    Image{
        id: inputFromFileDelete
        visible: props.inputFileSelected
        
        property string folder: vdispWindow.getImageFolder(width, 16, 256)
        source: "../Assets/" + folder + "/exit.png"
        
        anchors {
            left: inputFromFileContainer.right
            leftMargin: inputFromFileContainer.gap*1.5
            right: inputFromFileContainer.right
            rightMargin: -(inputFromFileContainer.gap*1.5 + inputFromFileDelete.height)
            top: inputFromFileContainer.top
            topMargin: inputFromFileContainer.height/4
            bottom: inputFromFileContainer.bottom
            bottomMargin: inputFromFileContainer.height/4
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                props.inputFileSelected = false
                inputFromFileText.text = "Input From File"
                inputFromFileDelete.width = 0
                // Update form to empty
            }
        }
    }
    FileDialog {
        id: fileDialog
        title: "Please select input file"
        selectMultiple: false
        folder: (props.lastInputFileDir.length > 0) ? props.lastInputFileDir : shortcuts.home
        nameFilters: ["VDisp data files (*.dat)" ]
        onAccepted: {
            props.inputFile = fileUrl.toString()

            // Once a new input file is selected, we need Julia to parse it
            // and emit signal to QML to update fields. This only happens when 
            // value of inputFileSelected is changed. If it was already selected 
            // before and user selects a new one, the value of inputFileSelected
            // would remain true without the next line, and Julia would never run
            // the required code. Thus, we force a change in the next line
            props.inputFileSelected = false   
            props.inputFileSelected = true

            props.lastInputFileDir = folder.toString()

            // Convert URL to string
            var name = fileUrl.toString()
            // Split URL String at each "/" and extract last piece of data
            var path = name.split("/")
            var fileName = path[path.length - 1]
            // Update fileName property
            inputFromFileContainer.fileName = fileName
        }
    }
    Popup {
        id: inputFileRejectedDialog
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape // | Popup.CloseOnPressOutsideParent

        width: popupPadding + inputFileRejectedDialogText.width 
        height: popupPadding + inputFileRejectedDialogTitle.height + inputFileRejectedDialogText.height + inputFileRejectedDialogButton.height + 2*inputFileRejectedDialog.gap

        anchors.centerIn: parent

        property string message: ""
        property int gap: 10
        property int popupPadding: 40

        background: Rectangle {
            color: "#483434"
            radius: 10
        }

        contentItem: Item {
            id: inputFileRejectedDialogContainer
            
            width: inputFileRejectedDialogText.width 
            height: inputFileRejectedDialogTitle.height + inputFileRejectedDialogText.height + inputFileRejectedDialogButton.height + 2*inputFileRejectedDialog.gap
            
            anchors.centerIn: parent
            
            // Title
            Text{
                id: inputFileRejectedDialogTitle
                font.pixelSize: 25
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                text: "Error: Bad Input File"
            }

            // Message
            Text{
                id: inputFileRejectedDialogText
                font.pixelSize: 18
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: inputFileRejectedDialogTitle.bottom
                    topMargin: inputFileRejectedDialog.gap
                }
                text: inputFileRejectedDialog.message
            }

            // Close Button
            Rectangle {
                id: inputFileRejectedDialogButton
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
                    top: inputFileRejectedDialogText.bottom
                    topMargin: inputFileRejectedDialog.gap
                    horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: inputFileRejectedDialog.close()
                }
            }
        }
    }
    
    ////////////////////////
    
    // Title
    Text {
        id: enterDataTitle
        text: "Enter Data"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
    // Form Top
    Item {
        id: formTop
        implicitWidth: parent.width
        implicitHeight: itemHeight*3 + itemGap*2
        anchors {
            // horizontalCenter: parent.horizontalCenter
            top: enterDataTitle.baseline
            topMargin: enterDataFormBackground.formTopMargin
        }
        
        property int itemWidth: 230
        property int itemHeight: 25
        property int itemGap: 20
        property int labelGap: 10
        
        // PROBLEM NAME
        Rectangle {
            id: problemNameTextbox
            width: formTop.itemWidth
            height: formTop.itemHeight
            radius: 5
            color: "#FFF3E4"
            anchors {
                left: formTop.horizontalCenter
                leftMargin: formTop.labelGap / 2
            }

            // Error highlighting
            Rectangle {
                visible: (enterDataFormBackground.highlightErrors && (!problemNameInput.acceptableInput || !problemNameInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
            }

            TextInput {
                id: problemNameInput
                width: parent.width - 10
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }

                focus: true

                Component.onCompleted: {
                    forceActiveFocus()
                }

                KeyNavigation.tab: appliedPressureInput
                KeyNavigation.down: appliedPressureInput
                
                selectByMouse: true
                clip: true
                onTextChanged: props.problemName = text
                
                // Placeholder Text
                property string placeholderText: "Enter Problem Name Here..."
                Text {
                    text: problemNameInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !problemNameInput.text
                }
            }
        }
        Text{
            id: problemNameLabel
            text: "Problem Name: "
            color: "#FFF3E4"
            font.pixelSize: 18
            anchors {
                verticalCenter: problemNameTextbox.verticalCenter
                right: formTop.horizontalCenter
                rightMargin: formTop.labelGap/2
            }
        }
        ///////////

        // MODEL ////////////
        ComboBox {
            id: modelDropdown
            model: ["Consolidation/Swell", "Schmertmann", "Schmertmann Elastic"]
            anchors {
                top: problemNameTextbox.bottom
                topMargin: formTop.itemGap
                left: formTop.horizontalCenter
                leftMargin: formTop.labelGap/2
            }
            width: formTop.itemWidth
            font.pixelSize: 18
            
            property bool loaded: false
            property bool loadedFromFile: false
            onCurrentIndexChanged: {
                if(!loaded){
                    // The ComboBox loading also emits current index change signal
                    loaded = true
                }else{
                    props.model = currentIndex
                    if(props.inputFileSelected && loadedFromFile) {
                        props.modelChanged = true
                    }else{
                        loadedFromFile = true // Prevents updating "modelChanged" first time we load the model from input
                    }
                }
            }
            // Text of dropdown list
            delegate: ItemDelegate {
                width: modelDropdown.width
                contentItem: Text {
                    text: modelData
                    color: highlighted ? "#6B4F4F" : "#483434"
                    font: modelDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: modelDropdown.highlightedIndex === index
                
                Rectangle {
                    visible: highlighted
                    anchors.fill: parent
                    color: "#fff3e4"
                    radius: 2
                }
                
                required property int index
                required property var modelData
            }
            indicator: Canvas {
                id: modelCanvas
                x: modelDropdown.width - width - 10
                y: modelDropdown.height / 2 - 3
                width: 12
                height: 8
                contextType: "2d"
                Connections {
                    target: modelDropdown
                    function onPressedChanged() { modelCanvas.requestPaint(); }
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
                text: modelDropdown.displayText
                font: modelDropdown.font
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
                height: formTop.itemHeight
                color: "#fff3e4"
                radius: 5
            }
            popup: Popup {
                y: modelDropdown.height - 1
                width: modelDropdown.width
                implicitHeight: contentItem.implicitHeight
                padding: 0
                contentItem: ListView {
                    id: modelDropdownItem
                    clip: true
                    implicitHeight: contentHeight
                    model: modelDropdown.popup.visible ? modelDropdown.delegateModel : null
                    currentIndex: modelDropdown.highlightedIndex
                }
                background: Rectangle {
                    color: "#fff3e4"
                    radius: 2
                }
            }
        }
        Text{
            id: modelLabel
            text: "Model: "
            color: "#FFF3E4"
            font.pixelSize: 18
            anchors {
                verticalCenter: modelDropdown.verticalCenter
                right: formTop.horizontalCenter
                rightMargin: formTop.labelGap/2
            }
        }
        /////////////////////////

        // FOUNDATION TYPE //////
        ComboBox {
            id: foundationDropdown
            model: ["Rectangular Slab", "Long Strip Footing"]
            anchors {
                top: modelDropdown.bottom
                topMargin: formTop.itemGap
                left: formTop.horizontalCenter
                leftMargin: formTop.labelGap/2
            }
            width: formTop.itemWidth
            font.pixelSize: 18
            property bool loaded: false
            onCurrentIndexChanged: {
                if(!loaded){
                    // The ComboBox loading also emits current index change signal
                    loaded = true
                }else{
                    props.foundation = currentIndex
                }
            }
            // Text of dropdown list
            delegate: ItemDelegate {
                width: foundationDropdown.width
                contentItem: Item {
                    Text { 
                        text: modelData
                        color: highlighted ? "#6B4F4F" : "#483434"
                        font: foundationDropdown.font
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                highlighted: foundationDropdown.highlightedIndex === index
                
                Rectangle {
                    visible: highlighted
                    anchors.fill: parent
                    // no background highlighting, just keep background same as before
                    color: "#fff3e4"
                    radius: 2 // to match curved bg
                }
                
                required property int index
                required property var modelData
            }
            indicator: Canvas {
                id: foundationCanvas
                x: foundationDropdown.width - width - 10
                y: foundationDropdown.height / 2 - 3
                width: 12
                height: 8
                contextType: "2d"
                Connections {
                    target: foundationDropdown
                    function onPressedChanged() { foundationCanvas.requestPaint(); }
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
                text: foundationDropdown.displayText
                font: foundationDropdown.font
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
                height: formTop.itemHeight
                color: "#fff3e4"
                radius: 5
            }
            popup: Popup {
                y: foundationDropdown.height - 1
                width: foundationDropdown.width
                implicitHeight: contentItem.implicitHeight
                padding: 0
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: foundationDropdown.popup.visible ? foundationDropdown.delegateModel : null
                    currentIndex: foundationDropdown.highlightedIndex
                }
                background: Rectangle {
                    color: "#fff3e4"
                    radius: 3
                }
            }
        }
        Text{
            id: foundationLabel
            text: "Foundation Option: "
            color: "#FFF3E4"
            font.pixelSize: 18
            anchors {
                verticalCenter: foundationDropdown.verticalCenter
                right: formTop.horizontalCenter
                rightMargin: formTop.labelGap/2
            }
        }
        ///////////////
    }
    // Form Middle
    Item {
        id: formMiddle
        implicitWidth: parent.width
        implicitHeight: 2*itemHeight + itemGap + enterDataFormBackground.diagramMargin + diagramRect.height
        anchors {
            top: formTop.bottom
            topMargin: enterDataFormBackground.formMiddleMargin
        }
        
        property int itemWidth: 150
        property int itemHeight: 25
        property int itemGap: 20
        property int labelGap: 10
        
        // Width /////////////
        Rectangle {
            id: widthTextbox
            width: formMiddle.itemWidth
            height: formMiddle.itemHeight
            color: "#fff3e4"
            radius: 5
            anchors {
                left: widthLabel.right
                leftMargin: formMiddle.labelGap
            }

            // Error highlighting
            Rectangle {
                visible: (enterDataFormBackground.highlightErrors && (!widthInput.acceptableInput || !widthInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
            }

            TextInput {
                id: widthInput
                font.pixelSize: 18
                width: text ? text.width : widthPlaceholderText.width
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }

                KeyNavigation.up: problemNameInput
                KeyNavigation.left: appliedPressureInput
                KeyNavigation.tab: lengthInput
                KeyNavigation.down: lengthInput
                
                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    // must be positive
                    bottom: 0
                }
                // Change for input handling
                onTextChanged: {
                    // Update property (so diagram can update)
                    enterDataFormBackground.widthValue = parseFloat(text)
                    // Update Julia value
                    props.foundationWidth = parseFloat(text)
                }
                // Placeholder Text
                property string placeholderText: "Enter Width..."
                Text {
                    id: widthPlaceholderText
                    text: widthInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !widthInput.text
                }
            }
            // Units
            Text{
                text: (props.units === 0) ? " m" : " ft"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: widthInput.right
                    leftMargin: 1
                }
                visible: widthInput.text
            }
        }
        // Label
        Text {
            id: widthLabel
            text: "Width: "
            font.pixelSize: 18
            color: "#fff3e4"
            anchors {
                right: lengthLabel.right
            }
        }
        //////////////////

        // APPLIED PRESSURE /////
        Rectangle {
            id: appliedPressureTextbox
            width: formMiddle.itemWidth
            height: formMiddle.itemHeight
            color: "#fff3e4"
            radius: 5
            anchors {
                right: formMiddle.horizontalCenter
                rightMargin: formMiddle.itemGap / 2
            }

            // Error highlighting
            Rectangle {
                visible: (enterDataFormBackground.highlightErrors && (!appliedPressureInput.acceptableInput || !appliedPressureInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
            }

            TextInput {
                id: appliedPressureInput
                width: text ? text.width : appliedPressurePlaceholder.width
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }

                KeyNavigation.up: problemNameInput
                KeyNavigation.left: problemNameInput
                KeyNavigation.tab: widthInput
                KeyNavigation.down: widthInput
                KeyNavigation.right: widthInput
                
                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    // must be positive
                    bottom: 0
                }
                // Change for input handling
                onTextChanged: props.appliedPressure = parseFloat(text)
                // Placeholder Text
                property string placeholderText: "Enter Pressure..."
                Text {
                    id: appliedPressurePlaceholder
                    text: appliedPressureInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !appliedPressureInput.text
                }
            }
            // Units
            Text{
                text: (props.units === 0) ? " Pa" : " tsf"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: appliedPressureInput.right
                    leftMargin: 1
                }
                visible: appliedPressureInput.text
            }
        }
        Text {
            id: appliedPressureLabel
            text: "Applied Pressure: "
            font.pixelSize: 18
            color: "#fff3e4"
            anchors {
                right: appliedPressureTextbox.left
                rightMargin: formMiddle.labelGap
            }
        }
        ///////////////////////

        // Length /////////////
        Rectangle {
            id: lengthTextbox
            width: formMiddle.itemWidth
            height: formMiddle.itemHeight
            color: "#fff3e4"
            radius: 5

            // Error highlighting
            Rectangle {
                visible: (enterDataFormBackground.highlightErrors && (!lengthInput.acceptableInput || !lengthInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
            }

            anchors {
                left: lengthLabel.right
                leftMargin: formMiddle.labelGap
                top: widthTextbox.bottom
                topMargin: formMiddle.itemGap
            }
            TextInput {
                id: lengthInput
                width: text ? text.width : lengthInputPlaceholder.width
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }
                
                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    // must be positive
                    bottom: 0
                }
                // Change for input handling
                onTextChanged: {
                    // Update property (so diagram can update)
                    enterDataFormBackground.lengthValue = parseFloat(text)
                    // Update Julia value
                    props.foundationLength = parseFloat(text)
                }
                // Placeholder Text
                property string placeholderText: "Enter Length..."
                Text {
                    id: lengthInputPlaceholder
                    text: lengthInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !lengthInput.text
                }
            }

            KeyNavigation.tab: continueButton
            KeyNavigation.down: continueButton
            KeyNavigation.right: continueButton
            KeyNavigation.up: widthInput
            KeyNavigation.left: widthInput

            // Units
            Text{
                text: (props.units === 0) ? " m" : " ft"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: lengthInput.right
                    leftMargin: 1
                }
                visible: lengthInput.text
            }
        }
        Text {
            id: lengthLabel
            text: "Length: "
            font.pixelSize: 18
            color: "#fff3e4"
            anchors {
                left: formMiddle.horizontalCenter
                leftMargin: formMiddle.itemGap / 2
                verticalCenter: lengthTextbox.verticalCenter
            }
        }
        //////////////////////

        // APPLIED AT ////////
        ComboBox {
            id: appliedDropdown
            model: ["Center", "Corner", "Edge"]
            anchors {
                top: appliedPressureTextbox.bottom
                topMargin: formMiddle.itemGap
                right: formMiddle.horizontalCenter
                rightMargin: formMiddle.itemGap/2
            }
            width: formMiddle.itemWidth
            font.pixelSize: 18
            property bool loaded: false
            onCurrentIndexChanged: {
                if(!loaded){
                    // The ComboBox loading also emits current index change signal
                    loaded = true
                }else{
                    // Only index 0 means center
                    props.center = (currentIndex === 0) ? true : false
                }
            }
            // Text of dropdown list
            delegate: ItemDelegate {
                width: appliedDropdown.width
                contentItem: Text {
                    text: modelData
                    color: highlighted ? "#6B4F4F" : "#483434"
                    font: appliedDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: appliedDropdown.highlightedIndex === index
                
                Rectangle {
                    visible: highlighted
                    anchors.fill: parent
                    color: "#fff3e4"
                    radius: 2
                }
                
                required property int index
                required property var modelData
            }
            indicator: Canvas {
                id: appliedCanvas
                x: appliedDropdown.width - width - 10
                y: appliedDropdown.height / 2 - 3
                width: 12
                height: 8
                contextType: "2d"
                Connections {
                    target: appliedDropdown
                    function onPressedChanged() { appliedCanvas.requestPaint(); }
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
                text: appliedDropdown.displayText
                font: appliedDropdown.font
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
                height: formMiddle.itemHeight
                color: "#fff3e4"
                radius: 5
            }
            popup: Popup {
                y: appliedDropdown.height - 1
                width: appliedDropdown.width
                implicitHeight: contentItem.implicitHeight
                padding: 0
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: appliedDropdown.popup.visible ? appliedDropdown.delegateModel : null
                    currentIndex: appliedDropdown.highlightedIndex
                }
                background: Rectangle {
                    color: "#fff3e4"
                    radius: 2
                }
            }
        }
        Text{
            id: appliedLabel
            text: "Applied At: "
            color: "#FFF3E4"
            font.pixelSize: 18
            anchors {
                verticalCenter: appliedDropdown.verticalCenter
                right: appliedDropdown.left
                rightMargin: 10
            }
        }
        /////////////////////

        // Diagram //////////
        Rectangle {
            id: diagramRect
            
            color: "transparent"
            border.color: "#fff3e4"
            border.width: 2
            
            property int max_length: 100 + 250 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
            property int max_width: max_length
            property int min_width: 40
            property int min_length: 30
            width: (enterDataFormBackground.widthValue < 0 || enterDataFormBackground.lengthValue < 0) ? max_width : Math.max(Math.min((enterDataFormBackground.widthValue/enterDataFormBackground.lengthValue)*max_width, max_width), min_width);
            height: (enterDataFormBackground.lengthValue < 0 || enterDataFormBackground.widthValue < 0) ? max_length : Math.max(Math.min((enterDataFormBackground.lengthValue/enterDataFormBackground.widthValue)*max_length, max_length), min_length);
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: appliedDropdown.bottom
                topMargin: enterDataFormBackground.diagramMargin
            }
            //////////////

            // Force Point
            Rectangle {
                id: diagramArrow
                width: 10
                height: width
                radius: width / 2

                color: "#483434"
                border.color: "#fff3e4"

                anchors {
                    horizontalCenter: (appliedDropdown.currentIndex === 0) ? diagramRect.horizontalCenter : diagramRect.left
                    verticalCenter: (appliedDropdown.currentIndex === 1) ? diagramRect.bottom : diagramRect.verticalCenter
                }
            }
        }
        /////////////////////
    }
    /////////////////////

    // Output Increments
    Rectangle {
        id: outputIncrementsCheckbox
        property bool checked: false
        width: parent.checkboxSize
        height: parent.checkboxSize
        radius: 5
        color: "#fff3e4"
        anchors {
            bottom: continueButton.top
            bottomMargin: enterDataFormBackground.checkboxMargin
            right: parent.horizontalCenter
            rightMargin: parent.checkboxGap / 2
        }
        Rectangle {
            visible: parent.checked
            color: "#483434"
            radius: 3
            anchors.fill: parent
            anchors.margins: 3
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Toggle checkbox
                parent.checked = !parent.checked
                // Update Julia value
                props.outputIncrements = parent.checked
            }
        }
    }
    Text {
        id: outputIncrementsLabel
        text: "Output Increments: "
        color: "#fff3e4"
        font.pixelSize: 18
        anchors {
            right: outputIncrementsCheckbox.left
            rightMargin: parent.checkboxLabelGap
            verticalCenter: outputIncrementsCheckbox.verticalCenter
        }
    }
    /////////////////////

    // Saturated Above Water Table
    Rectangle {
        id: saturationCheckbox
        property bool checked: false
        width: parent.checkboxSize
        height: parent.checkboxSize
        radius: 5
        color: "#fff3e4"
        anchors {
            bottom: continueButton.top
            bottomMargin: enterDataFormBackground.checkboxMargin
            left: saturationLabel.right
            leftMargin: parent.checkboxLabelGap
        }
        Rectangle {
            visible: parent.checked
            color: "#483434"
            radius: 3
            anchors.fill: parent
            anchors.margins: 3
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Toggle checkbox
                parent.checked = !parent.checked
                // Update Julia value
                props.saturatedAboveWaterTable = parent.checked
            }
        }
    }
    Text {
        id: saturationLabel
        text: "Saturated Above Water Table: "
        color: "#fff3e4"
        font.pixelSize: 18
        anchors {
            left: parent.horizontalCenter
            leftMargin: parent.checkboxGap / 2
            verticalCenter: saturationCheckbox.verticalCenter
        }
    }
    //////////////////////

    // Continue Button ///
    Rectangle {
        id: continueButton
        width: parent.width/6
        height: 25
        radius: 12
        focus: true
        color: (parent.formFilled) ? "#fff3e4" : "#9d8f84"
        border.color: (activeFocus) ? "#483434" : "transparent"

        KeyNavigation.up: lengthInput
        KeyNavigation.tab: problemNameInput

        Keys.onReturnPressed: {
            // Same as onClicked
            if(enterDataFormBackground.formFilled)
                    enterDataStackView.push(enterDataFormBackground.nextScreen)
            else
                enterDataFormBackground.highlightErrors = true
        }
        Keys.onEnterPressed: {
            // Same as onClicked
            if(enterDataFormBackground.formFilled)
                    enterDataStackView.push(enterDataFormBackground.nextScreen)
            else
                enterDataFormBackground.highlightErrors = true
        }

        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(enterDataFormBackground.formFilled)
                    enterDataStackView.push(enterDataFormBackground.nextScreen)
                else
                    enterDataFormBackground.highlightErrors = true
            }
        }
        Text {
            id: continueButtonText
            text: "Continue"
            color: "#483434"
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