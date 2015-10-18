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
    
    property bool initialized: false
    
    // configuration
    property bool fahrenheitEnabled: plasmoid.configuration.fahrenheitEnabled
    property string configuredResources: plasmoid.configuration.resources
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
    
    property double overallWidth: vertical ? itemWidth : temperatureModel.count * itemWidth + (temperatureModel.count-1) * itemMargin
    property double overallHeight: vertical ? temperatureModel.count * itemHeight + (temperatureModel.count-1) * itemMargin : itemHeight
    
    Layout.preferredWidth:  overallWidth
    Layout.preferredHeight: overallHeight
    
    function dbgprint(msg) {
        print('[thermalMonitor] ' + msg)
    }
    
    FontLoader {
        source: '../fonts/fontawesome-webfont-4.3.0.ttf'
    }
    
    Image {
        id: noResourceIcon;

        anchors.centerIn: parent
        
        visible: temperatureModel.count === 0

        height: itemHeight
        width: height
        
        source: '../images/thermal-monitor.svg'
    }

    ListView {
        id: listView
        anchors.fill: parent
        
        orientation: vertical ? ListView.Vertical : ListView.Horizontal
        spacing: itemMargin
        
        model: temperatureModel
        
        delegate: TemperatureItem {}
    }

    /*
     * 
     * One object has these properties: temperature, alias and other
     * 
     */
    ListModel {
        id: temperatureModel
    }
    
    Component.onCompleted: {
        plasmoid.setAction('reloadSources', i18n('Reload Temperature Sources'), 'system-reboot');
        reloadAllSources()
    }
    
    onConfiguredResourcesChanged: {
        dbgprint('configured resources changed')
        if (!initialized) {
            dbgprint('applet not initialized -> no reloading sources')
            return
        }
        reloadAllSources()
    }
    
    function action_reloadSources() {
        reloadAllSources()
    }
    
    function reloadAllSources() {
        
        dbgprint('reloading all sources...')
        
        var resources = ConfigUtils.getResourcesObjectArray()
        
        temperatureModel.clear()
        
        if (!systemmonitorSourcesToAdd) {
            systemmonitorSourcesToAdd = []
        }
        
        systemmonitorSourcesToAdd.length = 0
        systemmonitorDS.connectedSources.length = 0
        udisksDS.connectedSources.length = 0
        udisksDS.cmdSourceBySourceName = {}
        nvidiaDS.connectedSources.length = 0
        
        ModelUtils.initModels(resources, temperatureModel)
        
        for (var i = 0; i < temperatureModel.count; i++) {
            var tempObj = temperatureModel.get(i)
            var source = tempObj.sourceName
            
            if (source === 'group-of-sources') {
                
                dbgprint('adding group: ' + tempObj.alias)
                
                for (var childSource in tempObj.childSourceObjects) {
                    
                    dbgprint('adding source (for group): ' + childSource)
                    
                    addSourceToDs(childSource)
                    
                }
                
            } else {
                
                addSourceToDs(source)
                
            }
        }
        
        ModelUtils.rebuildModelIndexByKey(temperatureModel)
        
        initialized = true
        
        dbgprint('reloadAllSources() DONE')
    }
    
    function addSourceToDs(source) {
        
        if (source.indexOf('udisks/') === 0) {
            
            var diskLabel = source.substring('udisks/'.length)
            var cmdSource = ModelUtils.getUdisksTemperatureCmd(diskLabel)
            udisksDS.cmdSourceBySourceName[cmdSource] = source
            
            dbgprint('adding source: ' + cmdSource)
            
            addToSourcesOfDatasource(udisksDS, cmdSource)
            
        } else if (source.indexOf('nvidia-') === 0 && nvidiaDS.connectedSources.length === 0) {
            
            addToSourcesOfDatasource(nvidiaDS, nvidiaDS.nvidiaSource)
            
        } else {
            
            dbgprint('adding source: ' + source)
            
            if (systemmonitorAvailableSources && systemmonitorAvailableSources.indexOf(source) > -1) {
                dbgprint('adding to connected')
                addToSourcesOfDatasource(systemmonitorDS, source)
            } else {
                dbgprint('adding to sta')
                systemmonitorSourcesToAdd.push(source)
            }
            
        }
        
    }
    
    function addToSourcesOfDatasource(datasource, sourceName) {
        if (systemmonitorDS.connectedSources.indexOf(sourceName) > -1) {
            // already added
            dbgprint('source already added: ' + sourceName)
            return
        }
        systemmonitorDS.connectedSources.push(sourceName)
    }
    
    PlasmaCore.DataSource {
        id: systemmonitorDS
        engine: 'systemmonitor'

        property string lmSensorsStart: 'lmsensors/'
        property string acpiStart: 'acpi/Thermal_Zone/'

        connectedSources: []
        
        onSourceAdded: {
            
            if (source.indexOf(lmSensorsStart) === 0 || source.indexOf(acpiStart) === 0) {
                
                systemmonitorAvailableSources.push(source)
                var staIndex = systemmonitorSourcesToAdd.indexOf(source)
                if (staIndex > -1) {
                    addToSourcesOfDatasource(systemmonitorDS, source)
                    systemmonitorSourcesToAdd.splice(staIndex, 1)
                }
                
            }
            
        }

        onNewData: {
            if (data.value === undefined) {
                return
            }
            ModelUtils.updateTemperatureModel(temperatureModel, sourceName, parseFloat(data.value))
        }
        interval: updateInterval
    }
    
    PlasmaCore.DataSource {
        id: udisksDS
        engine: 'executable'
        
        property variant cmdSourceBySourceName: {}
        
        connectedSources: []
        
        onNewData: {
            
            dbgprint('udisks new data - valid: ' + valid + ', stdout: ' + data.stdout)
            
            if (data['exit code'] > 0) {
                dbgprint('new data error: ' + data.stderr)
                return
            }
            
            var temperature = ModelUtils.getCelsiaFromUdisksStdout(data.stdout)
            ModelUtils.updateTemperatureModel(temperatureModel, cmdSourceBySourceName[sourceName], temperature)
        }
        interval: updateInterval
    }
    
    PlasmaCore.DataSource {
        id: nvidiaDS
        engine: 'executable'
        
        property string nvidiaSource: 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'

        connectedSources: []
        
        onNewData: {
            if (data['exit code'] > 0) {
                return
            }
            
            ModelUtils.updateTemperatureModel(temperatureModel, 'nvidia-smi', parseFloat(data.stdout))
        }
        interval: updateInterval
    }
    
    Timer {
        interval: updateInterval
        repeat: true
        running: true
        onTriggered: {
            ModelUtils.computeVirtuals(temperatureModel)
        }
    }
    
}
