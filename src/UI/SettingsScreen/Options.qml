import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: optionsBackground
    width: vdispWindow.width * .8
    height: vdispWindow.height * .8
    anchors.centerIn: parent
    color: "#6B4F4F"
    radius: 5

    // Units ////////
    Item{
        id: unitsDropdownContainer

        width: unitsLabel.width + unitsDropdown.width + 10
        height: unitsDropdown.height

        anchors{
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 40
        }

        Text{
            id: unitsLabel
            text: "Unit System: "
            color: "#FFF3E4"
            font.pixelSize: 18
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }
        ComboBox {
            id: unitsDropdown
            model: ["Metric", "Imperial"]
            
            anchors {
                left: unitsLabel.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }

            Component.onCompleted: {
                currentIndex = props.units
            }

            width: optionsBackground.width / 4
            height: 30
            font.pixelSize: 18
            
            property bool loaded: false
            onCurrentIndexChanged: {
                if(!loaded){
                    // The ComboBox loading also emits current index change signal
                    loaded = true
                }else{
                    props.units = currentIndex
                }
            }

            // Text of dropdown list
            delegate: ItemDelegate {
                width: unitsDropdown.width
                contentItem: Text {
                    text: modelData
                    color: highlighted ? "#6B4F4F" : "#483434"
                    font: unitsDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: unitsDropdown.highlightedIndex === index
                
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
                id: unitsCanvas
                x: unitsDropdown.width - width - 10
                y: unitsDropdown.height / 2 - 3
                width: 12
                height: 8
                contextType: "2d"
                Connections {
                    target: unitsDropdown
                    function onPressedChanged() { unitsCanvas.requestPaint(); }
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
                text: unitsDropdown.displayText
                font: unitsDropdown.font
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
                width: unitsDropdown.width
                height: 30
                color: "#fff3e4"
                radius: 5
            }
            popup: Popup {
                y: unitsDropdown.height - 1
                width: unitsDropdown.width
                implicitHeight: contentItem.implicitHeight
                padding: 0
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: unitsDropdown.popup.visible ? unitsDropdown.delegateModel : null
                    currentIndex: unitsDropdown.highlightedIndex
                }
                background: Rectangle {
                    color: "#fff3e4"
                    radius: 2
                }
            }
        }
    }
    /////////////////////

    // Describe Unit System ///
    Item {
        id: unitsTable

        property variant measures: ["Distance", "Pressure", "Cone Penetration", "Elastic Modulus"]
        property variant imperialUnits: ["ft", "tsf", "tsf", "tsf"]
        property variant metricUnits: ["m", "Pa", "KPa", "KPa"]

        property int rows: measures.length + 1 // Extra row for header

        property int cellWidth: 150
        property int cellHeight: 30
        property int tableGap: 20

        width: 2 * (cellWidth*2) + tableGap 
        height: rows * cellHeight 

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }

        // Metric Table ///////////
        // Title
        Text {
            text: "Metric System Units"
            
            color: "#fff3e4"
            font.pixelSize: 20

            anchors {
                horizontalCenter: metricTable.horizontalCenter
                bottom: metricTable.top
                bottomMargin: 5
            }
        }
        // Header Background
        Rectangle {
            id: metricHeaderBg
            color: "#5E4545"
            radius: 10
            
            width: unitsTable.cellWidth * 2
            height: unitsTable.cellHeight
            

            Rectangle {
                color: "#5e4545"
                height: 10
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
        // Body Background
        Rectangle {
            color: "#483434"
            radius: 10
            
            width: unitsTable.cellWidth * 2
            height: unitsTable.height - unitsTable.cellHeight
            y: unitsTable.cellHeight // Start from second row

            Rectangle {
                color: "#483434"
                height: 10
                width: parent.width
                anchors.top: parent.top
            }
        }
        // Outline
        Rectangle {
            anchors.fill: metricTable
            radius: 10
            color: "transparent"
            border.color: "#fff3e4"
        }
        // Divider
        Rectangle {
            color: "#fff3e4"

            width: unitsTable.cellWidth * 2
            height: 1

            anchors.verticalCenter: metricHeaderBg.bottom
        }
        // Table
        Repeater {
            id: metricTable
            model: 2

            width: unitsTable.cellWidth * 2
            height: unitsTable.rows * unitsTable.cellHeight

            delegate: Repeater {  // Repeat each row
                id: metricTableRows
                model: unitsTable.rows

                property string columnHeader: (index === 0) ? "Measure" : "Unit"
                property variant dataList: (index === 0) ? unitsTable.measures : unitsTable.metricUnits

                width: unitsTable.cellWidth
                height: unitsTable.height

                x: index * unitsTable.cellWidth

                delegate: Item {
                    x: metricTableRows.x
                    y: index * unitsTable.cellHeight

                    width: unitsTable.cellWidth
                    height: unitsTable.cellHeight

                    property string cellText: (index === 0) ? metricTableRows.columnHeader : metricTableRows.dataList[index-1]

                    Text {
                        text: cellText
                        font.pixelSize: (index === 0) ? 15 : 13
                        color: "#fff3e4"
                        anchors.centerIn: parent
                    }
                }
            }
        }
        ///////////////////////////

        // Imperial Table ///////////
        // Title
        Text {
            text: "Imperial System Units"
            
            color: "#fff3e4"
            font.pixelSize: 20

            anchors {
                horizontalCenter: imperialTable.horizontalCenter
                bottom: imperialTable.top
                bottomMargin: 5
            }
        }
        // Header Background
        Rectangle {
            id: imperialHeaderBg
            color: "#5E4545"
            radius: 10
            
            width: unitsTable.cellWidth * 2
            height: unitsTable.cellHeight
            x: imperialTable.x
            

            Rectangle {
                color: "#5e4545"
                height: 10
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
        // Body Background
        Rectangle {
            color: "#483434"
            radius: 10
            
            width: unitsTable.cellWidth * 2
            height: unitsTable.height - unitsTable.cellHeight
            x: imperialTable.x
            y: unitsTable.cellHeight // Start from second row

            Rectangle {
                color: "#483434"
                height: 10
                width: parent.width
                anchors.top: parent.top
            }
        }
        // Outline
        Rectangle {
            anchors.fill: imperialTable
            radius: 10
            color: "transparent"
            border.color: "#fff3e4"
        }
        // Divider
        Rectangle {
            color: "#fff3e4"

            width: unitsTable.cellWidth * 2
            height: 1
            x: imperialTable.x

            anchors.verticalCenter: imperialHeaderBg.bottom
        }
        // Table
        Repeater {
            id: imperialTable
            model: 2

            width: unitsTable.cellWidth * 2
            height: unitsTable.rows * unitsTable.cellHeight

            x: unitsTable.cellWidth * 2 + unitsTable.tableGap

            delegate: Repeater {  // Repeat each row
                id: imperialTableRows
                model: unitsTable.rows

                property string columnHeader: (index === 0) ? "Measure" : "Unit"
                property variant dataList: (index === 0) ? unitsTable.measures : unitsTable.imperialUnits

                width: unitsTable.cellWidth
                height: unitsTable.height

                x: index * unitsTable.cellWidth + unitsTable.cellWidth * 2 + unitsTable.tableGap

                delegate: Item {
                    x: imperialTableRows.x
                    y: index * unitsTable.cellHeight

                    width: unitsTable.cellWidth
                    height: unitsTable.cellHeight

                    property string cellText: (index === 0) ? imperialTableRows.columnHeader : imperialTableRows.dataList[index-1]

                    Text {
                        text: cellText
                        font.pixelSize: (index === 0) ? 15 : 13
                        color: "#fff3e4"
                        anchors.centerIn: parent
                    }
                }
            }
        }
        ///////////////////////////
    }
    ///////////////////////////
}