import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: enterDataFormBackground
    
    function isFilled(){
        return problemNameInput.text && widthInput.text && widthInput.acceptableInput && lengthInput.text && lengthInput.acceptableInput && appliedPressureInput.text && appliedPressureInput.acceptableInput
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property string nextScreen: "EnterDataStage2.qml"
    
    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
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
    
    // Add "Input From File"
    
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
            TextInput {
                id: problemNameInput
                width: parent.width - 10
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                }
                
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
            model: ["Consolidation Swell", "Schmertmann", "Schmertmann Elastic"]
            anchors {
                top: problemNameTextbox.bottom
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
                    props.model = currentIndex
                }
            }
            // Text of dropdown list
            delegate: ItemDelegate {
                width: modelDropdown.width
                contentItem: Text {
                    text: modelData
                    color: "#483434"
                    font: modelDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: modelDropdown.highlightedIndex === index
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
                    context.fillStyle = modelDropdown.pressed ? "#e8e4e4" : "#483434";
                    context.fill();
                }
            }
            // Text in main box
            contentItem: Text {
                text: modelDropdown.displayText
                font: modelDropdown.font
                color: modelDropdown.pressed ? "#989494" : "#483434"
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
                padding: 1
                contentItem: ListView {
                    id: modelDropdownItem
                    clip: true
                    implicitHeight: contentHeight
                    model: modelDropdown.popup.visible ? modelDropdown.delegateModel : null
                    currentIndex: modelDropdown.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
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
                contentItem: Text {
                    text: modelData
                    color: "#483434"
                    font: foundationDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: foundationDropdown.highlightedIndex === index
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
                    context.fillStyle = foundationDropdown.pressed ? "#e8e4e4" : "#483434";
                    context.fill();
                }
            }
            // Text in main box
            contentItem: Text {
                text: foundationDropdown.displayText
                font: foundationDropdown.font
                color: foundationDropdown.pressed ? "#989494" : "#483434"
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
                padding: 1
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: foundationDropdown.popup.visible ? foundationDropdown.delegateModel : null
                    currentIndex: foundationDropdown.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }
                background: Rectangle {
                    color: "#fff3e4"
                    radius: 2
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
            TextInput {
                id: widthInput
                width: parent.width - 10
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
                    enterDataFormBackground.widthValue = parseFloat(text)
                    // Update Julia value
                    props.foundationWidth = parseFloat(text)
                }
                // Placeholder Text
                property string placeholderText: "Enter Width..."
                Text {
                    text: widthInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !widthInput.text
                }
            }
        }
        Text {
            id: widthLabel
            text: "Width: "
            font.pixelSize: 18
            color: "#fff3e4"
            anchors {
                // left: formMiddle.horizontalCenter
                // leftMargin: formMiddle.itemGap / 2
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
            TextInput {
                id: appliedPressureInput
                width: parent.width - 10
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
                onTextChanged: props.appliedPressure = parseFloat(text)
                // Placeholder Text
                property string placeholderText: "Enter Pressure..."
                Text {
                    text: appliedPressureInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !appliedPressureInput.text
                }
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
            anchors {
                left: lengthLabel.right
                leftMargin: formMiddle.labelGap
                top: widthTextbox.bottom
                topMargin: formMiddle.itemGap
            }
            TextInput {
                id: lengthInput
                width: parent.width - 10
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
                    text: lengthInput.placeholderText
                    font.pixelSize: 18
                    color: "#483434"
                    visible: !lengthInput.text
                }
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
                    color: "#483434"
                    font: appliedDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: appliedDropdown.highlightedIndex === index
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
                    context.fillStyle = appliedDropdown.pressed ? "#e8e4e4" : "#483434";
                    context.fill();
                }
            }
            // Text in main box
            contentItem: Text {
                text: appliedDropdown.displayText
                font: appliedDropdown.font
                color: appliedDropdown.pressed ? "#989494" : "#483434"
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
                padding: 1
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: appliedDropdown.popup.visible ? appliedDropdown.delegateModel : null
                    currentIndex: appliedDropdown.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
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
        Shape {
            id: diagramRect
            property int max_width: (vdispWindow.height > 800) ? 200 : (vdispWindow.height > 700) ? 150 : 130
            property int max_length: (vdispWindow.height > 800) ? 170 : (vdispWindow.height > 700) ? 120 : 100
            width: (enterDataFormBackground.widthValue < 0 || enterDataFormBackground.lengthValue < 0) ? max_width : Math.min((enterDataFormBackground.widthValue/enterDataFormBackground.lengthValue)*max_width, max_width);
            height: (enterDataFormBackground.lengthValue < 0 || enterDataFormBackground.widthValue < 0) ? max_length : Math.min((enterDataFormBackground.lengthValue/enterDataFormBackground.widthValue)*max_length, max_length);
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: appliedDropdown.bottom
                topMargin: enterDataFormBackground.diagramMargin
            }
            ShapePath {
                strokeWidth: 2
                strokeColor: "#fff3e4"
                startX: 20
                startY: 0
                fillColor: "transparent"
                PathLine { x: diagramRect.width; y: 0 }
                PathLine { x: diagramRect.width-20; y: diagramRect.height }
                PathLine { x: 0; y: diagramRect.height }
                PathLine { x: 20; y: 0 }
            }
            //////////////

            // Force Point
            Shape {
                id: diagramArrow
                width: 10
                height: diagramRect.height / 3
                property int xOffset: (appliedDropdown.currentIndex === 2) ? -10 : 0
                anchors {
                    horizontalCenter: (appliedDropdown.currentIndex === 1) ? diagramRect.left : diagramRect.horizontalCenter
                    bottom: (appliedDropdown.currentIndex === 0) ? diagramRect.verticalCenter : diagramRect.bottom
                }
                ShapePath {
                    strokeWidth: 2
                    strokeColor: "#EED6C4"
                    startX: 5 + diagramArrow.xOffset
                    startY: 0
                    fillColor: "transparent"
                    PathLine { x: 5 + diagramArrow.xOffset; y: diagramArrow.height }
                }
                ShapePath {
                    strokeWidth: 2
                    strokeColor: "#EED6C4"
                    startX: 0 + diagramArrow.xOffset
                    startY: diagramArrow.height - 6
                    fillColor: "transparent"
                    PathLine { x: 5 + diagramArrow.xOffset; y: diagramArrow.height }
                }
                ShapePath {
                    strokeWidth: 2
                    strokeColor: "#EED6C4"
                    startX: diagramArrow.width + diagramArrow.xOffset
                    startY: diagramArrow.height - 6
                    fillColor: "transparent"
                    PathLine { x: 5 + diagramArrow.xOffset; y: diagramArrow.height }
                }
                Rectangle {
                    id: diagramForcePoint
                    width: 5
                    height: width
                    radius: width * 0.5
                    color: "red"
                    x: 5 + diagramArrow.xOffset - diagramForcePoint.width/2; y: diagramArrow.height - diagramForcePoint.height/2
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
            top: formMiddle.bottom
            topMargin: enterDataFormBackground.checkboxMargin
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
            top: formMiddle.bottom
            topMargin: enterDataFormBackground.checkboxMargin
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
        color: (parent.formFilled) ? "#fff3e4" : "#9d8f84"
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