import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import "../../code/config-utils.js" as ConfigUtils
import "../../code/model-utils.js" as ModelUtils

Item {
    id: resourcesConfigPage
    
    property double tableWidth: parent.width

    property string cfg_resources
    property alias cfg_warningTemperature: warningTemperatureSpinBox.value
    property alias cfg_meltdownTemperature: meltdownTemperatureSpinBox.value
    
    property var preparedSystemMonitorSources: []
    
    ListModel {
        id: resourcesModel
    }
    
    ListModel {
        id: comboboxModel
    }
    
    ListModel {
        id: checkboxesSourcesModel
    }
    
    Component.onCompleted: {
        
        systemmonitorDS.sources.forEach(function (source) {
            
            if ((source.indexOf('lmsensors/') === 0 || source.indexOf('acpi/Thermal_Zone/') === 0)
                && !source.match(/\/fan[0-9]*$/) ) {
                
                comboboxModel.append({
                    text: source,
                    val: source
                })
                
                print('source to combo: ' + source)
            }
        })
        
        var resources = ConfigUtils.getResourcesObjectArray()
        resources.forEach(function (resourceObj) {
            resourcesModel.append(resourceObj)
        })
    }
    
    function reloadComboboxModel(temperatureObj) {
        
        temperatureObj = temperatureObj || {}
        var childSourceObjects = temperatureObj.childSourceObjects || {}
        var childSourceObjectsEmpty = !temperatureObj.childSourceObjects
        
        checkboxesSourcesModel.clear()
        sourceCombo.currentIndex = 0
        
        print('sourceName to select: ' + temperatureObj.sourceName)
        
        addResourceDialog.sourceTypeSwitch = temperatureObj.sourceName === 'group-of-sources' ? 1 : 0
        addResourceDialog.setVirtualSelected()
        
        addResourceDialog.groupSources.length = 0
        
        for (var i = 0; i < comboboxModel.count; i++) {
            var source = comboboxModel.get(i).val
            
            if (source === temperatureObj.sourceName) {
                sourceCombo.currentIndex = i
            }
            
            var checkboxChecked = childSourceObjectsEmpty || (source in childSourceObjects)
            checkboxesSourcesModel.append({
                text: source,
                val: source,
                checkboxChecked: checkboxChecked
            })
            if (checkboxChecked) {
                addResourceDialog.groupSources.push(source)
            }
        }
        
    }
    
    function resourcesModelChanged() {
        var newResourcesArray = []
        for (var i = 0; i < resourcesModel.count; i++) {
            var obj = resourcesModel.get(i)
            newResourcesArray.push({
                sourceName: obj.sourceName,
                alias: obj.alias,
                overrideLimitTemperatures: obj.overrideLimitTemperatures,
                warningTemperature: obj.warningTemperature,
                meltdownTemperature: obj.meltdownTemperature,
                virtual: obj.virtual,
                childSourceObjects: obj.childSourceObjects
            })
        }
        cfg_resources = JSON.stringify(newResourcesArray)
        print('resources: ' + cfg_resources)
    }
    
    
    function fillAddResourceDialogAndOpen(temperatureObj, editResourceIndex) {
        
        // set dialog title
        addResourceDialog.addResource = temperatureObj === null
        addResourceDialog.editResourceIndex = editResourceIndex
        
        temperatureObj = temperatureObj || {
            alias: '',
            overrideLimitTemperatures: false,
            meltdownTemperature: 90,
            warningTemperature: 70
        }
        
        // set combobox
        reloadComboboxModel(temperatureObj)
        
        // alias
        aliasTextfield.text = temperatureObj.alias
        showAlias.checked = !!temperatureObj.alias
        
        // temperature overrides
        overrideLimitTemperatures.checked = temperatureObj.overrideLimitTemperatures
        warningTemperatureItem.value = temperatureObj.warningTemperature
        meltdownTemperatureItem.value = temperatureObj.meltdownTemperature
        
        // open dialog
        addResourceDialog.open()
        
    }
    
    
    Dialog {
        id: addResourceDialog
        
        property bool addResource: true
        property int editResourceIndex: -1
        
        title: addResource ? i18n('Add Resource') : i18n('Edit Resource')
        
        width: tableWidth
        
        property int tableIndex: 0
        property double fieldHeight: addResourceDialog.height / 5 - 3
        
        property bool virtualSelected: true
        
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        
        property int sourceTypeSwitch: 0
        
        property var groupSources: []
            
        ExclusiveGroup {
            id: sourceTypeGroup
        }
        
        onSourceTypeSwitchChanged: {
            switch (sourceTypeSwitch) {
            case 0:
                sourceTypeGroup.current = singleSourceTypeRadio;
                break;
            case 1:
                sourceTypeGroup.current = multipleSourceTypeRadio;
                break;
            default:
            }
            setVirtualSelected()
        }
        
        function setVirtualSelected() {
            virtualSelected = sourceTypeSwitch === 1
            print('SET VIRTUAL SELECTED: ' + virtualSelected)
        }
        
        onAccepted: {
            if (!showAlias.checked) {
                aliasTextfield.text = ''
            } else if (!aliasTextfield.text) {
                aliasTextfield.text = '<UNKNOWN>'
            }
            
            var childSourceObjects = {}
            groupSources.forEach(function (groupSource) {
                print ('adding source to group: ' + groupSource)
                childSourceObjects[groupSource] = {
                    temperature: 0
                }
            })
            
            var newObject = {
                sourceName: virtualSelected ? 'group-of-sources' : comboboxModel.get(sourceCombo.currentIndex).val,
                alias: aliasTextfield.text,
                overrideLimitTemperatures: overrideLimitTemperatures.checked,
                warningTemperature: warningTemperatureItem.value,
                meltdownTemperature: meltdownTemperatureItem.value,
                virtual: virtualSelected,
                childSourceObjects: childSourceObjects
            }
            
            if (addResourceDialog.addResource) {
                resourcesModel.append(newObject)
            } else {
                resourcesModel.set(addResourceDialog.editResourceIndex, newObject)
            }
            
            
            resourcesModelChanged()
            addResourceDialog.close()
        }
        
        GridLayout {
            columns: 2
            
            RadioButton {
                id: singleSourceTypeRadio
                exclusiveGroup: sourceTypeGroup
                text: i18n("Source")
                onCheckedChanged: {
                    if (checked) {
                        addResourceDialog.sourceTypeSwitch = 0
                    }
                    addResourceDialog.setVirtualSelected()
                }
                checked: true
            }
            ComboBox {
                id: sourceCombo
                Layout.preferredWidth: tableWidth/2
                model: comboboxModel
                enabled: !addResourceDialog.virtualSelected
            }
            
            RadioButton {
                id: multipleSourceTypeRadio
                exclusiveGroup: sourceTypeGroup
                text: i18n("Group of sources")
                onCheckedChanged: {
                    if (checked) {
                        addResourceDialog.sourceTypeSwitch = 1
                    }
                    addResourceDialog.setVirtualSelected()
                }
                Layout.alignment: Qt.AlignTop
            }
            ListView {
                id: checkboxesSourcesListView
                model: checkboxesSourcesModel
                delegate: CheckBox {
                    text: val
                    checked: checkboxChecked
                    onCheckedChanged: {
                        if (checked) {
                            if (addResourceDialog.groupSources.indexOf(val) === -1) {
                                addResourceDialog.groupSources.push(val)
                            }
                        } else {
                            var idx = addResourceDialog.groupSources.indexOf(val)
                            if (idx !== -1) {
                                addResourceDialog.groupSources.splice(idx, 1)
                            }
                        }
                    }
                }
                enabled: addResourceDialog.virtualSelected
                Layout.preferredWidth: tableWidth/2
                Layout.preferredHeight: contentHeight
            }
            
            Item {
                Layout.columnSpan: 2
                width: 2
                height: 5
            }
            
            Label {
                text: i18n("NOTE: Group of sources shows the highest temperature of chosen sources.")
                Layout.columnSpan: 2
                enabled: addResourceDialog.virtualSelected
            }
            
            Item {
                Layout.columnSpan: 2
                width: 2
                height: 10
            }
            
            CheckBox {
                id: showAlias
                text: i18n("Show alias:")
                checked: true
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: aliasTextfield
                Layout.preferredWidth: tableWidth/2
                enabled: showAlias.checked
            }
            
            Item {
                Layout.columnSpan: 2
                width: 2
                height: 10
            }
            
            CheckBox {
                id: overrideLimitTemperatures
                text: i18n("Override limit temperatures")
                Layout.columnSpan: 2
                checked: false
            }
            
            Label {
                text: i18n('Warning temperature [°C]:')
                Layout.alignment: Qt.AlignRight
            }
            SpinBox {
                id: warningTemperatureItem
                stepSize: 10
                minimumValue: 10
                enabled: overrideLimitTemperatures.checked
            }
            
            Label {
                text: i18n('Meltdown temperature [°C]:')
                Layout.alignment: Qt.AlignRight
            }
            SpinBox {
                id: meltdownTemperatureItem
                stepSize: 10
                minimumValue: 10
                enabled: overrideLimitTemperatures.checked
            }
            
        }
    }
    
    GridLayout {
        columns: 2
        
        Label {
            text: i18n('Plasmoid version: ') + '1.2.8'
            Layout.alignment: Qt.AlignRight
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Resources')
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }
        
        Item {
            width: 2
            height: 2
        }
        
        TableView {
            
            headerVisible: true
            
            Label {
                text: i18n('Add resources by clicking "+" button.')
                anchors.centerIn: parent
                visible: resourcesModel.count === 0
            }
            
            TableViewColumn {
                role: 'sourceName'
                title: i18n('Source')
                width: tableWidth * 0.6
                delegate: MouseArea {
                    anchors.fill: parent
                    Label {
                        text: styleData.value
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                    }
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        fillAddResourceDialogAndOpen(resourcesModel.get(styleData.row), styleData.row)
                    }
                }
            }
            
            TableViewColumn {
                role: 'alias'
                title: i18n('Alias')
                width: tableWidth * 0.15
                delegate: MouseArea {
                    anchors.fill: parent
                    Label {
                        text: styleData.value
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                    }
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        fillAddResourceDialogAndOpen(resourcesModel.get(styleData.row), styleData.row)
                    }
                }
            }
            
            TableViewColumn {
                title: i18n('Action')
                width: tableWidth * 0.25 - 4
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 3
                        rowSpacing: 0
                        
                        Button {
                            iconName: 'go-up'
                            Layout.fillHeight: true
                            onClicked: {
                                resourcesModel.move(styleData.row, styleData.row - 1, 1)
                                resourcesModelChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.fillHeight: true
                            onClicked: {
                                resourcesModel.move(styleData.row, styleData.row + 1, 1)
                                resourcesModelChanged()
                            }
                            enabled: styleData.row < resourcesModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                resourcesModel.remove(styleData.row)
                                resourcesModelChanged()
                            }
                        }
                    }
                }
            }
            
            model: resourcesModel
            
            Layout.preferredHeight: 150
            Layout.preferredWidth: tableWidth
            Layout.columnSpan: 2
        }
        Button {
            id: buttonAddResource
            iconName: 'list-add'
            Layout.preferredWidth: 100
            Layout.columnSpan: 2
            onClicked: {
                fillAddResourceDialogAndOpen(null, -1)
            }
        }
        
        Item {
            width: 2
            height: 20
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Notifications')
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }
        
        Item {
            width: 2
            height: 2
        }
        
        Label {
            text: i18n('Warning temperature [°C]:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: warningTemperatureSpinBox
            stepSize: 1
            minimumValue: 10
            maximumValue: 200
        }
        
        Label {
            text: i18n('Meltdown temperature [°C]:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: meltdownTemperatureSpinBox
            stepSize: 1
            minimumValue: 10
            maximumValue: 200
        }
        
    }
    
    PlasmaCore.DataSource {
        id: systemmonitorDS
        engine: 'systemmonitor'
    }
    
    PlasmaCore.DataSource {
        id: udisksDS
        engine: 'executable'
        
        connectedSources: [ ModelUtils.UDISKS_DEVICES_CMD ]
        
        onNewData: {
            connectedSources.length = 0
            
            if (data['exit code'] > 0) {
                print('New data incomming. Source: ' + sourceName + ', ERROR: ' + data.stderr);
                return
            }
            
            print('New data incomming. Source: ' + sourceName + ', data: ' + data.stdout);
            
            var pathsToCheck = ModelUtils.parseUdisksPaths(data.stdout)
            pathsToCheck.forEach(function (pathObj) {
                var cmd = ModelUtils.UDISKS_VIRTUAL_PATH_PREFIX + pathObj.name
                comboboxModel.append({
                    text: cmd,
                    val: cmd
                })
            })
            
        }
        
        interval: 500
    }
    
    PlasmaCore.DataSource {
        id: nvidiaDS
        engine: 'executable'
        
        connectedSources: [ 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader' ]
        
        property bool prepared: false
        
        onNewData: {
            nvidiaDS.connectedSources.length = 0
            
            if (data['exit code'] > 0) {
                prepared = true
                return
            }
            
            comboboxModel.append({
                text: 'nvidia-smi',
                val: 'nvidia-smi'
            })
            
            prepared = true
        }
        
        interval: 500
    }
    
    PlasmaCore.DataSource {
        id: atiDS
        engine: 'executable'
        
        connectedSources: [ 'aticonfig --od-gettemperature' ]
        
        property bool prepared: false
        
        onNewData: {
            atiDS.connectedSources.length = 0
            
            if (data['exit code'] > 0) {
                prepared = true
                return
            }
            
            comboboxModel.append({
                text: 'aticonfig',
                val: 'aticonfig'
            })
            
            prepared = true
        }
        
        interval: 500
    }
    
}
