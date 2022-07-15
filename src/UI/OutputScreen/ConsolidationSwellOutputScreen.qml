import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import org.julialang 1.0

Rectangle {
    id: consolidationSwellOutputScreen
    color: "#483434"
    anchors.fill: parent

    // Calculating Data Progress Bar
    CustomProgressBar {
        id: loadingProgressBar
        minimum: 0
        maximum: 100
        value: props.outputDataProgress
        visible: !props.outputDataCreated
        anchors.centerIn: parent
    }
    Text {
        id: progressText
        visible: !props.outputDataCreated
        text: "Calculating Values: " + loadingProgressBar.value + "%" 
        color: "#fff3e4"
        font.pixelSize: 25
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: loadingProgressBar.bottom
            topMargin: 10
        }
    }

    property int titleMargin: 15 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int subtitleMargin: 5 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
    property int tableMargin: 10 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
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
        id: heaveAboveFoudationTableTitle
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
            top: heaveAboveFoudationTableTitle.bottom
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
        font.pixelSize: 18
        anchors{
            verticalCenter: totalHeaveAboveFoundationValue.verticalCenter
            right: totalHeaveAboveFoundationValue.left
        }
    }
    Text {
        id: totalHeaveAboveFoundationValue
        text: (props.outputDataCreated) ? props.outputData[7].toFixed(3) : "N/A"
        color: "#fff3e4"
        font.pixelSize: 18
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
        font.pixelSize: 18
        anchors {
            verticalCenter: totalHeaveAboveFoundationValue.verticalCenter
            left: totalHeaveAboveFoundationValue.right
            leftMargin: 1
        }
    }
    /////////////////////////////////////////////
}