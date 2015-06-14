import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    
    property alias cfg_rowCount: rowCountSpinBox.value
    
    property bool cfg_fahrenheitEnabled

    onCfg_fahrenheitEnabledChanged: {
        if (cfg_fahrenheitEnabled) {
            temperatureTypeGroup.current = temperatureFahrenheit
        } else {
            temperatureTypeGroup.current = temperatureCelsius
        }
    }
    
    Component.onCompleted: {
        cfg_fahrenheitEnabledChanged()
    }
    
    ExclusiveGroup {
        id: temperatureTypeGroup
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        Label {
            text: i18n('Update interval:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: updateIntervalSpinBox
            decimals: 1
            stepSize: 0.1
            minimumValue: 0.1
            suffix: i18nc('Abbreviation for seconds', 's')
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Row count:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: rowCountSpinBox
            decimals: 1
            stepSize: 1
            minimumValue: 1
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n("Temperature:")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: temperatureCelsius
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°C")
            onCheckedChanged: if (checked) cfg_fahrenheitEnabled = false
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureFahrenheit
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°F")
            onCheckedChanged: if (checked) cfg_fahrenheitEnabled = true
        }

    }
    
}
