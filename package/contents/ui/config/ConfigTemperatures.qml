import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import "../../code/config-utils.js" as ConfigUtils
import "../../code/model-utils.js" as ModelUtils

Item {
    id: resourcesConfigPage
    
    property double tableWidth: 550

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
    
    function resourcesModelChanged() {
        var newResourcesArray = []
        for (var i = 0; i < resourcesModel.count; i++) {
            var obj = resourcesModel.get(i)
            newResourcesArray.push({
                sourceName: obj.sourceName,
                alias: obj.alias
            })
        }
        cfg_resources = JSON.stringify(newResourcesArray)
        print('resources: ' + cfg_resources)
    }
    
    
    Dialog {
        id: addResourceDialog
        title: "Add Resource"
        
        width: tableWidth
        height: 150
        
        property int tableIndex: 0
        property double fieldHeight: addResourceDialog.height / 3 - 3
        
        contentItem: Item {
            
            GridLayout {
                columns: 1
                
                ComboBox {
                    id: sourceCombo
                    Layout.preferredWidth: addResourceDialog.width
                    Layout.preferredHeight: addResourceDialog.fieldHeight
                    model: ListModel {}
                }
                
                TextField {
                    id: aliasTextfield
                    placeholderText: 'Alias'
                    Layout.preferredWidth: addResourceDialog.width
                    Layout.preferredHeight: addResourceDialog.fieldHeight
                }
                
                Button {
                    text: 'Add'
                    width: addResourceDialog.width
                    Layout.preferredHeight: addResourceDialog.fieldHeight
                    onClicked: {
                        
                        if (!aliasTextfield.text) {
                            aliasTextfield.text = 'Insert alias'
                            return
                        }
                        
                        resourcesModel.append({
                            sourceName: comboboxModel.get(sourceCombo.currentIndex).val,
                            alias: aliasTextfield.text
                        })
                        resourcesModelChanged()
                        addResourceDialog.close()
                    }
                }
            }
        }
    }
    
    GridLayout {
        columns: 2
        
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
            
            Text {
                text: i18n('Add resources by clicking "+" button.')
                color: theme.textColor
                anchors.centerIn: parent
                visible: resourcesModel.count === 0
            }
            
            TableViewColumn {
                role: 'sourceName'
                title: 'Source'
                width: tableWidth * 0.6
            }
            
            TableViewColumn {
                role: 'alias'
                title: 'Alias'
                width: tableWidth * 0.1
            }
            
            TableViewColumn {
                title: 'Action'
                width: tableWidth * 0.3 - 4
                
                delegate: Item {
                    
                    GridLayout {
                        columns: 3
                        
                        Button {
                            iconName: 'go-up'
                            Layout.preferredHeight: 23
                            onClicked: {
                                resourcesModel.move(styleData.row, styleData.row - 1, 1)
                                resourcesModelChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.preferredHeight: 23
                            onClicked: {
                                resourcesModel.move(styleData.row, styleData.row + 1, 1)
                                resourcesModelChanged()
                            }
                            enabled: styleData.row < resourcesModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.preferredHeight: 23
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
                addResourceDialog.open()
                aliasTextfield.text = ''
                
                // remove already selected sources
                for (var i = 0; i < resourcesModel.count; i++) {
                    var obj = resourcesModel.get(i)
                    var sourceToRemove = obj.sourceName
                    for (var j = 0; j < comboboxModel.count; j++) {
                        var comboItem = comboboxModel.get(j)
                        if (comboItem.text === sourceToRemove) {
                            comboboxModel.remove(j)
                            break
                        }
                    }
                }
                
                // set combobox model
                sourceCombo.model = comboboxModel
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
            decimals: 1
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
            decimals: 1
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
    
}
