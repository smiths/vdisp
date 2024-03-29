import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import org.julialang 1.0

Rectangle {
    id: materialPropertiesFormBackground

    function isFilled(){
        // Check if each material name is nonempty
        for(var i = 0; i < props.materials; i++){
            if(props.materialNames[i]){
                if(props.materialNames[i].length <= 0){
                    return false
                }
            }
        }
        // As long as we have one material, the page is ready
        return materialsModel.count > 0
    }

    // Is this form filled correctly (allowed to go next)
    property bool formFilled: isFilled()
    property bool highlightErrors: false
    property int latestMaterialIndex: 1
    property int maxMaterialCount: props.MAX_MATERIAL_COUNT
    property string nextScreen: "EnterDataStage3.qml"

    property int topFormMargin: 30 + (55-30) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
    property int materialListMargin: 30 + (55-30) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
    property int materialListEntryHeight: 40

    radius: 20
    color: "#6B4F4F"
    anchors {
        fill: parent
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
        focus: true
        color: (parent.formFilled) ? "#fff3e4" : "#9d8f84"
        border.color: (activeFocus) ? "#483434" : "transparent"

        KeyNavigation.up: addBtn
        KeyNavigation.tab: sgTextInput

        Keys.onEnterPressed: {
            // Same as onClicked
            if(materialPropertiesFormBackground.formFilled)
                    enterDataStackView.push(materialPropertiesFormBackground.nextScreen)
        }
        Keys.onReturnPressed: {
            // Same as onClicked
            if(materialPropertiesFormBackground.formFilled)
                    enterDataStackView.push(materialPropertiesFormBackground.nextScreen)
        }

        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(materialPropertiesFormBackground.formFilled)
                    enterDataStackView.push(materialPropertiesFormBackground.nextScreen)
            }
        }
        Text {
            id: continueButtonText
            text: "Continue"
            color: "#483434"
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
            return sgTextInput.text  && sgTextInput.acceptableInput && vrTextInput.text && vrTextInput.acceptableInput && wcTextInput.text && wcTextInput.acceptableInput
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
            // Error highlighting
            Rectangle {
                visible: (materialPropertiesFormBackground.highlightErrors && (!sgTextInput.acceptableInput || !sgTextInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
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

                Component.onCompleted: {
                    forceActiveFocus()
                }

                KeyNavigation.tab: vrTextInput
                KeyNavigation.right: vrTextInput
                
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
            // Error highlighting
            Rectangle {
                visible: (materialPropertiesFormBackground.highlightErrors && (!vrTextInput.acceptableInput || !vrTextInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
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

                KeyNavigation.tab: wcTextInput
                KeyNavigation.right: wcTextInput
                KeyNavigation.left: sgTextInput
                
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
        Rectangle {
            id: wcTextbox
            width: parent.inputWidth
            height: 20
            color: "#fff3e4"
            radius: 4
            anchors {
                verticalCenter: parent.verticalCenter
                left: wcLabel.right
                leftMargin: parent.labelGap
            }
            // Error highlighting
            Rectangle {
                visible: (materialPropertiesFormBackground.highlightErrors && (!wcTextInput.acceptableInput || !wcTextInput.text))
                opacity: 0.8
                anchors.fill: parent
                color: "transparent"
                border.color: "red"
                border.width: 1
                radius: 5
            }
            TextInput {
                id: wcTextInput
                width: text ? text.width : wcTextInputPlaceholder.width
                font.pixelSize: topForm.textSize
                color: "#483434"
                anchors {
                    left: parent.left 
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                
                KeyNavigation.tab: addBtn
                KeyNavigation.right: addBtn
                KeyNavigation.left: vrTextInput

                selectByMouse: true
                clip: true
                validator: DoubleValidator{
                    bottom: 0
                    top: 100
                }
                // Placeholder Text
                property string placeholderText: "Enter Value..."
                Text {
                    id: wcTextInputPlaceholder
                    text: wcTextInput.placeholderText
                    font.pixelSize: topForm.textSize
                    color: "#483434"
                    visible: !wcTextInput.text
                }
            }
            // Units
            Text{
                text: "%"
                font.pixelSize: 18
                color: "#483434"
                anchors {
                    left: wcTextInput.right
                    leftMargin: 1
                }
                visible: wcTextInput.text
            }
        }
        /////////////////////////

        // Add button
        Image {
            id: addBtn
            focus: true
            
            width: 20 + (25-20) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            height: width
            
            property string folder: vdispWindow.getImageFolder(width, 16, 128)
            property string fileExt: activeFocus ? "-selected" : ""
            source: "../Assets/" + folder + "/add" + fileExt + ".png"
            
            anchors {
                left: wcTextbox.right
                leftMargin: topForm.labelGap
                rightMargin: topForm.sideGap
                verticalCenter: parent.verticalCenter
            }

            KeyNavigation.left: wcTextInput
            KeyNavigation.tab: sgTextInput
            KeyNavigation.down: continueButton

            Keys.onReturnPressed: {
                // Same as onClicked
                if(topForm.ready && materialsModel.count < materialsList.maxMaterials){
                    // Don't highlight errors until user tries to enter another material
                    materialPropertiesFormBackground.highlightErrors = false
                    
                    // Latest material name
                    var name = qsTr("Material " + (materialPropertiesFormBackground.latestMaterialIndex))
                    materialPropertiesFormBackground.latestMaterialIndex += 1

                    // Update UI
                    materialsModel.append({"materialName": name, "specificGravity": parseFloat(sgTextInput.text), "voidRatio": parseFloat(vrTextInput.text), "waterContent": parseFloat(wcTextInput.text)})
                    // Update Julia lists
                    props.materials = props.materials+1
                    props.materialCountChanged = true
                    props.materialNames = [...props.materialNames,name]
                    props.specificGravity =[...props.specificGravity, parseFloat(sgTextInput.text)]
                    props.voidRatio = [...props.voidRatio, parseFloat(vrTextInput.text)]
                    props.waterContent = [...props.waterContent, parseFloat(wcTextInput.text)]
                    // Clear fields
                    sgTextInput.text = ""
                    vrTextInput.text = ""
                    wcTextInput.text = ""
                }else{
                    materialPropertiesFormBackground.highlightErrors = true
                }
            }
            Keys.onEnterPressed: {
                // Same as onClicked
                if(topForm.ready && materialsModel.count < materialsList.maxMaterials){
                    // Don't highlight errors until user tries to enter another material
                    materialPropertiesFormBackground.highlightErrors = false
                    
                    // Latest material name
                    var name = qsTr("Material " + (materialPropertiesFormBackground.latestMaterialIndex))
                    materialPropertiesFormBackground.latestMaterialIndex += 1

                    // Update UI
                    materialsModel.append({"materialName": name, "specificGravity": parseFloat(sgTextInput.text), "voidRatio": parseFloat(vrTextInput.text), "waterContent": parseFloat(wcTextInput.text)})
                    // Update Julia lists
                    props.materials = props.materials+1
                    props.materialCountChanged = true
                    props.materialNames = [...props.materialNames,name]
                    props.specificGravity =[...props.specificGravity, parseFloat(sgTextInput.text)]
                    props.voidRatio = [...props.voidRatio, parseFloat(vrTextInput.text)]
                    props.waterContent = [...props.waterContent, parseFloat(wcTextInput.text)]
                    // Clear fields
                    sgTextInput.text = ""
                    vrTextInput.text = ""
                    wcTextInput.text = ""
                }else{
                    materialPropertiesFormBackground.highlightErrors = true
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(topForm.ready && materialsModel.count < materialsList.maxMaterials){
                        // Don't highlight errors until user tries to enter another material
                        materialPropertiesFormBackground.highlightErrors = false
                        
                        // Latest material name
                        var name = qsTr("Material " + (materialPropertiesFormBackground.latestMaterialIndex))
                        materialPropertiesFormBackground.latestMaterialIndex += 1

                        // Update UI
                        materialsModel.append({"materialName": name, "specificGravity": parseFloat(sgTextInput.text), "voidRatio": parseFloat(vrTextInput.text), "waterContent": parseFloat(wcTextInput.text)})
                        // Update Julia lists
                        props.materials = props.materials+1
                        props.materialCountChanged = true
                        props.materialNames = [...props.materialNames,name]
                        props.specificGravity =[...props.specificGravity, parseFloat(sgTextInput.text)]
                        props.voidRatio = [...props.voidRatio, parseFloat(vrTextInput.text)]
                        props.waterContent = [...props.waterContent, parseFloat(wcTextInput.text)]
                        // Clear fields
                        sgTextInput.text = ""
                        vrTextInput.text = ""
                        wcTextInput.text = ""
                    }else{
                        // Only highlight error for unfilled forms, not for material count
                        if(materialsModel.count < materialsList.maxMaterials) materialPropertiesFormBackground.highlightErrors = true
                        else tooManyMaterialsDialog.open() 
                    }
                }
            }
        }
        //////////////////////////
    }
    ////////////////////////

    // Material List ////////
    ListModel {
        id: materialsModel
    }

    ListView {
        id: materialsList
        model: materialsModel
        
        property int maxMaterials: materialPropertiesFormBackground.maxMaterialCount
        property bool overcrowded: vdispWindow.isMinHeight() && model.count > maxMaterials
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

        // If we went to a different screen and came back, reload previous entries (or if there is autofill)
        Component.onCompleted: {
            for(var i = 0; i < props.materials; i++){
                materialsModel.append({"materialName": props.materialNames[i], "specificGravity": props.specificGravity[i], "voidRatio": props.voidRatio[i], "waterContent": props.waterContent[i]})
            }
        }

        delegate: Item {
            id: materialEntry
            
            width: (!deleted) ? parent.width : undefined
            height: materialPropertiesFormBackground.materialListEntryHeight

            property bool deleted: false
            property int inputWidth: 50 + (90-50) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int inputGap: 10 + (30-10) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int labelGap: 3 + (8-3) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int sideGap: 8 + (20-8) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            property int textSize: 18 + (21-18) * (vdispWindow.width-vdispWindow.minimumWidth)/(vdispWindow.maximumWidth-vdispWindow.minimumWidth)
            
            // Entry ////////////////
            Item {
                implicitWidth: 2*materialEntry.sideGap + 4*materialEntry.inputGap + 4*materialEntry.labelGap + 3*materialEntry.inputWidth + sgLabelEntry.width + vrLabelEntry.width + wcLabelEntry.width + entryNameTextbox.width + deleteEntryBtn.width
                height: parent.height
                
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Material Name //
                Rectangle {
                    id: entryNameTextbox
                    color: "#fff3e4"
                    width: entryName.width + 10
                    height: 20
                    radius: 4
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: materialEntry.sideGap
                    }
                    TextInput {
                        id: entryName
                        text: materialName
                        font.pixelSize: materialEntry.textSize
                        color: "#483434"
                        anchors.centerIn: parent
                        maximumLength: 12
                        selectByMouse: true
                        clip: true
                        onTextChanged: {
                            // update Julia lists
                            materialsModel.get(index).materialName = text
                            var nameList = []
                            for(var i = 0; i < materialsModel.count; i++){
                                nameList.push(materialsModel.get(i).materialName)
                            }
                            props.materialNames = [...nameList]
                        }
                    }
                }
                //////////////////

                // SG ////////////
                Text {
                    id: sgLabelEntry
                    text: "Specific Gravity: "
                    color: "#fff3e4"
                    font.pixelSize: materialEntry.textSize
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: entryNameTextbox.right
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
                        text: specificGravity.toFixed(2)
                        color: "#483434"
                        font.pixelSize: (parseFloat(specificGravity) > 999) ? materialEntry.textSize - 3 : materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }
                //////////////////

                // VR ////////////
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
                        text: voidRatio.toFixed(2)
                        color: "#483434"
                        font.pixelSize: materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }
                //////////////////

                // WC ////////////
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
                        text: waterContent.toFixed(1) + "%"
                        color: "#483434"
                        font.pixelSize: (parseFloat(waterContent) === 100) ? materialEntry.textSize - 3 : (parseFloat(waterContent) >= 10.0) ? materialEntry.textSize - 2 : materialEntry.textSize
                        anchors.centerIn: parent
                    }
                }
                //////////////////

                // DELETE ////////
                Image {
                    id: deleteEntryBtn
                    
                    width: 15 + 10 * (vdispWindow.height-vdispWindow.minimumHeight)/(vdispWindow.maximumHeight-vdispWindow.minimumHeight)
                    height: width
                    
                    property string folder: vdispWindow.getImageFolder(width, 16, 64)
                    source: "../Assets/" + folder + "/delete.png"
                    
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: wcEntryTextbox.right
                        leftMargin: materialEntry.inputGap
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Delete from list
                            materialsModel.remove(index)
                            // Update Julia variables
                            props.materials = props.materials - 1
                            props.materialCountChanged = true
                            
                            var nameList = []
                            for(var i = 0; i < materialsModel.count; i++){
                                nameList.push(materialsModel.get(i).materialName)
                            }
                            props.materialNames = [...nameList]

                            var sgList = []
                            for(var i = 0; i < materialsModel.count; i++){
                                sgList.push(materialsModel.get(i).specificGravity)
                            }
                            props.specificGravity = [...sgList]

                            var vrList = []
                            for(var i = 0; i < materialsModel.count; i++){
                                vrList.push(materialsModel.get(i).voidRatio)
                            }
                            props.voidRatio = [...vrList]

                            var wcList = []
                            for(var i = 0; i < materialsModel.count; i++){
                                wcList.push(materialsModel.get(i).waterContent)
                            }
                            props.waterContent = [...wcList]

                            materialEntry.deleted = true
                        }
                    }
                }
                /////////////////
            }
            ///////////////////////
        }
    }
    /////////////////////////

    //TOO MANY MATERIALS POPUP ////
    Popup {
        id: tooManyMaterialsDialog
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape // | Popup.CloseOnPressOutsideParent

        width: popupPadding + tooManyMaterialsDialogText.width 
        height: popupPadding + tooManyMaterialsDialogTitle.height + tooManyMaterialsDialogText.height + tooManyMaterialsDialogButton.height + 2*tooManyMaterialsDialog.gap

        anchors.centerIn: parent

        property int gap: 10
        property int popupPadding: 40

        background: Rectangle {
            color: "#483434"
            radius: 10
        }

        contentItem: Item {
            id: tooManyMaterialsDialogContainer
            
            width: tooManyMaterialsDialogText.width 
            height: tooManyMaterialsDialogTitle.height + tooManyMaterialsDialogText.height + tooManyMaterialsDialogButton.height + 2*tooManyMaterialsDialog.gap
            
            anchors.centerIn: parent
            
            // Title
            Text{
                id: tooManyMaterialsDialogTitle
                font.pixelSize: 25
                color: "#fff3e4"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                text: "Warning: Too Many Materials"
            }

            // Message
            Text{
                id: tooManyMaterialsDialogText
                text: "Material count exceeded MAX_MATERIAL_COUNT (" +  materialPropertiesFormBackground.maxMaterialCount + ")"
                
                font.pixelSize: 18
                color: "#fff3e4"
                
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: tooManyMaterialsDialogTitle.bottom
                    topMargin: tooManyMaterialsDialog.gap
                }
            }

            // Close Button
            Rectangle {
                id: tooManyMaterialsDialogButton
                width: 100
                height: 20
                radius: 5
                color: "#fff3e4"

                Text{
                    text: "Ok"
                    font.pixelSize: 15
                    color: "#483434"
                    anchors.centerIn: parent
                }

                anchors{
                    top: tooManyMaterialsDialogText.bottom
                    topMargin: tooManyMaterialsDialog.gap
                    horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: tooManyMaterialsDialog.close()
                }
            }
        }
    }
    ///////////////////////////////
}