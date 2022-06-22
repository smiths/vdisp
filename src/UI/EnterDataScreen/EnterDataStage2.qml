import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Shapes 1.3
import org.julialang 1.0

Rectangle {
    id: materialPropertiesFormBackground

    function isFilled(){
        // Replace when page is ready
        return false
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property string nextScreen: "EnterDataStage3.qml"

    property int topFormMargin: 30 + (55-30) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
    property int materialListMargin: 30 + (55-30) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
    property int materialListEntryHeight: 40

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }

    // Title /////////////
    Text {
        id: enterDataTitle
        text: "Enter Material Properties"
        font.pixelSize: 32
        color: "#FFF3E4"
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top 
            topMargin: 20
        }
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
                if(enterDataFormBackground.formFilled)
                    enterDataStackView.push(enterDataFormBackground.nextScreen)
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

    // Top Form //////////
    Rectangle {
        id: topForm
        width: 3*inputWidth + 2*inputGap + 3*labelGap + 2*sideGap + sgLabel.width + vrLabel.width + wcLabel.width + addBtn.width
        height: 40
        radius: 6
        color: "transparent"
        border.color: "#fff3e4"
        border.width: 2
        anchors {
            top: enterDataTitle.bottom
            topMargin: parent.topFormMargin
            horizontalCenter: parent.horizontalCenter
        }

        function isReady() {
            return sgTextInput.text  && sgTextInput.acceptableInput && vrTextInput.text && vrTextInput.acceptableInput
        }
        property bool ready: isReady()

        property int inputWidth: 100 + (130-100) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int inputGap: 10 + (30-10) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int labelGap: 3 + (8-3) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int sideGap: 8 + (20-8) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
        property int textSize: 15 + (18-15) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)

        // Specific Gravity //////
        Text {
            id: sgLabel
            text: "Specific Gravity: "
            font.pixelSize: topForm.textSize
            color: "#fff3e4"
            anchors {
                verticalCenter: sgTextbox.verticalCenter
                left: parent.left 
                leftMargin: parent.sideGap
            }
        }
        Rectangle {
            id: sgTextbox
            width: parent.inputWidth
            height: 20
            color: "#fff3e4"
            radius: 4
            anchors {
                verticalCenter: parent.verticalCenter
                left: sgLabel.right
                leftMargin: parent.labelGap
            }

            TextInput {
                id: sgTextInput
                width: parent.width - 10
                font.pixelSize: topForm.textSize
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                
                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    // must be positive ?
                    bottom: 0
                }
                // Change for input handling
                onTextChanged: {
                    // DO SMTHN
                }
                // Placeholder Text
                property string placeholderText: "Enter Value..."
                Text {
                    text: sgTextInput.placeholderText
                    font.pixelSize: topForm.textSize
                    color: "#483434"
                    visible: !sgTextInput.text
                }
            }
        }
        //////////////////////////

        // Void Ratio ////////////
        Text {
            id: vrLabel
            text: "Void Ratio: "
            color: "#fff3e4"
            font.pixelSize: topForm.textSize
            anchors {
                left: sgTextbox.right
                leftMargin: parent.inputGap
                verticalCenter: parent.verticalCenter
            }
        }
        Rectangle {
            id: vrTextbox
            width: parent.inputWidth
            height: 20
            color: "#fff3e4"
            radius: 4
            anchors {
                verticalCenter: parent.verticalCenter
                left: vrLabel.right
                leftMargin: parent.labelGap
            }

            TextInput {
                id: vrTextInput
                width: parent.width - 10
                font.pixelSize: topForm.textSize
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                
                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    // must be positive ?
                    bottom: 0
                }
                // Change for input handling
                onTextChanged: {
                    // DO SMTHN
                }
                // Placeholder Text
                property string placeholderText: "Enter Value..."
                Text {
                    text: vrTextInput.placeholderText
                    font.pixelSize: topForm.textSize
                    color: "#483434"
                    visible: !vrTextInput.text
                }
            }
        }
        //////////////////////////

        // Water Content /////////
        Text{
            id: wcLabel
            text: "Water Content: "
            color: "#fff3e4"
            font.pixelSize: topForm.textSize
            anchors {
                left: vrTextbox.right
                leftMargin: parent.inputGap
                verticalCenter: parent.verticalCenter
            }
        }
        Slider {
            id: wcSlider
            value: 50
            from: 0
            to: 100
            stepSize: 0.5

            onValueChanged: {
                // DO SMTHN
            }
            
            width: topForm.inputWidth

            anchors {
                left: wcLabel.right
                leftMargin: parent.labelGap
                verticalCenter: parent.verticalCenter
            }

            // Object that depicts background of slider
            background: Rectangle {
                width: wcSlider.availableWidth
                height: 3
                radius: 2
                color: "#fff3e4"
                anchors.verticalCenter: parent.verticalCenter
            }

            handle: Rectangle {
                color: "#fff3e4"
                implicitWidth: 24
                implicitHeight: 24
                radius: width/2
                anchors.verticalCenter: parent.verticalCenter
                x: wcSlider.visualPosition * (wcSlider.availableWidth - width)
                
                Text {
                    anchors.centerIn: parent
                    color: "#483434"
                    font.pixelSize: topForm.textSize - 5
                    text: wcSlider.value
                }
            }
        }

        // Add button
        Image {
            id: addBtn
            width: 20 + (25-20) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            height: width
            source: "../Assets/add.png"
            anchors {
                left: wcSlider.right
                leftMargin: topForm.labelGap - 5
                rightMargin: topForm.sideGap
                verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    //if(topForm.ready && materialsModel.count < materialsList.maxMaterials){
                    if(topForm.ready) {
                        materialsModel.append({"materialName": "Material " + (materialsModel.count + 1), "specificGravity": parseFloat(sgTextInput.text), "voidRatio": parseFloat(vrTextInput.text), "waterContent": parseInt(wcSlider.value)})
                        sgTextInput.text = ""
                        vrTextInput.text = ""
                    }
                }
            }
        }
        //////////////////////////
    }

    // Material List ////////
    ListModel {
        id: materialsModel
    }

    ListView {
        id: materialsList
        model: materialsModel
        
        property int maxMaterials: 7
        property bool overcrowded: vdispWindow.isMinHeight() && model.count > 7
        property int maximumHeight: materialPropertiesFormBackground.materialListEntryHeight * maxMaterials
        
        interactive: (model.count <= maxMaterials) ? false : true  // Allow scrolling when list becomes too large
        implicitWidth: parent.width
        implicitHeight: Math.min(materialPropertiesFormBackground.materialListEntryHeight * materialsList.count, maximumHeight)
        clip: true
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            topMargin: (overcrowded) ? 20 : 0 
        }

        // Just for viewing bounds during development
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "red"
            border.width: 1
        }

        delegate: Item {
            id: materialEntry
            width: parent.width
            height: materialPropertiesFormBackground.materialListEntryHeight

            property int inputWidth: 50 + (90-50) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int inputGap: 10 + (30-10) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int labelGap: 3 + (8-3) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int sideGap: 8 + (20-8) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int textSize: 18 + (21-18) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            
            Item {
                implicitWidth: 2*materialEntry.sideGap + 3*materialEntry.inputGap + 3*materialEntry.labelGap + 3*materialEntry.inputWidth + sgLabelEntry.width + vrLabelEntry.width + wcLabelEntry.width + entryName.width
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                // Just for viewing bounds during development
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "green"
                    border.width: 1
                }
                TextInput {
                    id: entryName
                    text: materialName
                    font.pixelSize: materialEntry.textSize
                    color: "#fff3e4"
                    maximumLength: 13
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: materialEntry.sideGap
                    }
                    selectByMouse: true
                    clip: true
                    onTextChanged: {
                        // update name of material
                    }
                }

                Text {
                    id: sgLabelEntry
                    text: "Specific Gravity: "
                    color: "#fff3e4"
                    font.pixelSize: materialEntry.textSize
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: entryName.right
                        leftMargin: materialEntry.inputGap
                    }
                }
                Rectangle {
                    id: sgEntryTextbox
                    color: "#fff3e4"
                    width: materialEntry.inputWidth
                    height: 20
                    radius: 4
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: sgLabelEntry.right
                        leftMargin: materialEntry.labelGap
                    }
                    Text {
                        text: specificGravity
                        color: "#483434"
                        font.pixelSize: materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }

                Text {
                    id: vrLabelEntry
                    text: "Void Ratio: "
                    color: "#fff3e4"
                    font.pixelSize: materialEntry.textSize
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: sgEntryTextbox.right
                        leftMargin: materialEntry.inputGap
                    }
                }
                Rectangle {
                    id: vrEntryTextbox
                    color: "#fff3e4"
                    width: materialEntry.inputWidth
                    height: 20
                    radius: 4
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: vrLabelEntry.right
                        leftMargin: materialEntry.labelGap
                    }
                    Text {
                        text: voidRatio
                        color: "#483434"
                        font.pixelSize: materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }

                Text {
                    id: wcLabelEntry
                    text: "Water Content: "
                    color: "#fff3e4"
                    font.pixelSize: materialEntry.textSize
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: vrEntryTextbox.right
                        leftMargin: materialEntry.inputGap
                    }
                }
                Rectangle {
                    id: wcEntryTextbox
                    color: "#fff3e4"
                    width: materialEntry.inputWidth
                    height: 20
                    radius: 4
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: wcLabelEntry.right
                        leftMargin: materialEntry.labelGap
                    }
                    Text {
                        text: waterContent
                        color: "#483434"
                        font.pixelSize: materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
    /////////////////////////
    ////////////////////////
}