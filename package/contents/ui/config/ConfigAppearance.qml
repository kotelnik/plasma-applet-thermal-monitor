import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    
    property alias cfg_aliasFontSize: aliasFontSize.value
    property alias cfg_temperatureFontSize: temperatureFontSize.value
    property alias cfg_iconFontSize: iconFontSize.value
    property alias cfg_temperatureRightMargin: temperatureRightMargin.value
    property alias cfg_iconBottomMargin: iconBottomMargin.value
    property alias cfg_enableLabelDropShadow: enableLabelDropShadow.checked
    
    GridLayout {
        columns: 2
        anchors.left: parent.left
        anchors.right: parent.right
        
        Label {
            text: i18n('Alias font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: aliasFontSize
            stepSize: 1
            minimumValue: 2
            maximumValue: 100
            Layout.fillWidth: true
        }
        
        Label {
            text: i18n('Temperature font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: temperatureFontSize
            stepSize: 1
            minimumValue: 2
            maximumValue: 100
            Layout.fillWidth: true
        }
        
        Label {
            text: i18n('Icon font size:')
            Layout.alignment: Qt.AlignRight
        }
        Slider {
            id: iconFontSize
            stepSize: 1
            minimumValue: 2
            maximumValue: 100
            Layout.fillWidth: true
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
            Layout.fillWidth: true
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
            Layout.fillWidth: true
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: enableLabelDropShadow
            Layout.columnSpan: 2
            text: i18n('Enable label drop shadow')
        }
    }
    
}
