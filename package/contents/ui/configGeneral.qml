/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery

SimpleKCM {
    id: generalPage

    property alias cfg_overlayOpacity: opacitySlider.value
    property alias cfg_showClock: showClock.checked
    property alias cfg_clockSize: clockSizeCombo.value
    property alias cfg_showBattery: showBattery.checked
    property alias cfg_targetScreenName: screenCombo.currentValue
    property alias cfg_countdownDuration: countdownSpinner.value
    property alias cfg_useDoubleClick: useDoubleClick.checked
    property alias cfg_enableQuickPeek: enableQuickPeek.checked
    property alias cfg_enableDND: enableDND.checked
    property alias cfg_muteOnOverlay: muteOnOverlay.checked
    property var screenModel: []

    BatteryControlModel {
        id: batteryInfo
    }

    Component.onCompleted: {
        updateScreenModel()
    }

    function updateScreenModel() {
        screenModel = []
        var builtInPatterns = ["eDP", "LVDS", "DSI", "PANEL", "INTERNAL", "IDP"]

        for (var i = 0; i < Qt.application.screens.length; i++) {
            var screen = Qt.application.screens[i]
            var isBuiltIn = false
            var name = screen.name.toUpperCase()

            for (var p = 0; p < builtInPatterns.length; p++) {
                if (name.indexOf(builtInPatterns[p]) >= 0) {
                    isBuiltIn = true
                    break
                }
            }

            var displayName = screen.name + " (" + screen.width + "x" + screen.height + ")"

            screenModel.push({
                display: displayName,
                value: screen.name,
                isBuiltIn: isBuiltIn
            })
        }

        screenModel.sort(function(a, b) {
            if (a.isBuiltIn && !b.isBuiltIn) return -1
            if (!a.isBuiltIn && b.isBuiltIn) return 1
            return 0
        })

        screenCombo.model = screenModel

        var currentValue = plasmoid.configuration.targetScreenName || ""
        var foundIndex = -1

        for (var j = 0; j < screenModel.length; j++) {
            if (screenModel[j].value === currentValue) {
                foundIndex = j
                break
            }
        }

        if (foundIndex === -1) {
            for (var k = 0; k < screenModel.length; k++) {
                if (screenModel[k].isBuiltIn) {
                    foundIndex = k
                    break
                }
            }

            if (foundIndex === -1) {
                for (var m = 0; m < Qt.application.screens.length; m++) {
                    var s = Qt.application.screens[m]
                    if (s.virtualX === 0 && s.virtualY === 0) {
                        for (var n = 0; n < screenModel.length; n++) {
                            if (screenModel[n].value === s.name) {
                                foundIndex = n
                                break
                            }
                        }
                        if (foundIndex !== -1) break
                    }
                }
            }

            if (foundIndex === -1 && screenModel.length > 0) {
                foundIndex = 0
            }

            if (foundIndex >= 0) {
                screenCombo.currentIndex = foundIndex
                plasmoid.configuration.targetScreenName = screenModel[foundIndex].value
            }
        } else {
            screenCombo.currentIndex = foundIndex
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Kirigami.FormLayout {
            wideMode: true

            Item { implicitHeight: Kirigami.Units.largeSpacing }

            ColumnLayout {
                Kirigami.FormData.isSection: true

                Kirigami.Heading {
                    text: i18n("Appearance")
                    level: 2
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                }

                Label {
                    text: i18n("Configure how the overlay looks")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Label {
                        text: i18n("Opacity:")
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Slider {
                        id: opacitySlider
                        Layout.fillWidth: true
                        from: 0.7
                        to: 1.0
                        stepSize: 0.05
                        value: plasmoid.configuration.overlayOpacity
                    }

                    Label {
                        text: Math.round(opacitySlider.value * 100) + "%"
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Label {
                    text: i18n("Adjust transparency of the overlay")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                CheckBox {
                    id: showClock
                    text: i18n("Show moving clock")
                    onCheckedChanged: {
                        if (!checked) {
                            showBattery.checked = false
                        }
                    }
                }

                Label {
                    text: i18n("Display current time on the overlay")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    leftPadding: showClock.indicator.width + showClock.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    enabled: showClock.checked
                    opacity: showClock.checked ? 1.0 : 0.5

                    Label {
                        text: i18n("Clock size:")
                        Layout.alignment: Qt.AlignVCenter
                        leftPadding: showClock.indicator.width + showClock.spacing
                    }

                    ComboBox {
                        id: clockSizeCombo
                        Layout.fillWidth: true

                        model: [
                            { display: "48 px", value: 48 },
                            { display: "64 px", value: 64 },
                            { display: "72 px", value: 72 },
                            { display: "96 px", value: 96 },
                            { display: "128 px", value: 128 },
                            { display: "144 px", value: 144 },
                            { display: "192 px", value: 192 }
                        ]
                        textRole: "display"
                        valueRole: "value"

                        Component.onCompleted: {
                            currentIndex = indexOfValue(plasmoid.configuration.clockSize)
                            if (currentIndex === -1) {
                                let configValue = plasmoid.configuration.clockSize
                                let bestIndex = 0
                                let minDiff = Math.abs(model[0].value - configValue)

                                for (let i = 1; i < model.length; i++) {
                                    let diff = Math.abs(model[i].value - configValue)
                                    if (diff < minDiff) {
                                        minDiff = diff
                                        bestIndex = i
                                    }
                                }
                                currentIndex = bestIndex
                            }
                        }

                        onActivated: {
                            clockSizeCombo.value = model[currentIndex].value
                        }

                        property int value: currentValue
                    }
                }

                Label {
                    text: i18n("Select the moving clock font size")
                    font: Kirigami.Theme.smallFont
                    opacity: showClock.checked ? 0.7 : 0.3
                    leftPadding: showClock.indicator.width + showClock.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                CheckBox {
                    id: showBattery
                    text: i18n("Show battery status")
                    enabled: showClock.checked && batteryInfo.hasInternalBatteries
                    opacity: showClock.checked && batteryInfo.hasInternalBatteries ? 1.0 : 0.5
                }

                Label {
                    text: i18n("Display battery status on the overlay")
                    font: Kirigami.Theme.smallFont
                    opacity: showClock.checked && batteryInfo.hasInternalBatteries ? 0.7 : 0.3
                    leftPadding: showBattery.indicator.width + showBattery.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.largeSpacing }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Item { implicitHeight: Kirigami.Units.largeSpacing }

            ColumnLayout {
                Kirigami.FormData.isSection: true

                Kirigami.Heading {
                    text: i18n("Behavior")
                    level: 2
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                }

                Label {
                    text: i18n("Configure how the overlay behaves")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Label {
                        text: i18n("Target screen:")
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ComboBox {
                        id: screenCombo
                        Layout.fillWidth: true
                        model: screenModel
                        textRole: "display"
                        valueRole: "value"
                    }
                }

                Label {
                    text: i18n("Select a monitor for the overlay to appear")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Label {
                        text: i18n("Countdown duration:")
                        Layout.alignment: Qt.AlignVCenter
                    }

                    SpinBox {
                        id: countdownSpinner
                        from: 0
                        to: 30
                        stepSize: 1
                        Layout.alignment: Qt.AlignVCenter

                        textFromValue: function(value) {
                            return value === 0 ? i18n("Immediate") : i18np("%1 second", "%1 seconds", value)
                        }

                        valueFromText: function(text) {
                            return parseInt(text) || 0
                        }
                    }
                }

                Label {
                    text: i18n("Time to wait before activating the overlay")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                CheckBox {
                    id: useDoubleClick
                    text: i18n("Use double-click to exit")
                    onCheckedChanged: {
                        if (!checked) {
                            enableQuickPeek.checked = false
                        }
                    }
                }

                Label {
                    text: i18n("Close overlay with double-click")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    leftPadding: useDoubleClick.indicator.width + useDoubleClick.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                CheckBox {
                    id: enableQuickPeek
                    text: i18n("Enable Quick Peek")
                    enabled: useDoubleClick.checked
                    opacity: useDoubleClick.checked ? 1.0 : 0.5
                }

                Label {
                    text: i18n("Long-press to see through the overlay")
                    font: Kirigami.Theme.smallFont
                    opacity: useDoubleClick.checked ? 0.7 : 0.3
                    leftPadding: enableQuickPeek.indicator.width + enableQuickPeek.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    CheckBox {
                        id: enableDND
                        text: i18n("Enable Do Not Disturb")
                    }

                    Kirigami.ContextualHelpButton {
                        toolTipText: i18n("Starting with Plasma 6.4, the default Do Not Disturb behavior is also controlled by system settings.")
                    }
                }

                Label {
                    text: i18n("Activate DND while overlay is visible")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    leftPadding: enableDND.indicator.width + enableDND.spacing
                }
            }

            Item { implicitHeight: Kirigami.Units.smallSpacing }

            ColumnLayout {
                Layout.leftMargin: Kirigami.Units.largeSpacing

                CheckBox {
                    id: muteOnOverlay
                    text: i18n("Mute a sound device")
                }

                Label {
                    text: i18n("Silence audio while overlay is visible")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    leftPadding: muteOnOverlay.indicator.width + muteOnOverlay.spacing
                }
            }
        }
    }
}