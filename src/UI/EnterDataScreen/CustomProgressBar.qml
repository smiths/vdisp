import QtQuick 2.0

/*
    No use for this currently, maybe will add to EnterDataStage4,5,6
*/

Rectangle { // background
    id: root

    // public
    property double maximum: 10
    property double value:   0
    property double minimum: 0

    property string bgColor: "#EED6C4"
    property string fgColor: "#fff3e4"
    property string borderColor: "transparent"

    // private
    width: parent.width/2  
    height: 50 // default size

    border.width: 2
    border.color: borderColor
    radius: 0.5 * height
    color: bgColor
   
    Rectangle { // foreground
        visible: value > minimum
        width: Math.max(height,
               Math.min((value - minimum) / (maximum - minimum) * (parent.width),
                        parent.width)) // clip
        height: root.height
        color: root.fgColor
        radius: parent.radius
    }
}   