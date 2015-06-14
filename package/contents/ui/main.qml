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

Item {
    id: main
    
    Text {
        text: 'Thermal Monitor'
    }
    
    PlasmaCore.DataSource {
        id: dataSource
        engine: "systemmonitor"

        property string lmSensorsStart: 'lmsensors/'
        property string acpiStart: 'acpi/Thermal_Zone/'

        connectedSources: []
        
        onSourceAdded: {
            print('source added: ' + source)
            if (source.indexOf(lmSensorsStart) === 0 || source.indexOf(acpiStart) === 0) {
                print('  adding')
                connectedSources.push(source)
            }
        }

        onNewData: {
            if (data.value === undefined) {
                return
            }
            print('New data incomming. Source: ' + data.value + ', sourceName: ' + sourceName);
        }
        interval: 1000 * plasmoid.configuration.updateInterval
    }
    
}
