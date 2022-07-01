import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
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
    
    property variant filled: []
    property int forceUpdateInt: 2

    property int formGap: 20

    Component.onCompleted: {
        for(var i = 0; i < props.materials; i++){
            filled.push(false)
            // Initialize elastic modulus values to 0.0
            props.elasticModulus = [...props.elasticModulus, 0.0]
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
        text: "Schmertmann"
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
                height: 20
                radius: 5
                color: "#fff3e4"

                anchors {
                    left: timeLabel.right
                    leftMargin: schmertmannElasticDataForm.labelGap
                    verticalCenter: parent.verticalCenter
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
                    // Change for input handling
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
                        verticalCenter: schemrtmannDataListEntry.verticalCenter
                        left: schemrtmannDataListEntry.left
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
                        verticalCenter: schemrtmannDataListEntry.verticalCenter
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

                    TextInput {
                        id: elasticModInput
                        width: parent.width - 10
                        font.pixelSize: schmertmannElasticDataForm.fontSize
                        color: "#483434"
                        anchors.centerIn: parent

                        selectByMouse: true
                        clip: true
                        validator: DoubleValidator{
                            // must be atleast 1 year
                            bottom: 0
                        }
                        // Change for input handling
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
                            text: elasticModInput.placeholderText
                            font.pixelSize: schmertmannElasticDataForm.fontSize
                            color: "#483434"
                            visible: !elasticModInput.text
                        }
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
                    // mainLoader.source = "" (switch to next screen when it's designed)
                    props.finishedInput = true
                    Qt.quit()
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