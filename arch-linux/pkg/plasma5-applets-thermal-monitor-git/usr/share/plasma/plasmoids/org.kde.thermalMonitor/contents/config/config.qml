import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n('General')
         icon: 'preferences-system-windows'
         source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
         name: i18n('Misc')
         icon: 'preferences-system-windows'
         source: 'config/ConfigMisc.qml'
    }
}
