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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/temperature-utils.js" as TemperatureUtils

Item {
    id: temperatureItem

    width: itemWidth
    height: itemHeight

    //
    // all temperatures defaults to Celsius
    // Fahrenheit is being computed while putting int string for display
    //
    property bool warningState: temperature >= warningTemperature
    property bool meltdownState: temperature >= meltdownTemperature
    property bool isOff: temperature === 0

    PlasmaComponents.Label {
        id: stateIcon

        anchors.bottom: parent.bottom
        anchors.bottomMargin: iconBottomMargin
        anchors.right: parent.right

        color: meltdownState ? '#FFFF0000' : warningState ? '#FFFF8000' : '#FF66FF66'
        font.pixelSize: iconFontSize
        font.pointSize: -1
        font.family: 'FontAwesome'
        verticalAlignment: Text.AlignBottom

        text: meltdownState ? '\uf06d' : (warningState ? '\uf071' : '\uf05d')
        visible: meltdownState || warningState
    }

    Item {
        id: labels
        anchors.fill: parent

        PlasmaComponents.Label {
            id: aliasText

            font.pixelSize: aliasFontSize
            font.pointSize: -1
            verticalAlignment: Text.AlignTop

            text: alias
        }

        PlasmaComponents.Label {
            id: temperatureText

            anchors.bottom: aliasText.text === '' ? undefined : parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: temperatureRightMargin
            anchors.verticalCenter: aliasText.text === '' ? parent.verticalCenter : undefined

            font.pixelSize: temperatureFontSize * (isOff ? 0.7 : 1)
            font.pointSize: -1
            verticalAlignment: Text.AlignBottom

            opacity: isOff ? 0.7 : 1

            text: isOff ? i18n('OFF') : TemperatureUtils.getTemperatureStr(temperature, temperatureUnit)
        }
    }

    DropShadow {
        anchors.fill: labels
        radius: enableLabelDropShadow ? 3 : 0
        spread: 0.8
        fast: true
        color: theme.backgroundColor
        source: labels
        visible: enableLabelDropShadow
    }

}
