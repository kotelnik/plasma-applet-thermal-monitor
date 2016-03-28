import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n('Temperature')
         icon: Qt.resolvedUrl('../images/thermal-monitor.svg').replace('file://', '')
         source: 'config/ConfigTemperatures.qml'
    }
    ConfigCategory {
         name: i18n('Appearance')
         icon: 'preferences-desktop-color'
         source: 'config/ConfigAppearance.qml'
    }
    ConfigCategory {
         name: i18n('Misc')
         icon: 'preferences-system-other'
         source: 'config/ConfigMisc.qml'
    }
}
