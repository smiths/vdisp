import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: schmertmannElasticDataBackground

    function formIsFilled() {
        for(var i = 0; i < props.materials; i++){
            if(!filled[i]) return false
        }
        return true
    }
    function isFilled(){
        return forceUpdateInt === 2 && timeTextInput.text && timeTextInput.acceptableInput && formIsFilled()
    }
    function forceUpdate(){
        forceUpdateInt = 1
        forceUpdateInt = 2
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property string nextScreen: "../OutputScreen/SchmertmannOutputScreen.qml" 
    property bool highlightErrors: false

    property variant filled: []
    property int forceUpdateInt: 2

    property int formGap: 20

    Component.onCompleted: {
        if(!props.inputFileSelected || props.modelChanged){
            for(var i = 0; i < props.materials; i++){
                filled.push(false)
                // Initialize elastic modulus values to 0.0
                props.elasticModulus = [...props.elasticModulus, 0.0]
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
        id: schmertmannElasticTitle
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
        id: schmertmannElasticSubtitle
        text: "Schmertmann Elastic"
        font.pixelSize: 15
        color: "#fff3e4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: schmertmannElasticTitle.bottom 
            topMargin: 10
        }
    }
    ///////////////////////

    // Form //////////////
    Item {
        id: schmertmannElasticDataForm

        property int inputWidth: 100 + 20 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int inputHeight: 20 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
        property int labelGap: 5 + 2 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int inputGap: 10 + 5 * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int fontSize: 15 + 3 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

        width: timeContainer.width
        height: timeContainer.height + schmertmannElasticDataBackground.formGap + schmertmannElasticDataList.height

        anchors.centerIn: parent

        // Time After Construction ///
        Item {
            id: timeContainer

            width: timeLabel.width + schmertmannElasticDataForm.inputGap + schmertmannElasticDataForm.inputWidth
            height: timeTextBox.height

            Text {
                id: timeLabel
                text: "Time After Construction (yrs): "
                color: "#fff3e4"
                font.pixelSize: schmertmannElasticDataForm.fontSize
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            Rectangle{
                id: timeTextBox
                width: schmertmannElasticDataForm.inputWidth
                height: schmertmannElasticDataForm.inputHeight
                radius: 5
                color: "#fff3e4"

                anchors {
                    left: timeLabel.right
                    leftMargin: schmertmannElasticDataForm.labelGap
                    verticalCenter: parent.verticalCenter
                }

                // Error highlighting
                Rectangle {
                    visible: (schmertmannElasticDataBackground.highlightErrors && (!timeTextInput.acceptableInput || !timeTextInput.text))
                    opacity: 0.8
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "red"
                    border.width: 1
                    radius: 5
                }

                TextInput {
                    id: timeTextInput
                    width: parent.width - 10
                    font.pixelSize: schmertmannElasticDataForm.fontSize
                    color: "#483434"
                    anchors.centerIn: parent

                    selectByMouse: true
                    clip: true
                    validator: IntValidator{
                        // must be atleast 1 year
                        bottom: 1
                    }
                    
                    Component.onCompleted: {
                        if(props.inputFileSelected && !props.modelChanged) text = props.timeAfterConstruction
                    }

                    onTextChanged: {
                        if(acceptableInput) props.timeAfterConstruction = parseInt(text)
                    }
                    // Placeholder Text
                    property string placeholderText: "Enter Time..."
                    Text {
                        text: timeTextInput.placeholderText
                        font.pixelSize: schmertmannElasticDataForm.fontSize
                        color: "#483434"
                        visible: !timeTextInput.text
                    }
                }
            }
        }
        //////////////////////////////

        // Items /////////////////////
        Repeater {
            id: schmertmannElasticDataList
            model: props.materials

            property int rowGap: 5 + 5 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)

            width: schmertmannElasticDataListEntry.width
            height: props.materials * (schmertmannElasticDataForm.inputHeight+rowGap)

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: timeContainer.bottom
                topMargin: schmertmannElasticDataBackground.formGap
            }

            delegate: Item {
                id: schmertmannElasticDataListEntry

                width: materialLabel.width + elasticModLabel.width + schmertmannElasticDataForm.inputGap + schmertmannElasticDataForm.inputWidth + schmertmannElasticDataForm.labelGap
                height: schmertmannElasticDataForm.inputHeight

                anchors.horizontalCenter: parent.horizontalCenter

                y: timeContainer.height + schmertmannElasticDataBackground.formGap + (height + schmertmannElasticDataList.rowGap) * index

                // Material Name //////////////
                Text{
                    id: materialLabel
                    text: props.materialNames[index] + ":"
                    color: "#fff3e4"
                    font.pixelSize: schmertmannElasticDataForm.fontSize
                    anchors {
                        verticalCenter: schemrtmannElasticDataListEntry.verticalCenter
                        left: schemrtmannElasticDataListEntry.left
                    }
                }
                ////////////////////////////////

                // Elastic Modulus ////////////
                Text {
                    id: elasticModLabel
                    text: "Elastic Modulus: "
                    color: "#fff3e4"
                    font.pixelSize: schmertmannElasticDataForm.fontSize
                    anchors {
                        verticalCenter: schemrtmannElasticDataListEntry.verticalCenter
                        left: materialLabel.right
                        leftMargin: schmertmannElasticDataForm.inputGap
                    }
                }
                Rectangle{
                    id: elasticModTextBox
                    width: schmertmannElasticDataForm.inputWidth
                    height: schmertmannElasticDataForm.inputHeight
                    radius: 5
                    color: "#fff3e4"

                    anchors {
                        left: elasticModLabel.right
                        leftMargin: schmertmannElasticDataForm.labelGap
                        verticalCenter: elasticModLabel.verticalCenter
                    }

                    // Error highlighting
                    Rectangle {
                        visible: (schmertmannElasticDataBackground.highlightErrors && (!elasticModInput.acceptableInput || !elasticModInput.text))
                        opacity: 0.8
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        radius: 5
                    }

                    TextInput {
                        id: elasticModInput
                        width: text ? text.width : elasticModInputPlaceholder.width
                        font.pixelSize: schmertmannElasticDataForm.fontSize
                        color: "#483434"
                        anchors{
                            left: parent.left
                            leftMargin: 5
                        }

                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator{
                            // must be atleast 1 year
                            bottom: 0
                        }

                        Component.onCompleted: {
                            if(props.inputFileSelected && !props.modelChanged) text = props.elasticModulus[index]
                        }

                        onTextChanged: {
                            if(acceptableInput){
                                // Update form filled
                                schmertmannElasticDataBackground.filled[index] = true
                                // Force update in isFilled
                                schmertmannElasticDataBackground.forceUpdate()
                                // Update Julia
                                var em = []
                                for(var i = 0; i < props.materials; i++){
                                    if(i === index)
                                        em = [...em, parseFloat(text)]
                                    else
                                        em = [...em, props.elasticModulus[i]]
                                }
                                props.elasticModulus = [...em]
                            }else{
                                // Update form filled
                                schmertmannElasticDataBackground.filled[index] = false
                                // Force update in isFilled
                                schmertmannElasticDataBackground.forceUpdate()
                            }
                        }
                        // Placeholder Text
                        property string placeholderText: "Enter Value..."
                        Text {
                            id: elasticModInputPlaceholder
                            text: elasticModInput.placeholderText
                            font.pixelSize: schmertmannElasticDataForm.fontSize
                            color: "#483434"
                            visible: !elasticModInput.text
                        }
                    }
                    // Units
                    Text{
                        text: (props.units === 0) ? " KPa" : " tsf"
                        font.pixelSize: schmertmannElasticDataForm.fontSize
                        color: "#483434"
                        anchors {
                            left: elasticModInput.right
                            leftMargin: 1
                        }
                        visible: elasticModInput.text
                    }
                }
                ////////////////////////////////
            }
        }
        //////////////////////////////
    }
    //////////////////////

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
                if(schmertmannElasticDataBackground.formFilled){
                    mainLoader.source = schmertmannElasticDataBackground.nextScreen
                    /*
                       Since we can't directly call a function from Julia (until the bug in CxxWrap.jl and QML.jl is fixed),
                    I'm forced to create an Observable() variable in Julia and pass it into props. When this variable updates
                    to true, I will execute the Julia subroutine from the Julia code. 
                       If user comes back from output screen and updates input, props.createOutputData will already be true, 
                    thus we have to change it to false, then back to true, just to force an update on the Julia side
                    */
                    props.createOutputData = false
                    props.createOutputData = true
                }else{
                    schmertmannElasticDataBackground.highlightErrors = true
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