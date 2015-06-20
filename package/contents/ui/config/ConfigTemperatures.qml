import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../../code/config-utils.js" as ConfigUtils
import "../../code/model-utils.js" as ModelUtils

Item {
    id: resourcesConfigPage
    
    property double tableWidth: 500

    property string cfg_resources
    property alias cfg_warningTemperature: warningTemperatureSpinBox.value
    property alias cfg_meltdownTemperature: meltdownTemperatureSpinBox.value
    
    property var comboboxModel: []
    
    ListModel {
        id: resourcesModel
    }
    
    Component.onCompleted: {
        
        print('sources: ' + systemmonitorDS.sources.length)
        
        systemmonitorDS.sources.forEach(function (source) {
            if (source.indexOf('lmsensors/') === 0 || source.indexOf('acpi/Thermal_Zone/') === 0) {
                comboboxModel.push(source)
                print('added to combo model: ' + source)
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
                    model: comboboxModel
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
                        
                        resourcesModel.append({
                            sourceName: sourceCombo.currentText,
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
            
            headerVisible: false
            
            Text {
                text: i18n('Add resources by clicking "+" button.')
                color: theme.textColor
                anchors.centerIn: parent
                visible: resourcesModel.count === 0
            }
            
            TableViewColumn {
                role: 'sourceName'
                title: 'Source'
                width: tableWidth * 0.5
            }
            
            TableViewColumn {
                role: 'alias'
                title: 'Alias'
                width: tableWidth * 0.2
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
            iconName: 'list-add'
            Layout.preferredWidth: 100
            Layout.columnSpan: 2
            onClicked: {
                addResourceDialog.open()
                aliasTextfield.text = ''
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
        engine: "systemmonitor"
    }
    
    PlasmaCore.DataSource {
        id: hddtempDS
        engine: "executable"
        
        connectedSources: [ 'netcat localhost 7634' ]
        
        onNewData: {
            hddtempDS.connectedSources.length = 0
            
            if (data['exit code'] > 0) {
                return
            }
            
            print('New data incomming. Source: ' + sourceName + ', data: ' + data.stdout);
            var hddtempObjects = ModelUtils.parseHddtemp(data.stdout)
            hddtempObjects.forEach(function (hddtempObj) {
                var source = hddtempObj.sourceName
                if (comboboxModel.indexOf(source) > -1 || isNaN(hddtempObj.temperature)) {
                    return
                }
                comboboxModel.push(source)
                print('added to combo model: ' + source)
            })
            
        }
        interval: 1000
    }
    
    PlasmaCore.DataSource {
        id: nvidiaDS
        engine: "executable"
        
        connectedSources: [ 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader' ]
        
        onNewData: {
            nvidiaDS.connectedSources.length = 0
            
            if (data['exit code'] > 0) {
                return
            }
            
            comboboxModel.push('nvidia-smi')
        }
        interval: 1000
    }
    
}
