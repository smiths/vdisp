import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: optionsBackground
    width: parent.width * .8
    height: parent.height * .8
    anchors.centerIn: parent
    color: "#6B4F4F"
    radius: 5

    // Units ////////
    Item{
        width: unitsLabel.width + unitsDropdown.width + 10
        height: unitsDropdown.height

        anchors.centerIn: parent

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
}