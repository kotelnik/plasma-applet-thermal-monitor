/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/model-utils.js" as ModelUtils
import "../code/config-utils.js" as ConfigUtils

Item {
    id: main
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    // configuration
    property bool fahrenheitEnabled: plasmoid.configuration.fahrenheitEnabled
    property var configuredResources: plasmoid.configuration.resources
    property int updateInterval: 1000 * plasmoid.configuration.updateInterval
    
    property int itemMargin: 5
    property double itemWidth:  parent === null ? 0 : vertical ? parent.width : parent.height
    property double itemHeight: itemWidth
    property double fontPointSize: itemHeight * 0.2
    
    property color warningColor: Qt.tint(theme.textColor, '#60FF0000')
    property var textFontFamily: theme.defaultFont.family
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    property double aliasFontSize: itemHeight * plasmoid.configuration.aliasFontSize * 0.01
    property double temperatureFontSize: itemHeight * plasmoid.configuration.temperatureFontSize * 0.01
    property double iconFontSize: itemHeight * plasmoid.configuration.iconFontSize * 0.01
    property double temperatureRightMargin: itemHeight * plasmoid.configuration.temperatureRightMargin * 0.01
    property double iconBottomMargin: itemHeight * plasmoid.configuration.iconBottomMargin * 0.01
    
    property var systemmonitorAvailableSources: systemmonitorDS.sources
    property var systemmonitorSourcesToAdd: []
    
    property double overallWidth: vertical ? itemWidth : visualModel.count * itemWidth + (visualModel.count-1) * itemMargin
    property double overallHeight: vertical ? visualModel.count * itemHeight + (visualModel.count-1) * itemMargin : itemHeight
    
    Layout.preferredWidth:  overallWidth
    Layout.preferredHeight: overallHeight

    FontLoader {
        source: 'plasmapackage:/fonts/fontawesome-webfont-4.3.0.ttf'
    }
    
//     GridView {
//         id: listView
//         anchors.fill: parent
//         cellWidth: itemWidth
//         cellHeight: itemHeight
//         
//         model: visualModel
//         
//         delegate: TemperatureItem {}
//     }

    ListView {
        id: listView
        anchors.fill: parent
        
        orientation: vertical ? ListView.Vertical : ListView.Horizontal
        spacing: itemMargin
        
        model: visualModel
        
        delegate: TemperatureItem {}
    }

    /*
     * 
     * One object has these properties: temperature, deviceName
     * 
     */
    ListModel {
        id: temperatureModel
    }
    
    PlasmaCore.SortFilterModel {
        id: visualModel
//         filterRole: 'doNotShow'
//         filterRegExp: 'false'
        sourceModel: temperatureModel
    }
    
    Component.onCompleted: {
        reloadAllSources()
    }
    
    onConfiguredResourcesChanged: {
        reloadAllSources()
    }
    
    onVerticalChanged: {
        refreshView()
    }
    
    function reloadAllSources() {
        var resources = ConfigUtils.getResourcesObjectArray()
        
        temperatureModel.clear()
        
        if (!systemmonitorSourcesToAdd) {
            systemmonitorSourcesToAdd = []
        }
        
        systemmonitorSourcesToAdd.length = 0
        systemmonitorDS.connectedSources.length = 0
        hddtempDS.connectedSources.length = 0
        nvidiaDS.connectedSources.length = 0
        
        ModelUtils.initModels(resources, temperatureModel)
        
        for (var i = 0; i < temperatureModel.count; i++) {
            var tempObj = temperatureModel.get(i)
            var source = tempObj.sourceName
            
            if (source.indexOf(systemmonitorDS.lmSensorsStart) === 0 || source.indexOf(systemmonitorDS.acpiStart) === 0) {
                
                print('adding source: ' + source)
                
                if (systemmonitorAvailableSources && systemmonitorAvailableSources.indexOf(source) > -1) {
                    print('adding to connected')
                    systemmonitorDS.connectedSources.push(source)
                } else {
                    print('adding to sta')
                    systemmonitorSourcesToAdd.push(source)
                }
                
            } else if (source.indexOf('hddtemp-') === 0 && hddtempDS.connectedSources.length === 0) {
                
                print('adding source: ' + hddtempDS.netcatSource)
                
                hddtempDS.connectedSources.push(hddtempDS.netcatSource)
                
            } else if (source.indexOf('nvidia-') === 0 && nvidiaDS.connectedSources.length === 0) {
                
                nvidiaDS.connectedSources.push(nvidiaDS.nvidiaSource)
                
            }
        }
    }
    
    PlasmaCore.DataSource {
        id: systemmonitorDS
        engine: "systemmonitor"

        property string lmSensorsStart: 'lmsensors/'
        property string acpiStart: 'acpi/Thermal_Zone/'

        connectedSources: []
        
        onSourceAdded: {
            print('source added: ' + source)
            if (source.indexOf(lmSensorsStart) === 0 || source.indexOf(acpiStart) === 0) {
                print('  adding to available')
                systemmonitorAvailableSources.push(source)
                var staIndex = systemmonitorSourcesToAdd.indexOf(source)
                if (staIndex > -1) {
                    systemmonitorDS.connectedSources.push(source)
                    systemmonitorSourcesToAdd.splice(staIndex, 1)
                }
            }
        }

        onNewData: {
            if (data.value === undefined) {
                return
            }
            print('New data incomming. Source: ' + sourceName + ', data: ' + data.value);
            ModelUtils.updateTemperatureModel(temperatureModel, sourceName, parseFloat(data.value))
        }
        interval: updateInterval
    }
    
    PlasmaCore.DataSource {
        id: hddtempDS
        engine: "executable"
        
        property string netcatSource: 'netcat localhost 7634'

        connectedSources: []
        
        onNewData: {
            if (data['exit code'] > 0) {
                return
            }
            print('New data incomming. Source: ' + sourceName + ', data: ' + data.stdout);
            var hddtempObjects = ModelUtils.parseHddtemp(data.stdout)
            hddtempObjects.forEach(function (hddtempObj) {
                ModelUtils.updateTemperatureModel(temperatureModel, hddtempObj.sourceName, hddtempObj.temperature)
            })
            
            //ModelUtils.computeVirtuals(temperatureModel)
        }
        interval: updateInterval
    }
    
    PlasmaCore.DataSource {
        id: nvidiaDS
        engine: "executable"
        
        property string nvidiaSource: 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'

        connectedSources: []
        
        onNewData: {
            if (data['exit code'] > 0) {
                return
            }
            print('New data incomming. Source: ' + sourceName + ', data: ' + data.stdout);
            ModelUtils.updateTemperatureModel(temperatureModel, 'nvidia-smi', parseFloat(data.stdout))
        }
        interval: updateInterval
    }
    
}
