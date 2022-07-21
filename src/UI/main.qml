import QtQuick 2.12
import QtQuick.Window 2.12
import org.julialang 1.0

Window {
    id: vdispWindow
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    maximumWidth: 1920
    maximumHeight: 1080
    visible: true
    title: qsTr("VDisp")

    function isMinHeight(){
        return height === minimumHeight
    }
    function isMinWidth(){
        return width === minimumWidth
    }
    function isMinSize(){
        return isMinHeight() && isMinWidth()
    }

    /*
        VDisp icons are sorted into folders of 16px, 24px, 32px, 64px,
    128px, 256px and 512px. When rendering, each icon calls this function
    to determine the nearest resolution given the desired icon size.
        Since each icon will not necessarily exist in all 7 folders, min and
    max ensure an existing size is chosen
    */
    function getImageFolder(sourceSize, min, max){
        var finalSize = 0
        if(sourceSize < 20){
            /* 
                Halfway between 16 and 24 is 20. Any icon less than 20px
            in size will get its image from the 16px folder. Follow the same 
            logic to derive values 28, 48, 96, etc... in "else if" statements
            */
            finalSize = 16
        }else if(sourceSize < 28){
            finalSize = 24
        }else if(sourceSize < 48){
            finalSize = 32
        }else if(sourceSize < 96){
            finalSize = 64
        }else if(sourceSize < 192){
            finalSize = 128
        }else if(sourceSize < 384){
            finalSize = 256
        }else{
            finalSize = 512
        }

        // Make sure finalSize is in range [min, max]
        return Math.min(max, Math.max(min, finalSize))
    }

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "./MenuScreen/MenuScreen.qml"
    }
}