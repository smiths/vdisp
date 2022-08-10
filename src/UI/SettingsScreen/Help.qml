import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Rectangle {
    id: helpBackground
    
    width: vdispWindow.width * .8
    height: vdispWindow.height * .8
    
    anchors.centerIn: settingsStackView

    color: "#6B4F4F"
    radius: 5

    // Title ///////////////////////
    Text {
        id: helpTitle
        
        text: "Help"
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
        id: helpParagraph

        text: "For help with using the <b>VDisp</b> software, or understanding what happens behind the scenes, see the following links: "
        color: "#fff3e4"
        font.pixelSize: 18 + 10 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)

        width: vdispWindow.width * 0.8 * 0.8
        wrapMode: Text.WordWrap

        anchors {
            centerIn: parent
        }
    }
    ///////////////////////////////

    // Links ///////////////////////
    property int linkSpace: 10
    Text {
        id: wikiLink

        color: "#fff3e4"
        font.pixelSize: 16 + 10 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        text: "<u>VDisp Wiki</u>"
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Qt.openUrlExternally("https://github.com/smiths/vdisp/wiki")
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: helpParagraph.bottom
            topMargin: helpBackground.linkSpace
        }
    }

    Text {
        id: userGuideLink

        color: "#fff3e4"
        font.pixelSize: 16 + 10 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        text: "<u>User Guide Video</u>"
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Qt.openUrlExternally("https://github.com/smiths/vdisp/wiki")  // TODO: Replace link with user guide vidoe link when ready
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: wikiLink.bottom
            topMargin: helpBackground.linkSpace
        }
    }

    Text {
        id: docsLink

        color: "#fff3e4"
        font.pixelSize: 16 + 10 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        text: "<u>VDisp Documentation</u>"
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Qt.openUrlExternally("https://smiths.github.io/vdisp/dev/")
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: userGuideLink.bottom
            topMargin: helpBackground.linkSpace
        }
    }
    ///////////////////////////////
}