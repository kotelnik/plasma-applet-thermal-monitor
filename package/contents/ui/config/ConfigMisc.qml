import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    
    property string cfg_temperatureUnit

    onCfg_temperatureUnitChanged: {

        if (cfg_temperatureUnit == "°C") {
            temperatureTypeGroup.current = temperatureCelsius
        }
        else if (cfg_temperatureUnit == "°F") {
            temperatureTypeGroup.current = temperatureFahrenheit
        }
        else {
            temperatureTypeGroup.current = temperatureKelvin
        }
    }


    Component.onCompleted: {
        cfg_temperatureUnitChanged()
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
            text: i18n("Temperature:")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: temperatureCelsius
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°C")
            onCheckedChanged: if (checked) cfg_temperatureUnit = "°C"
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
            onCheckedChanged: if (checked) cfg_temperatureUnit = "°F"
        }
	Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureKelvin
            exclusiveGroup: temperatureTypeGroup
            text: i18n("K")
            onCheckedChanged: if (checked) cfg_temperatureUnit = "K"
        }

    }

}
