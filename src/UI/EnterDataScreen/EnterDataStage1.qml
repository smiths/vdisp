import QtQuick 2.0
import QtQuick.Controls 2.12

Item {
    
    Rectangle {
        id: enterDataFormBackground

        width: 0.85 * parent.width
        height: 0.9 * parent.height
        radius: 20
        color: "#6B4F4F"

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        
        property int formTopMargin: 40
        property int formMiddleMargin: 30

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
                    // onTextChanged: acceptableInput ? print("Input acceptable") : print("Input not acceptable")

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
                    // onTextChanged: acceptableInput ? print("Input acceptable") : print("Input not acceptable")

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
            ////////////////

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
                    // onTextChanged: acceptableInput ? print("Input acceptable") : print("Input not acceptable")

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
            //////////////////

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
        }
    }

}