import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_updateInterval: updateIntervalSpinBox.value

    property int cfg_temperatureUnit

    onCfg_temperatureUnitChanged: {
        switch (cfg_temperatureUnit) {
        case 0:
            temperatureTypeGroup.current = temperatureTypeRadioCelsius;
            break;
        case 1:
            temperatureTypeGroup.current = temperatureTypeRadioFahrenheit;
            break;
        case 2:
            temperatureTypeGroup.current = temperatureTypeRadioKelvin;
            break;
        default:
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
            id: temperatureTypeRadioCelsius
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°C")
            onCheckedChanged: if (checked) cfg_temperatureUnit = 0
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureTypeRadioFahrenheit
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°F")
            onCheckedChanged: if (checked) cfg_temperatureUnit = 1
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureTypeRadioKelvin
            exclusiveGroup: temperatureTypeGroup
            text: i18n("K")
            onCheckedChanged: if (checked) cfg_temperatureUnit = 2
        }

    }

}
