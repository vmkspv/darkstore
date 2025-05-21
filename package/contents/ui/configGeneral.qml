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
    property alias cfg_countdownDuration: countdownSpinner.value

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
                    text: i18n("Adjust transparency of the black overlay")
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
                    text: i18n("Configure how the overlay activates")
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
        }
    }
}