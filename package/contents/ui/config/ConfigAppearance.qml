import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_aliasFontSize: aliasFontSize.value
    property alias cfg_temperatureFontSize: temperatureFontSize.value
    property alias cfg_iconFontSize: iconFontSize.value
    property alias cfg_temperatureRightMargin: temperatureRightMargin.value
    property alias cfg_iconBottomMargin: iconBottomMargin.value
    
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        Label {
            text: i18n('Alias font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: aliasFontSize
            stepSize: 1
            minimumValue: 1
            maximumValue: 100
            Layout.preferredWidth: 300
        }
        
        Label {
            text: i18n('Temperature font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: temperatureFontSize
            stepSize: 1
            minimumValue: 1
            maximumValue: 100
            Layout.preferredWidth: 300
        }
        
        Label {
            text: i18n('Icon font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: iconFontSize
            stepSize: 1
            minimumValue: 1
            maximumValue: 100
            Layout.preferredWidth: 300
        }

        Label {
            text: i18n('Temperature right margin:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: temperatureRightMargin
            stepSize: 1
            minimumValue: 0
            maximumValue: 80
            Layout.preferredWidth: 300
        }
        
        Label {
            text: i18n('Notification icon bottom margin:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: iconBottomMargin
            stepSize: 1
            minimumValue: 0
            maximumValue: 100
            Layout.preferredWidth: 300
        }
    }
    
}
