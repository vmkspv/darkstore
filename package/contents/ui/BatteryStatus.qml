/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.private.battery

Text {
    id: batteryItem

    property bool hasBattery: batteryInfo.hasBatteries
    property int batteryPercent: hasBattery ? batteryInfo.percent : 100
    property bool isCharging: batteryInfo.state === BatteryControlModel.Charging
    property int clockSize: 96

    BatteryControlModel {
        id: batteryInfo
    }

    text: {
        if (!hasBattery) return ""
        if (isCharging) return i18n("Charging %1%", batteryPercent)
        return i18n("Battery %1%", batteryPercent)
    }
    horizontalAlignment: Text.AlignHCenter
    color: "#80ffffff"
    font.pixelSize: Math.round(clockSize * 0.25)
    font.bold: true
}