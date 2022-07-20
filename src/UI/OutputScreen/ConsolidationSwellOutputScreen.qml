import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: consolidationSwellOutputScreen
    color: "#483434"
    anchors.fill: parent

    property int titleMargin: 10 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int subtitleMargin: 3 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int tableMargin: 1 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int tableBottomValueFontSize: 12 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    
    // Title
    Text{
        id: outputScreenTitle
        text: (props.outputDataCreated) ? props.outputData[0] : "Loading"
        color: "#fff3e4"
        font.pixelSize: 25 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: parent.titleMargin
        }
    }
    Text{
        id: outputScreenSubTitle
        visible: props.outputDataCreated
        text: "Consolidation/Swell"
        color: "#fff3e4"
        font.pixelSize: 15 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: outputScreenTitle.bottom
            topMargin: parent.subtitleMargin
        }
    }


    // Heave Above Foundation ///////////////////
    Text {
        id: heaveAboveFoundationTableTitle
        text: "Heave Above Foundation"
        font.pixelSize: 20
        color: "#fff3e4"
        anchors {
            top: outputScreenSubTitle.bottom
            topMargin: consolidationSwellOutputScreen.tableMargin
            left: heaveAboveFoundationContainer.left
            leftMargin: 10
        }
    }
    Item {
        id: heaveAboveFoundationContainer

        width: 600 + 300 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        height: heaveAboveFoundationTableHeaderView.height + heaveAboveFoundationTableView.height

        clip: true

        anchors {
            top: heaveAboveFoundationTableTitle.bottom
            topMargin: 2
            horizontalCenter: parent.horizontalCenter
        }

        // Header Background
        Rectangle {
            color: "#5E4545"
            radius: 10
            anchors.fill: heaveAboveFoundationTableHeaderView

            Rectangle {
                color: "#5e4545"
                height: 10
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
        
        // Body Background
        Rectangle {
            color: "#6B4F4F"
            radius: 10
            anchors.fill: heaveAboveFoundationTableView

            Rectangle {
                color: "#6B4F4F"
                height: 10
                width: parent.width
                anchors.top: parent.top
            }
        }

        // Divider
        Rectangle{
            color: "#fff3e4"
            width: parent.width
            height: 1.5
            anchors.verticalCenter: heaveAboveFoundationTableHeaderView.bottom
        }

        // Border
        Rectangle {
            border.color: "#fff3e4"
            radius: 10
            color: "transparent"
            anchors.fill: parent
        }

        Repeater {
            id: heaveAboveFoundationTableHeaderView
            model: 4 

            property string distUnit: props.units === 0 ? "m" : "ft"
            property string pressureUnit: props.units === 0 ? "Pa" : "tsf"
            property variant headers: ["Element", "Depth ("+distUnit+")", "Delta Heave (" + distUnit + ")", "Excess Pore\nPressure ("+pressureUnit+")"]

            width: heaveAboveFoundationContainer.width
            height: heaveAboveFoundationTableView.cellHeight

            delegate: Item {
                //x: vdispWindow.width/2 - heaveAboveFoundationTableHeaderView.width/2 + index*width
                x: index*width
                //y: consolidationSwellOutputScreen.titleMargin + consolidationSwellOutputScreen.subtitleMargin + consolidationSwellOutputScreen.tableMargin + outputScreenTitle.height + outputScreenSubTitle.height
                width: heaveAboveFoundationTableHeaderView.width / 4
                height: heaveAboveFoundationTableHeaderView.height

                Text {
                    color: "#fff3e4"
                    font.pixelSize: 18
                    text: heaveAboveFoundationTableHeaderView.headers[index]
                    anchors.centerIn: parent
                }
            }
        }
        ListView {
            id: heaveAboveFoundationTableView
            model: props.outputData[4]  // heaveAboveFoundationRows

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded  // From docs: The scroll bar is only shown when the content is too large to fit.
                // Custom Bar
                contentItem: Rectangle {
                    implicitWidth: 6
                    opacity: 0.4
                    color: "#fff3e4"
                }
            }

            width: heaveAboveFoundationContainer.width
            height: Math.min(maxHeight, props.outputData[4]*cellHeight)

            property int cellHeight: 50
            property int maxHeight: 150 + 100 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            clip: true
            interactive: props.outputData[4]*cellHeight > maxHeight
            boundsMovement: Flickable.StopAtBounds

            anchors{
                top: heaveAboveFoundationTableHeaderView.bottom
                horizontalCenter: parent.horizontalCenter
            }

            delegate: Item {
                id: heaveAboveFoudationTableRow
                
                height: heaveAboveFoundationTableView.cellHeight
                property int id: index

                Repeater {
                    id: heaveAboveFoudationTableCellView
                    model: 4
                    property int id: parent.id

                    width: heaveAboveFoundationTableView.width
                    height: heaveAboveFoudationTableRow.height

                    delegate: Item {

                        x: index*width
                        width: heaveAboveFoudationTableCellView.width / 4
                        height: parent.height

                        Text {
                            id: heaveAboveFoudationTableCellEntry
                            color: "#fff3e4"
                            font.pixelSize: 18
                            
                            // Entry text is heaveAboveFoundationTable[row + column*heaveAboveFoundationTableRows]
                            // Round all values (except column 1, the layer number) to 3 decimals
                            text: (index > 0) ? props.outputData[3][heaveAboveFoudationTableCellView.id + index*props.outputData[4]].toFixed(3) : props.outputData[3][heaveAboveFoudationTableCellView.id + index*props.outputData[4]]

                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
    Text {
        text: "Total Heave Above Foundation: "
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors{
            verticalCenter: totalHeaveAboveFoundationValue.verticalCenter
            right: totalHeaveAboveFoundationValue.left
        }
    }
    Text {
        id: totalHeaveAboveFoundationValue
        text: (props.outputDataCreated) ? props.outputData[7].toFixed(3) : "N/A"
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors {
            top: heaveAboveFoundationContainer.bottom 
            topMargin: 5
            left: heaveAboveFoundationContainer.horizontalCenter
            leftMargin: (heaveAboveFoundationContainer.width/4)/2 - width/2
        }
    }
    Text {
        text: (props.units === 0) ? "m" : "ft"
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors {
            verticalCenter: totalHeaveAboveFoundationValue.verticalCenter
            left: totalHeaveAboveFoundationValue.right
            leftMargin: 1
        }
    }
    /////////////////////////////////////////////

    // Heave Below Foundation ///////////////////
    Text {
        id: heaveBelowFoundationTableTitle
        text: "Heave Below Foundation"
        font.pixelSize: 20
        color: "#fff3e4"
        anchors {
            top: totalHeaveAboveFoundationValue.bottom
            topMargin: consolidationSwellOutputScreen.tableMargin
            left: heaveBelowFoundationContainer.left
            leftMargin: 10
        }
    }
    Item {
        id: heaveBelowFoundationContainer

        width: 600 + 300 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        height: heaveBelowFoundationTableHeaderView.height + heaveBelowFoundationTableView.height

        clip: true

        anchors {
            top: heaveBelowFoundationTableTitle.bottom
            topMargin: 2
            horizontalCenter: parent.horizontalCenter
        }

        // Header Background
        Rectangle {
            color: "#5E4545"
            radius: 10
            anchors.fill: heaveBelowFoundationTableHeaderView

            Rectangle {
                color: "#5e4545"
                height: 10
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
        
        // Body Background
        Rectangle {
            color: "#6B4F4F"
            radius: 10
            anchors.fill: heaveBelowFoundationTableView

            Rectangle {
                color: "#6B4F4F"
                height: 10
                width: parent.width
                anchors.top: parent.top
            }
        }

        // Divider
        Rectangle{
            color: "#fff3e4"
            width: parent.width
            height: 1.5
            anchors.verticalCenter: heaveBelowFoundationTableHeaderView.bottom
        }

        // Border
        Rectangle {
            border.color: "#fff3e4"
            radius: 10
            color: "transparent"
            anchors.fill: parent
        }

        Repeater {
            id: heaveBelowFoundationTableHeaderView
            model: 4 

            property string distUnit: props.units === 0 ? "m" : "ft"
            property string pressureUnit: props.units === 0 ? "Pa" : "tsf"
            property variant headers: ["Element", "Depth ("+distUnit+")", "Delta Heave (" + distUnit + ")", "Excess Pore\nPressure ("+pressureUnit+")"]

            width: heaveBelowFoundationContainer.width
            height: heaveBelowFoundationTableView.cellHeight

            delegate: Item {
                //x: vdispWindow.width/2 - heaveBelowFoundationTableHeaderView.width/2 + index*width
                x: index*width
                //y: consolidationSwellOutputScreen.titleMargin + consolidationSwellOutputScreen.subtitleMargin + consolidationSwellOutputScreen.tableMargin + outputScreenTitle.height + outputScreenSubTitle.height
                width: heaveBelowFoundationTableHeaderView.width / 4
                height: heaveBelowFoundationTableHeaderView.height

                Text {
                    color: "#fff3e4"
                    font.pixelSize: 18
                    text: heaveBelowFoundationTableHeaderView.headers[index]
                    anchors.centerIn: parent
                }
            }
        }
        ListView {
            id: heaveBelowFoundationTableView
            model: props.outputData[6]  // heaveBelowFoundationRows
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded  // From docs: The scroll bar is only shown when the content is too large to fit.
                // Custom Bar
                contentItem: Rectangle {
                    implicitWidth: 6
                    opacity: 0.4
                    color: "#fff3e4"
                }
            }
            width: heaveBelowFoundationContainer.width
            height: Math.min(maxHeight, props.outputData[6]*cellHeight)

            property int cellHeight: 50
            property int maxHeight: 150 + 100 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            clip: true
            interactive: props.outputData[6]*cellHeight > maxHeight
            boundsMovement: Flickable.StopAtBounds

            anchors{
                top: heaveBelowFoundationTableHeaderView.bottom
                horizontalCenter: parent.horizontalCenter
            }

            delegate: Item {
                id: heaveBelowFoundationTableRow
                
                height: heaveBelowFoundationTableView.cellHeight
                property int id: index

                Repeater {
                    id: heaveBelowFoundationTableCellView
                    model: 4
                    property int id: parent.id

                    width: heaveBelowFoundationTableView.width
                    height: heaveBelowFoundationTableRow.height

                    delegate: Item {

                        x: index*width
                        width: heaveBelowFoundationTableCellView.width / 4
                        height: parent.height

                        Text {
                            id: heaveBelowFoundationTableCellEntry
                            color: "#fff3e4"
                            font.pixelSize: 18
                            
                            // Entry text is heaveBelowFoundationTable[row + column*heaveBelowFoundationTableRows]
                            // Round all values (except column 1, the layer number) to 3 decimals
                            text: (index > 0) ? props.outputData[5][heaveBelowFoundationTableCellView.id + index*props.outputData[6]].toFixed(3) : props.outputData[5][heaveBelowFoundationTableCellView.id + index*props.outputData[6]]

                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
    Text {
        text: "Total Heave Below Foundation: "
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors{
            verticalCenter: totalheaveBelowFoundationValue.verticalCenter
            right: totalheaveBelowFoundationValue.left
        }
    }
    Text {
        id: totalheaveBelowFoundationValue
        text: (props.outputDataCreated) ? props.outputData[8].toFixed(3) : "N/A"
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors {
            top: heaveBelowFoundationContainer.bottom 
            topMargin: 5
            left: heaveBelowFoundationContainer.horizontalCenter
            leftMargin: (heaveBelowFoundationContainer.width/4)/2 - width/2
        }
    }
    Text {
        text: (props.units === 0) ? "m" : "ft"
        color: "#fff3e4"
        font.pixelSize: consolidationSwellOutputScreen.tableBottomValueFontSize
        anchors {
            verticalCenter: totalheaveBelowFoundationValue.verticalCenter
            left: totalheaveBelowFoundationValue.right
            leftMargin: 1
        }
    }
    /////////////////////////////////////////////

    // Total Heave ///
    Text {
        id: totalheaveValue
        property string unitString: (props.units === 0) ? "m" : "ft"
        text: (props.outputDataCreated) ? "Total Heave of Soil Profile: " + props.outputData[9].toFixed(3) + unitString : "N/A"
        color: "#fff3e4"
        font.pixelSize: 20 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        anchors {
            top: totalheaveBelowFoundationValue.bottom 
            topMargin: 5 + 40 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
            horizontalCenter: parent.horizontalCenter
        }
    }
    //////////////////

    // Effective Stress Popup ///
    Item {
        id: effectiveStressPopupButton
        height: effectiveStressPopupButtonRect.height
        width: 1.5*effectiveStressPopupButtonRect.width

        y: 30

        Rectangle{
            id: effectiveStressPopupButtonCircle
            color: "#6B4F4F"
            width: 55
            height: 55
            radius: width/2
            anchors{
                verticalCenter: effectiveStressPopupButtonRect.verticalCenter
                horizontalCenter: effectiveStressPopupButtonRect.right
            } 
        }
        Rectangle {
            id: effectiveStressPopupButtonRect
            color: "#6B4F4F"
            width: 55
            height: 55
        }
        Image {
            source: "../Assets/layers.png"
            width: 40
            height: 40
            anchors.centerIn: effectiveStressPopupButtonCircle
        }
        MouseArea {
            anchors.fill: parent
            onClicked: effectiveStressPopup.open()
        }
    }
    Popup {
        id: effectiveStressPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        width: vdispWindow.width / 2
        height: effectiveStressPopupRepeater.height + effectiveStressPopupTitle.height + 40

        anchors.centerIn: parent

        background: Rectangle {
            color: "#6B4F4F"
            border.color: "#fff3e4"
            radius: 10
        }

        contentItem: Item {
            width: parent.width 
            height: effectiveStressPopupRepeater.height + effectiveStressPopupTitle.height + 10
            anchors.centerIn: parent

            Text {
                id: effectiveStressPopupTitle
                text: "Effective Stresses of Each Layer"
                font.pixelSize: 20
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }

            Repeater {
                id: effectiveStressPopupRepeater
                model: props.materials
                property int cellHeight: 50

                width: parent.width
                height: cellHeight * props.materials

                delegate: Rectangle {
                    width: parent.width
                    height: effectiveStressPopupRepeater.cellHeight

                    y: effectiveStressPopupTitle.height + 10 + index * effectiveStressPopupRepeater.cellHeight

                    color: (index % 2 == 0) ? "#fff3e4" : "#EED6C4"
                    
                    Text {
                        color: "#483434"
                        font.pixelSize: 20
                        property string unitString: (props.units == 0) ? "Pa" : "tsf"
                        text: (props.outputDataCreated) ? props.materialNames[index] + ": " + props.outputData[10][index].toFixed(3) + unitString: "N/A"
                        anchors.centerIn: parent
                    }
                }
            }

            Image{
                source: "../Assets/exit.png"
                width: 15
                height: 15
                anchors {
                    left: parent.left
                    leftMargin: 2
                    verticalCenter: foundationStressPopupTitle.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: effectiveStressPopup.close()
                }
            }
        }
    }
    /////////////////////////////

    // Foundation Stress Popup ///
    Item {
        id: foundationStressPopupButton
        height: foundationStressPopupButtonRect.height
        width: 1.5*foundationStressPopupButtonRect.width

        y: 30 + foundationStressPopupButton.height + 30

        Rectangle{
            id: foundationStressPopupButtonCircle
            color: "#6B4F4F"
            width: 55
            height: 55
            radius: width/2
            anchors{
                verticalCenter: foundationStressPopupButtonRect.verticalCenter
                horizontalCenter: foundationStressPopupButtonRect.right
            } 
        }
        Rectangle {
            id: foundationStressPopupButtonRect
            color: "#6B4F4F"
            width: 55
            height: 55
        }
        Image {
            source: "../Assets/layers.png"
            width: 40
            height: 40
            anchors.centerIn: foundationStressPopupButtonCircle
        }
        MouseArea {
            anchors.fill: parent
            onClicked: foundationStressPopup.open()
        }
    }
    Popup {
        id: foundationStressPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        width: foundationStressPopupTitle.width + foundationStressPopupCloseBtn.width + foundationStressPopupSwitchBtn.width + 70
        height: foundationStressPopupRepeater.height + foundationStressPopupTitle.height + 40

        property bool totalStress: false

        anchors.centerIn: parent

        background: Rectangle {
            color: "#6B4F4F"
            border.color: "#fff3e4"
            radius: 10
        }

        contentItem: Item {
            width: foundationStressPopupTitle.width + foundationStressPopupCloseBtn.width + foundationStressPopupSwitchBtn.width + 50
            height: foundationStressPopupRepeater.height + foundationStressPopupTitle.height + 10
            anchors.centerIn: parent

            Text {
                id: foundationStressPopupTitle
                text: foundationStressPopup.totalStress ? "Effective and Foundation Stresses on Soil Layers" : "Stress from Foundation on Each Layer"
                font.pixelSize: 20
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }

            Repeater {
                id: foundationStressPopupRepeater
                model: props.materials
                property int cellHeight: 50

                width: parent.width
                height: cellHeight * props.materials

                delegate: Rectangle {
                    width: parent.width
                    height: foundationStressPopupRepeater.cellHeight

                    y: foundationStressPopupTitle.height + 10 + index * foundationStressPopupRepeater.cellHeight

                    color: (index % 2 == 0) ? "#fff3e4" : "#EED6C4"
                    
                    Text {
                        color: "#483434"
                        font.pixelSize: 20
                        property string unitString: (props.units == 0) ? "Pa" : "tsf"
                        property string dataString: foundationStressPopup.totalStress ?  props.outputData[11][index].toFixed(3) : props.outputData[12][index].toFixed(3)
                        text: (props.outputDataCreated) ? props.materialNames[index] + ": " + dataString + unitString: "N/A"
                        anchors.centerIn: parent
                    }
                }
            }

            Image{
                id: foundationStressPopupCloseBtn
                source: "../Assets/exit.png"
                width: 15
                height: 15
                anchors {
                    left: parent.left
                    leftMargin: 2
                    verticalCenter: foundationStressPopupTitle.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: foundationStressPopup.close()
                }
            }

            Image{
                id: foundationStressPopupSwitchBtn
                source: "../Assets/layers.png"
                width: 15
                height: 15
                anchors {
                    right: parent.right
                    rightMargin: 2
                    verticalCenter: foundationStressPopupTitle.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: foundationStressPopup.totalStress = !foundationStressPopup.totalStress
                }
            }
        }
    }
    //////////////////////////////

    // Save Output ///////////////
    Rectangle {
        id: selectOutputButton
        color: "#6B4F4F"
        border.color: "#fff3e4"
        radius: 5
        width: selectOutputButtonContainer.width + 10
        height: selectOutputButtonContainer.height + 5
        anchors {
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }

        Item {
            id: selectOutputButtonContainer
            
            height: selectOutputButtonIcon.height
            width: selectOutputButtonText.width + gap + selectOutputButtonIcon.width

            anchors.centerIn: parent

            property int gap: 10
            property string fileName: ""
            property bool selectedOutputFile: false

            Text{
                id: selectOutputButtonText
                text: (selectOutputButtonContainer.selectedOutputFile) ? selectOutputButtonContainer.fileName : "Save Output"
                color: "#fff3e4"
                font.pixelSize: 15
                anchors{
                    left: parent.left
                    verticalCenter: selectOutputButtonIcon.verticalCenter
                }
            }
            Image {
                id: selectOutputButtonIcon
                source: (selectOutputButtonContainer.selectedOutputFile) ? "../Assets/fileAccept.png" : "../Assets/download.png"
                width: 20
                height: 20
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: selectOutputButtonText.right
                    leftMargin: selectOutputButtonContainer.gap
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: fileDialog.open()
        }
    }
    FileDialog {
        id: fileDialog
        title: "Please select output file"
        selectMultiple: false
        selectExisting: false
        folder: shortcuts.home
        nameFilters: ["VDisp data files (*.dat)" ]
        onAccepted: {
            selectOutputButtonContainer.selectedOutputFile = true
            props.outputFile = fileUrl.toString()
            // Convert URL to string
            var name = fileUrl.toString()
            // Split URL String at each "/" and extract last piece of data
            var path = name.split("/")
            var fileName = path[path.length - 1]
            // Update fileName property
            selectOutputButtonContainer.fileName = fileName
            
            // UI elements for download prompt
            selectOutputTimer.start()
            fileDownloadingPopup.open()
        }
        onRejected: {
            selectOutputButtonContainer.selectedOutputFile = false
        }
    }
    Popup {
        id: fileDownloadingPopup
        width: fileDownloadingPopupText.width + gap*3 + fileDownloadingPopupImage.width
        height: 30
        closePolicy: Popup.NoAutoClose // Only close from timer

        background: Rectangle{
            color: "#6B4F4F"
        }

        property int gap: 5

        x: 0
        y:  vdispWindow.height - fileDownloadingPopup.height

        contentItem: Item{
            anchors.fill: parent

            Text{
                id: fileDownloadingPopupText
                text: "Saving file: " + selectOutputButtonContainer.fileName
                color: "#fff3e4"
                font.pixelSize: 18
                anchors {
                    left: parent.left
                    leftMargin: fileDownloadingPopup.gap
                    verticalCenter: parent.verticalCenter
                }
            }

            Image {
                id: fileDownloadingPopupImage
                source: "../Assets/spinner.png"
                height: 20
                width: 20

                anchors {
                    left: fileDownloadingPopupText.right
                    leftMargin: fileDownloadingPopup.gap
                    verticalCenter: fileDownloadingPopupText.verticalCenter
                }

                RotationAnimator on rotation {
                    from: 0;
                    to: 360;
                    duration: 1000
                    running: true
                }
            }
        }
    }
    Timer {
        id: selectOutputTimer
        interval: 2000 // 2s
        running: false
        repeat: false
        onTriggered: {
            selectOutputButtonContainer.selectedOutputFile = false
            fileDownloadingPopup.close()
        }
    }
    ///////////////////////////////

    // Back arrow /////////////////
    Image {
        id: backArrow
        width: height
        height: 32 + (50-32)*(vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        source: "../Assets/back.png"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left 
            leftMargin: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                mainLoader.source = "../EnterDataScreen/EnterDataScreen.qml"
            }
        }
    }
    ///////////////////////////////
}