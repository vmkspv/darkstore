/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils
import org.kde.kirigami as Kirigami

SimpleKCM {
    id: generalPage

    property alias cfg_overlayOpacity: opacitySlider.value
    property alias cfg_showClock: showClock.checked
    property alias cfg_clockSize: clockSizeCombo.value
    property alias cfg_countdownDuration: countdownSpinner.value
    property alias cfg_useDoubleClick: useDoubleClick.checked
    property alias cfg_enableDND: enableDND.checked

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
                        text: i18n("Countdown duration:")
                        Layout.alignment: Qt.AlignVCenter
                    }

                    SpinBox {
                        id: countdownSpinner
                        from: 3
                        to: 30
                        stepSize: 5
                        Layout.alignment: Qt.AlignVCenter

                        textFromValue: function(value) {
                            return value + i18n(" seconds")
                        }

                        valueFromText: function(text) {
                            return parseInt(text) || 5
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
                    id: enableDND
                    text: i18n("Enable Do Not Disturb")
                }

                Label {
                    text: i18n("Activate DND while overlay is visible")
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    leftPadding: enableDND.indicator.width + enableDND.spacing
                }
            }
        }
    }
}