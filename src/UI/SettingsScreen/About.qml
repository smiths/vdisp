import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: aboutBackground
    
    width: vdispWindow.width * .8
    height: vdispWindow.height * .8
    
    anchors.centerIn: settingsStackView

    color: "#6B4F4F"
    radius: 5

    // Title ///////////////////////
    Text {
        id: aboutTitle
        
        text: "About"
        color: "#fff3e4"
        font.pixelSize: 32 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 10
        }
    }
    ///////////////////////////////

    // Paragaph ///////////////////
    Text {
        id: aboutParagraph

        text: "<b>VDisp</b> is a one-dimensional soil settlement analysis software, written using the Julia programming language and Qt/QML."
        color: "#fff3e4"
        font.pixelSize: 18 + 14 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)

        width: vdispWindow.width * 0.8 * 0.8
        wrapMode: Text.WordWrap

        anchors {
            centerIn: parent
        }
    }

    Text {
        id: acknowledgementLink

        color: "#fff3e4"
        font.pixelSize: 16 + 10 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        text: "<u>Acknowledgements</u>"
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Qt.openUrlExternally("https://github.com/smiths/vdisp/blob/main/Acknowledgements.md")
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: aboutParagraph.bottom
            topMargin: 20
        }
    }
    ///////////////////////////////

    // Footer ////////////////////
    Text {
        id: footer
        text: "Authors: Emil Soleymani, Dr. Spencer Smith, Dr. Dieter Stolle"
        color: "#fff3e4"
        
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
    }
    //////////////////////////////
}