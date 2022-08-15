import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: schmertmannOutputScreen
    color: "#483434"
    anchors.fill: parent

    property int titleMargin: 10 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int subtitleMargin: 3 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int tableMargin: 10 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int tableBottomValueFontSize: 12 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

    // Title ////////////////////
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
        property string elasticString: (props.model === 2) ? " Elastic" : ""
        text: "Schmertmann" + elasticString
        color: "#fff3e4"
        font.pixelSize: 15 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: outputScreenTitle.bottom
            topMargin: parent.subtitleMargin
        }
    }
    /////////////////////////////

    // Settlement Table /////////
    Text {
        id: settlementTableTitle
        text: "Settlement " + props.outputData[1] + " Years After Construction"
        font.pixelSize: 20
        color: "#fff3e4"
        anchors {
            top: outputScreenSubTitle.bottom
            topMargin: schmertmannOutputScreen.tableMargin
            left: settlementContainer.left
            leftMargin: 10
        }
    }
    Item {
        id: settlementContainer

        width: 600 + 300 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        height: settlementTableHeaderView.height + settlementTableView.height

        clip: true

        anchors {
            top: settlementTableTitle.bottom
            topMargin: 2
            horizontalCenter: parent.horizontalCenter
        }

        // Header Background /////
        Rectangle {
            color: "#5E4545"
            radius: 10
            anchors.fill: settlementTableHeaderView

            Rectangle {
                color: "#5E4545"
                height: 10
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
        //////////////////////////
        
        // Body Background ////////
        Rectangle {
            color: "#6B4F4F"
            radius: 10
            anchors.fill: settlementTableView

            Rectangle {
                color: "#6B4F4F"
                height: 10
                width: parent.width
                anchors.top: parent.top
            }
        }
        //////////////////////////

        // Divider ////////////////
        Rectangle{
            color: "#fff3e4"
            width: parent.width
            height: 1.5
            anchors.verticalCenter: settlementTableHeaderView.bottom
        }
        //////////////////////////

        // Border /////////////////
        Rectangle {
            border.color: "#fff3e4"
            radius: 10
            color: "transparent"
            anchors.fill: parent
        }
        //////////////////////////

        // Header ////////////////
        Repeater {
            id: settlementTableHeaderView
            model: 3

            property string distUnit: props.units === 0 ? "m" : "ft"
            property string pressureUnit: props.units === 0 ? "Pa" : "tsf"
            property variant headers: ["Element", "Depth ("+distUnit+")", "Settlement (" + distUnit + ")"]

            width: settlementContainer.width
            height: settlementTableView.cellHeight

            delegate: Item {
                x: index*width

                width: settlementTableHeaderView.width / 3
                height: settlementTableHeaderView.height

                Text {
                    color: "#fff3e4"
                    font.pixelSize: 18
                    text: settlementTableHeaderView.headers[index]
                    anchors.centerIn: parent
                }
            }
        }
        //////////////////////////

        // Table /////////////////
        ListView {
            id: settlementTableView
            model: props.outputData[5]  // settlementTableRows

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded  // From docs: The scroll bar is only shown when the content is too large to fit.
                // Custom Bar
                contentItem: Rectangle {
                    visible: settlementTableView.interactive
                    implicitWidth: 6
                    opacity: 0.4
                    color: "#fff3e4"
                }
            }

            width: settlementContainer.width
            height: Math.min(maxHeight, props.outputData[5]*cellHeight)

            property int cellHeight: 50
            property int maxHeight: 350 + 100 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            clip: true
            interactive: props.outputData[5]*cellHeight > maxHeight
            boundsMovement: Flickable.StopAtBounds

            anchors{
                top: settlementTableHeaderView.bottom
                horizontalCenter: parent.horizontalCenter
            }

            delegate: Item {
                id: settlementTableRow
                
                height: settlementTableView.cellHeight
                property int id: index

                Repeater {
                    id: settlementTableCellView
                    model: 3
                    property int id: parent.id

                    width: settlementTableView.width
                    height: settlementTableRow.height

                    delegate: Item {

                        x: index*width
                        width: settlementTableCellView.width / 3
                        height: parent.height

                        Text {
                            id: settlementTableCellEntry
                            color: "#fff3e4"
                            font.pixelSize: 18
                            
                            // Entry text is settlementTable[row + column*settlementTableRows]
                            // Round all values (except column 1, the layer number) to 3 decimals
                            text: (index > 0) ? props.outputData[4][settlementTableCellView.id + index*props.outputData[5]].toFixed(3) : props.outputData[4][settlementTableCellView.id + index*props.outputData[5]]

                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
        //////////////////////////
    }
    Text {
        id: totalSettlementValue
        
        color: "#fff3e4"
        font.pixelSize: schmertmannOutputScreen.tableBottomValueFontSize + 8
        
        property string unitString: (props.units === 0) ? " m" : " ft"
        property double settlement: (props.outputDataCreated) ? props.outputData[6].toFixed(3) : "N/A"
        text: "Total Settlement: " + settlement + unitString
        
        anchors {
            top: settlementContainer.bottom 
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }
    /////////////////////////////

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
                        property string unitString: (props.units == 0) ? " Pa" : " tsf"
                        text: (props.outputDataCreated) ? props.materialNames[index] + ": " + props.outputData[7][index].toFixed(3) + unitString: "N/A"
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
            source: "../Assets/64/building.png"
            width: 35
            height: 35
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
                        property string unitString: (props.units == 0) ? " Pa" : " tsf"
                        property string dataString: foundationStressPopup.totalStress ?  props.outputData[9][index].toFixed(3) : props.outputData[8][index].toFixed(3)
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

    // Plot //////////////////////
    Rectangle {
        id: plotBtn
        color: "#6B4F4F"
        width: plotBtnContents.width + 20
        height: plotBtnContents.height + 10
        radius: 5

        anchors {
            left: parent.left
            leftMargin: 15
            bottom: parent.bottom
            bottomMargin: 10
        }

        Item {
            id: plotBtnContents
            
            property int gap: 15
            width: plotBtnText.width + gap + plotBtnImage.width
            height: plotBtnImage.height

            anchors.centerIn: plotBtn
            
            Text {
                id: plotBtnText
                text: "View Plot"
                color: "#fff3e4"
                font.pixelSize: 18

                anchors{
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            Image {
                id: plotBtnImage
                source: "../Assets/32/lineGraph.png"
                width: 20
                height: 20

                anchors {
                    left: plotBtnText.right
                    leftMargin: plotBtnContents.gap
                    verticalCenter: plotBtnText.verticalCenter
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Force Julia to run graphing code
                props.graphData = false
                props.graphData = true
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
            color: "transparent"
        }

        property int gap: 5

        x: vdispWindow.width/2 - (fileDownloadingPopupText.width + gap + fileDownloadingPopupImage.width)/2
        y: vdispWindow.height - fileDownloadingPopup.height

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
                mainLoader.pushScreens = true
                mainLoader.lastScreen = (props.model === 1) ? "EnterDataStage5.qml" : "EnterDataStage6.qml"
                mainLoader.source = "../EnterDataScreen/EnterDataScreen.qml"
            }
        }
    }
    ///////////////////////////////
}