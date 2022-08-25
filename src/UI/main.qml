/*
    Main QML file of VDisp GUI program.

    Author: Emil Soleymani (soleymae@mcmaster.ca)
    Date: August 2022
*/

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
        if(sourceSize < 24){
            /* 
                Halfway between 16 and 24 is 20. Any icon less than 20px
            in size will get its image from the 16px folder. Follow the same 
            logic to derive values 28, 48, 96, etc... in "else if" statements
            */
            finalSize = 16
        }else if(sourceSize < 32){
            finalSize = 24
        }else if(sourceSize < 64){
            finalSize = 32
        }else if(sourceSize < 128){
            finalSize = 64
        }else if(sourceSize < 256){
            finalSize = 128
        }else if(sourceSize < 512){
            finalSize = 256
        }else{
            finalSize = 512
        }

        // Make sure finalSize is in range [min, max]
        return Math.min(max, Math.max(min, finalSize))
    }

    Loader {
        id: mainLoader
        
        width: vdispWindow.width
        height: vdispWindow.height

        // Initial screen
        source: "./MenuScreen/MenuScreen.qml"

        /*
            If user presses back button, push all screens 
        to stack until the last page
        */
        property bool pushScreens: false
        property string lastScreen: ""  // Which screen is the last (Stage 4 or 5 or 6)
    }
}