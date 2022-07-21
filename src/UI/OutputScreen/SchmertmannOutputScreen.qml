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
        text: "Schmertmann"
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
        
        property string unitString: (props.units === 0) ? "m" : "ft"
        property double settlement: (props.outputDataCreated) ? props.outputData[6].toFixed(3) : "N/A"
        text: "Total Settlement: " + settlement + unitString
        
        anchors {
            top: settlementContainer.bottom 
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }
    /////////////////////////////

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
}