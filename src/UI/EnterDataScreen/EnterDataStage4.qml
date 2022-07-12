import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: consolidationSwellDataBackground

    function formIsFilled(){
        // Check that all arrays have correct length
        if(filledSP.length != props.materials || filledSI.length != props.materials || filledCI.length != props.materials || filledRI.length != props.materials) return false
        // Check that each properties entries are valid
        for(var i = 0; i < props.materials; i++){
            if(!filledSP[i] || !filledSI[i] || !filledCI[i] || !filledRI[i]) return false
        }
        return true
    }

    function forceUpdate(){
        var temp = props.heaveActive
        props.heaveActive = 12
        props.heaveActive = temp
    }

    function isFilled(){
        // should there be a min difference between heave begin and heave active depth
        return selectedOutputFile && (props.heaveActive - props.heaveBegin > 0) && formIsFilled()
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property bool highlightErrors: false
    property bool selectedOutputFile: false
    
    
    property int formGap: 20

    property variant filledSP: []
    property variant filledSI: []
    property variant filledCI: []
    property variant filledRI: []

    Component.onCompleted: {
        if(!props.inputFileSelected){
            for(var i = 0; i < props.materials; i++){
                // Populate arrays that check if forms are filled properly
                filledSP.push(false)
                filledSI.push(false)
                filledCI.push(false)
                filledRI.push(false)
                // Initialize Julia arrays to correct number of entries, 0.0 for all
                props.swellPressure = [...props.swellPressure, 0.0]
                props.swellIndex = [...props.swellIndex, 0.0]
                props.compressionIndex = [...props.compressionIndex, 0.0]
                props.recompressionIndex = [...props.recompressionIndex, 0.0]
            }
        }
    }

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: (parent) ? parent.horizontalCenter : undefined
        verticalCenter: (parent) ? parent.verticalCenter : undefined
    }

    // Title //////////////
    Text {
        id: consolidationSwellTitle
        text: "Enter Values"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
    }
    Text {
        id: consolidationSwellSubtitle
        text: "Consolidation/Swell"
        font.pixelSize: 15
        color: "#fff3e4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: consolidationSwellTitle.bottom 
            topMargin: 10
        }
    }
    ///////////////////////

    // Form ////////////////
    Item {
        id: consolidationSwellDataContainer

        width: Math.max(heaveSliderContainer.width, consolidationSwellDataList.maxWidth)
        height: heaveSliderContainer.height + consolidationSwellDataBackground.formGap + consolidationSwellDataList.height
        
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter 
        }

        // Heave Slider //////
        Item {
            id: heaveSliderContainer

            property int sliderWidth: 0.8*(consolidationSwellDataBackground.width - heaveSliderLabel.width)
            property int labelGap: 5
            property int fontSize: 15 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            // set width and height
            width: heaveSliderLabel.width + sliderWidth + labelGap
            height: heaveSlider.height + heaveBeginText.height + heaveActiveText.height

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            // Label ////////
            Text {
                id: heaveSliderLabel
                text: "Heave: "
                color: "#fff3e4"
                font.pixelSize: parent.fontSize

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            /////////////////

            // Range Slider ///
            RangeSlider {
                id: heaveSlider
                clip: false

                // Values
                from: 0
                to: props.totalDepth
                first.value: (props.inputFileSelected) ?  props.heaveBegin : props.totalDepth/4
                second.value: (props.inputFileSelected) ?  props.heaveActive : 3*props.totalDepth/4
                stepSize: 0.025
                snapMode: RangeSlider.SnapAlways  // TODO: toggle to RangeSlider.NoSnap with a snap to grid option?

                width: parent.sliderWidth
                height: 26

                first.onMoved: {
                    // Update Julia Variable
                    props.heaveBegin = first.value
                }
                second.onMoved: {
                    // Update Julia Variable
                    props.heaveActive = second.value
                }

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: heaveSliderLabel.right
                    leftMargin: parent.labelGap
                }

                background: Rectangle {
                    x: heaveSlider.leftPadding
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: parent.width
                    implicitHeight: 4
                    width: heaveSlider.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: "#483434"

                    // Highlight inbetween range
                    Rectangle {
                        x: heaveSlider.first.visualPosition * parent.width
                        width: heaveSlider.second.visualPosition * parent.width - x
                        height: parent.height
                        color: "#EED6C4"
                        radius: 2
                    }

                    // Highlight active heave range
                    Rectangle {
                        x: heaveSlider.second.visualPosition * parent.width
                        width: parent.width - x
                        height: parent.height
                        color: "#fff3e4"
                        radius: 2
                    }
                }

                first.handle: Rectangle {
                    x: heaveSlider.leftPadding + heaveSlider.first.visualPosition * (heaveSlider.availableWidth - width)
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: "#fff3e4"

                    Text {
                        id: heaveBeginText
                        text: "Begin: " + heaveSlider.first.value.toFixed(3)
                        color: "#fff3e4"
                        font.pixelSize: heaveSliderContainer.fontSize
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.bottom
                            topMargin: heaveSliderContainer.labelGap
                        }
                    }
                }

                second.handle: Rectangle {
                    x: heaveSlider.leftPadding + heaveSlider.second.visualPosition * (heaveSlider.availableWidth - width)
                    y: heaveSlider.topPadding + heaveSlider.availableHeight / 2 - height / 2
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: "#fff3e4"

                    Text {
                        id: heaveActiveText
                        text: "Active: " + heaveSlider.second.value.toFixed(3)
                        color: "#fff3e4"
                        font.pixelSize: heaveSliderContainer.fontSize
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.top
                            bottomMargin: heaveSliderContainer.labelGap
                        }
                    }
                }
            }
            ///////////////////
        }
        //////////////////////

        // Items /////////////
        Repeater {
            id: consolidationSwellDataList
            model: props.materials

            property int maxWidth: 0
            property int rowGap: 5

            width: consolidationSwellDataListEntry.width
            height: props.materials * (35+rowGap)

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: heaveSliderContainer.bottom
                topMargin: consolidationSwellDataBackground.formGap
            }

            delegate: Item {
                id: consolidationSwellDataListEntry

                property int inputWidth: 35 + 20 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
                property int inputGap: 10
                property int labelGap: 5
                property int fontSize: 12 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

                width: consolidationSwellDataListEntryMaterialLabel.width + consolidationSwellDataListEntrySPLabel.width + consolidationSwellDataListEntrySILabel.width + consolidationSwellDataListEntryCILabel.width + consolidationSwellDataListEntryRILabel.width + 4*inputWidth + 4*inputGap + 4*labelGap
                height: 35

                Component.onCompleted: {
                    consolidationSwellDataList.maxWidth = Math.max(consolidationSwellDataListEntryMaterialLabel.width + consolidationSwellDataListEntrySPLabel.width + consolidationSwellDataListEntrySILabel.width + consolidationSwellDataListEntryCILabel.width + consolidationSwellDataListEntryRILabel.width + 4*inputWidth + 4*inputGap + 4*labelGap, consolidationSwellDataList.maxWidth)
                }

                y: heaveSliderContainer.height + consolidationSwellDataBackground.formGap + (height + consolidationSwellDataList.rowGap) * index

                anchors.horizontalCenter: parent.horizontalCenter

                // Material Name ///////////
                Text {
                    id: consolidationSwellDataListEntryMaterialLabel
                    text: props.materialNames[index] + ":"
                    color: "#fff3e4"
                    font.pixelSize: consolidationSwellDataListEntry.fontSize
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntry.left
                    }
                }
                /////////////////////////////

                // Swell Pressure ///////////
                Text {
                    id: consolidationSwellDataListEntrySPLabel
                    text: "Swell Pressure: "
                    color: "#fff3e4"
                    font.pixelSize: consolidationSwellDataListEntry.fontSize
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntryMaterialLabel.right
                        leftMargin: consolidationSwellDataListEntry.inputGap
                    }
                }

                Rectangle {
                    id: spTextbox
                    width: consolidationSwellDataListEntry.inputWidth
                    height: 20
                    color: "#fff3e4"
                    radius: 4
                    clip: true
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntrySPLabel.right
                        leftMargin: consolidationSwellDataListEntry.labelGap
                    }

                    // Error highlighting
                    Rectangle {
                        visible: (consolidationSwellDataBackground.highlightErrors && (!spTextInput.acceptableInput || !spTextInput.text))
                        opacity: 0.8
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        radius: 5
                    }

                    TextInput {
                        id: spTextInput
                        width: text ? text.width : spTextInputPlaceholder.width
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: parent.left 
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        
                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator {
                            bottom: 0
                        }

                        Component.onCompleted: {
                            if(props.inputFileSelected) text = props.swellPressure[index]
                        }

                        onTextChanged: {
                            if(acceptableInput){
                                // Set filled to true
                                filledSP[index] = true
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                                var sp = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index){
                                        sp = [...sp, parseFloat(text)]
                                    }else{
                                        sp = [...sp, props.swellPressure[i]]
                                    }
                                }
                                props.swellPressure = [...sp]
                            }else {
                                // Set filled to false
                                filledSP[index] = false
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                            }
                        }
                        // Placeholder Text
                        property string placeholderText: "--.--"
                        Text {
                            id: spTextInputPlaceholder
                            text: spTextInput.placeholderText
                            font.pixelSize: consolidationSwellDataListEntry.fontSize
                            color: "#483434"
                            visible: !spTextInput.text
                        }
                    }
                    // Units
                    Text{
                        text: (props.units === 0) ? " Pa" : " tsf"
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: spTextInput.right
                            leftMargin: 1
                            verticalCenter: parent.verticalCenter
                        }
                        visible: spTextInput.text
                    }
                }
                //////////////////////////////////////

                // Swell Index ///////////
                Text {
                    id: consolidationSwellDataListEntrySILabel
                    text: "Swell Index: "
                    color: "#fff3e4"
                    font.pixelSize: consolidationSwellDataListEntry.fontSize
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: spTextbox.right
                        leftMargin: consolidationSwellDataListEntry.inputGap
                    }
                }

                Rectangle {
                    id: siTextbox
                    width: consolidationSwellDataListEntry.inputWidth
                    height: 20
                    color: "#fff3e4"
                    radius: 4
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntrySILabel.right
                        leftMargin: consolidationSwellDataListEntry.labelGap
                    }

                    // Error highlighting
                    Rectangle {
                        visible: (consolidationSwellDataBackground.highlightErrors && (!siTextInput.acceptableInput || !siTextInput.text))
                        opacity: 0.8
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        radius: 5
                    }

                    TextInput {
                        id: siTextInput
                        width: parent.width - 10
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: parent.left 
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        
                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator {
                            bottom: 0
                        }

                        Component.onCompleted: {
                            if(props.inputFileSelected) text = props.swellIndex[index]
                        }

                        onTextChanged: {
                            if(acceptableInput){
                                // Set filled to true
                                filledSI[index] = true
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                                var si = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index){
                                        si = [...si, parseFloat(text)]
                                    }else{
                                        si = [...si, props.swellIndex[i]]
                                    }
                                }
                                props.swellIndex = [...si]
                            }else {
                                // Set filled to false
                                filledSI[index] = false
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                            }
                        }
                        // Placeholder Text
                        property string placeholderText: "--.--"
                        Text {
                            text: siTextInput.placeholderText
                            font.pixelSize: consolidationSwellDataListEntry.fontSize
                            color: "#483434"
                            visible: !siTextInput.text
                        }
                    }
                }
                //////////////////////////////////////                

                // Compression Index ///////////
                Text {
                    id: consolidationSwellDataListEntryCILabel
                    text: "Compression Index: "
                    color: "#fff3e4"
                    font.pixelSize: consolidationSwellDataListEntry.fontSize
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: siTextbox.right
                        leftMargin: consolidationSwellDataListEntry.inputGap
                    }
                }

                Rectangle {
                    id: ciTextbox
                    width: consolidationSwellDataListEntry.inputWidth
                    height: 20
                    color: "#fff3e4"
                    radius: 4
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntryCILabel.right
                        leftMargin: consolidationSwellDataListEntry.labelGap
                    }

                    // Error highlighting
                    Rectangle {
                        visible: (consolidationSwellDataBackground.highlightErrors && (!ciTextInput.acceptableInput || !ciTextInput.text))
                        opacity: 0.8
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        radius: 5
                    }

                    TextInput {
                        id: ciTextInput
                        width: parent.width - 10
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: parent.left 
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        
                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator {
                            bottom: 0
                        }

                        Component.onCompleted: {
                            if(props.inputFileSelected) text = props.compressionIndex[index]
                        }

                        onTextChanged: {
                            if(acceptableInput){
                                // Set filled to true
                                filledCI[index] = true
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                                var ci = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index){
                                        ci = [...ci, parseFloat(text)]
                                    }else{
                                        ci = [...ci, props.compressionIndex[i]]
                                    }
                                }
                                props.compressionIndex = [...ci]
                            }else {
                                // Set filled to false
                                filledCI[index] = false
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                            }
                        }
                        // Placeholder Text
                        property string placeholderText: "--.--"
                        Text {
                            text: ciTextInput.placeholderText
                            font.pixelSize: consolidationSwellDataListEntry.fontSize
                            color: "#483434"
                            visible: !ciTextInput.text
                        }
                    }
                }
                //////////////////////////////////////

                // Max Past Pressure ///////////
                Text {
                    id: consolidationSwellDataListEntryRILabel
                    text: "Max Past Pressure: "
                    color: "#fff3e4"
                    font.pixelSize: consolidationSwellDataListEntry.fontSize
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: ciTextbox.right
                        leftMargin: consolidationSwellDataListEntry.inputGap
                    }
                }

                Rectangle {
                    id: riTextbox
                    clip: true
                    width: consolidationSwellDataListEntry.inputWidth
                    height: 20
                    color: "#fff3e4"
                    radius: 4
                    anchors {
                        verticalCenter: consolidationSwellDataListEntry.verticalCenter
                        left: consolidationSwellDataListEntryRILabel.right
                        leftMargin: consolidationSwellDataListEntry.labelGap
                    }

                    // Error highlighting
                    Rectangle {
                        visible: (consolidationSwellDataBackground.highlightErrors && (!riTextInput.acceptableInput || !riTextInput.text))
                        opacity: 0.8
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        radius: 5
                    }

                    TextInput {
                        id: riTextInput
                        width: text ? text.width : riTextInputPlaceholder.width
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: parent.left 
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        
                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator {
                            bottom: 0
                        }

                        Component.onCompleted: {
                            if(props.inputFileSelected) text = props.recompressionIndex[index]
                        }

                        onTextChanged: {
                            if(acceptableInput){
                                // Set filled to true
                                filledRI[index] = true
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                                // Update Julia
                                var ri = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index){
                                        ri = [...ri, parseFloat(text)]
                                    }else{
                                        ri = [...ri, props.recompressionIndex[i]]
                                    }
                                }
                                props.recompressionIndex = [...ri]
                            }else {
                                // Set filled to false
                                filledRI[index] = false
                                // Force formFilled to update
                                consolidationSwellDataBackground.forceUpdate()
                            }
                        }
                        // Placeholder Text
                        property string placeholderText: "--.--"
                        Text {
                            id: riTextInputPlaceholder
                            text: riTextInput.placeholderText
                            font.pixelSize: consolidationSwellDataListEntry.fontSize
                            color: "#483434"
                            visible: !riTextInput.text
                        }
                    }
                    // Units
                    Text{
                        text: (props.units === 0) ? " Pa" : " tsf"
                        font.pixelSize: consolidationSwellDataListEntry.fontSize
                        color: "#483434"
                        anchors {
                            left: riTextInput.right
                            leftMargin: 1
                            verticalCenter: parent.verticalCenter
                        }
                        visible: riTextInput.text
                    }
                }
                //////////////////////////////////////              
            }
        }
        //////////////////////
    }
    ////////////////////////////////

    // Select Output Location /////
    Rectangle {
        id: selectOutputButton
        color: "#fff3e4"
        radius: 5
        width: selectOutputButtonContainer.width + 10
        height: selectOutputButtonContainer.height + 5
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: consolidationSwellDataContainer.bottom
            topMargin: 20
        }

        // Error highlighting
        Rectangle {
            visible: (consolidationSwellDataBackground.highlightErrors && !consolidationSwellDataBackground.selectedOutputFile)
            opacity: 0.8
            anchors.fill: parent
            color: "transparent"
            border.color: "red"
            border.width: 1
            radius: 5
        }

        Item {
            id: selectOutputButtonContainer
            
            height: selectOutputButtonIcon.height
            width: selectOutputButtonText.width + gap + selectOutputButtonIcon.width

            anchors.centerIn: parent

            property int gap: 10
            property string fileName: ""

            Text{
                id: selectOutputButtonText
                text: (consolidationSwellDataBackground.selectedOutputFile) ? selectOutputButtonContainer.fileName : "Select Output File"
                color: "#483434"
                font.pixelSize: 15
                anchors{
                    left: parent.left
                    verticalCenter: selectOutputButtonIcon.verticalCenter
                }
            }
            Image {
                id: selectOutputButtonIcon
                source: (consolidationSwellDataBackground.selectedOutputFile) ? "../Assets/fileAccept.png" : "../Assets/fileUpload.png"
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
            consolidationSwellDataBackground.selectedOutputFile = true
            props.outputFile = fileUrl.toString()
            // Convert URL to string
            var name = fileUrl.toString()
            // Split URL String at each "/" and extract last piece of data
            var path = name.split("/")
            var fileName = path[path.length - 1]
            // Update fileName property
            selectOutputButtonContainer.fileName = fileName
        }
        onRejected: {
            consolidationSwellDataBackground.selectedOutputFile = false
        }
    }
    ///////////////////////////////

    // Continue Button ///
    Rectangle {
        id: continueButton
        width: parent.width/6
        height: 25
        radius: 12
        color: (parent.formFilled) ? "#fff3e4" : "#9d8f84"
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(consolidationSwellDataBackground.formFilled){
                    // mainLoader.source = "" (switch to next screen when it's designed)
                    props.finishedInput = true
                    Qt.quit()
                }else{
                    consolidationSwellDataBackground.highlightErrors = true
                }
            }
        }
        Text {
            id: continueButtonText
            text: "Continue"
            font.pixelSize: 13
            anchors {
                verticalCenter: continueButtonIcon.verticalCenter
                right: continueButtonIcon.left
                rightMargin: 5
            }
        }
        Image {
            id: continueButtonIcon
            source: "../Assets/continue.png"
            width: 19
            height: 19
            anchors {
                left: parent.horizontalCenter
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }
    }
    //////////////////////
}
