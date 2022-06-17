import QtQuick 2.0
import QtQuick.Controls 2.12
import org.julialang 1.0

Item {
    id: enterDataScreen

    Rectangle{
        id: backgroundRect
        color: "#483434"
        anchors.fill: parent
    }

    StackView {
        id: enterDataStackView
        anchors.fill: parent
        initialItem: "EnterDataStage1.qml"
    }
}