/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.batterymonitor
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    preferredRepresentation: plasmoid.formFactor === 0 || plasmoid.formFactor === 1
        ? compactRepresentation
        : undefined

    property bool overlayActive: false
    property int countdownSeconds: plasmoid.configuration.countdownDuration
    property var overlayWindow: null

    property bool inhibitActive: false
    property string inhibitionModule: ""
    property var inhibitionControl: Qt.createQmlObject(inhibitionModule, root, "inhibitionControl")
    property var inhibitions: inhibitionControl.inhibitions

    property string inhibitionControlQml: `
    import org.kde.plasma.private.batterymonitor
    InhibitionControl {
        id: powerManagementControl
    }`
    property string powerManagementControlQml: `
    import org.kde.plasma.private.batterymonitor
    PowerManagementControl {
        id: powerManagementControl
    }`

    Sensors.SensorDataModel {
        sensors: ["os/plasma/plasmaVersion"]
        enabled: true

        onDataChanged: {
            const value = data(index(0, 0), Sensors.SensorDataModel.Value)
            if (value !== undefined && value !== null) {
                if (value.indexOf("6.3") >= 0) {
                    inhibitionModule = inhibitionControlQml
                } else {
                    inhibitionModule = powerManagementControlQml
                }
            }
        }
    }

    compactRepresentation: Item {
        Kirigami.Icon {
            anchors.fill: parent
            source: Kirigami.Theme.textColor.hslLightness < 0.5
                ? Qt.resolvedUrl("../icons/io.github.vmkspv.darkstore-light.svg")
                : Qt.resolvedUrl("../icons/io.github.vmkspv.darkstore-dark.svg")
            active: mouseArea.containsMouse
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: toggleOverlay()
        }
    }

    fullRepresentation: Item {
        id: fullRep
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 18
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 28

        property int remainingSeconds: 0

        Timer {
            id: countdownTimer
            interval: 1000
            repeat: true
            onTriggered: {
                if (fullRep.remainingSeconds > 0) {
                    fullRep.remainingSeconds--
                } else {
                    stop()
                    toggleOverlay()
                }
            }
        }

        Item {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            height: placeholder.height + countdown.height + Kirigami.Units.largeSpacing

            Kirigami.PlaceholderMessage {
                id: placeholder
                anchors.top: parent.top
                width: parent.width
                icon {
                    source: Kirigami.Theme.textColor.hslLightness < 0.5
                        ? Qt.resolvedUrl("../icons/io.github.vmkspv.darkstore-light.svg")
                        : Qt.resolvedUrl("../icons/io.github.vmkspv.darkstore-dark.svg")
                    color: Kirigami.Theme.textColor
                }
                text: i18n("Overlay will activate in:")
            }

            Kirigami.Heading {
                id: countdown
                anchors.top: placeholder.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n("%1 seconds", fullRep.remainingSeconds)
                level: 1
                color: Kirigami.Theme.highlightColor
                font.weight: Font.Bold
            }
        }

        onVisibleChanged: {
            if (visible && !overlayActive) {
                fullRep.remainingSeconds = root.countdownSeconds
                countdownTimer.start()
            } else if (!visible) {
                countdownTimer.stop()
            }
        }
    }

    Component.onCompleted: {
        plasmoid.addEventListener("activate", function() {
            if (!overlayActive) {
                Plasmoid.expanded = true
            } else {
                toggleOverlay()
            }
        })
    }

    function toggleOverlay() {
        if (overlayActive) {
            if (overlayWindow) {
                overlayWindow.close()
                overlayWindow = null
            }
            overlayActive = false
            inhibitActive = false
            inhibitionControl.uninhibit()
        } else {
            createOverlay()
            overlayActive = true
            Plasmoid.expanded = false
        }
    }

    function createOverlay() {
        var component = Qt.createComponent("OverlayDialog.qml")
        if (component.status === Component.Ready) {
            overlayWindow = component.createObject(root, {
                "overlayOpacity": Math.max(0.7, plasmoid.configuration.overlayOpacity),
                "showClock": plasmoid.configuration.showClock
            })

            overlayWindow.shown.connect(function() {
                inhibitActive = true
                inhibitionControl.inhibit(i18n("Darkstore overlay is active"))
            })

            overlayWindow.closing.connect(function() {
                overlayActive = false
                overlayWindow = null
                inhibitActive = false
                inhibitionControl.uninhibit()
            })

            overlayWindow.showFullScreen()
        }
    }
}