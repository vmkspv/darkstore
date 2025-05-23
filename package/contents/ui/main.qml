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
import org.kde.notificationmanager as NotificationManager

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

    NotificationManager.Settings {
        id: notificationSettings
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
                if (fullRep.remainingSeconds > 1) {
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
            height: placeholder.height + countdown.height + sliderArea.height + Kirigami.Units.gridUnit * 3

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
                text: i18np("%1 second", "%1 seconds", fullRep.remainingSeconds)
                level: 1
                color: Kirigami.Theme.highlightColor
                font.weight: Font.Bold
            }

            Item {
                id: sliderArea
                anchors.top: countdown.bottom
                anchors.topMargin: Kirigami.Units.gridUnit * 2
                width: parent.width
                height: Kirigami.Units.gridUnit * 4

                Item {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Kirigami.Units.gridUnit * 18
                    height: Kirigami.Units.gridUnit * 3

                    Rectangle {
                        id: sliderTrack
                        anchors.fill: parent
                        radius: height / 2
                        color: Qt.rgba(
                            Kirigami.Theme.backgroundColor.r,
                            Kirigami.Theme.backgroundColor.g,
                            Kirigami.Theme.backgroundColor.b,
                            0.3
                        )
                        border.width: 1
                        border.color: Qt.rgba(
                            Kirigami.Theme.textColor.r,
                            Kirigami.Theme.textColor.g,
                            Kirigami.Theme.textColor.b,
                            0.2
                        )

                        Text {
                            anchors.centerIn: parent
                            text: i18n("Slide to activate now")
                            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 0.9)
                            color: Kirigami.Theme.textColor
                            opacity: 1.0 - (sliderHandle.x / (sliderTrack.width - sliderHandle.width))
                        }
                    }

                    Rectangle {
                        id: sliderHandle
                        width: height
                        height: parent.height
                        radius: height / 2
                        x: 0
                        color: Kirigami.Theme.highlightColor

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                            source: "go-next"
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: sliderHandle
                            drag.axis: Drag.XAxis
                            drag.minimumX: 0
                            drag.maximumX: sliderTrack.width - sliderHandle.width

                            onReleased: {
                                if (sliderHandle.x > (sliderTrack.width - sliderHandle.width) * 0.8) {
                                    countdownTimer.stop()
                                    toggleOverlay()
                                } else {
                                    sliderHandle.x = 0
                                }
                            }
                        }
                    }
                }
            }
        }

        onVisibleChanged: {
            if (visible && !overlayActive) {
                fullRep.remainingSeconds = root.countdownSeconds
                countdownTimer.start()
                if (sliderHandle) sliderHandle.x = 0
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

    function toggleDnd(enable) {
        if (enable) {
            var d = new Date()
            d.setYear(d.getFullYear() + 1)
            notificationSettings.notificationsInhibitedUntil = d
            notificationSettings.save()
        } else {
            var d = new Date(0)
            notificationSettings.notificationsInhibitedUntil = d
            notificationSettings.save()
        }
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
            if (plasmoid.configuration.enableDND) {
                toggleDnd(false)
            }
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
                "showClock": plasmoid.configuration.showClock,
                "clockSize": plasmoid.configuration.clockSize,
                "useDoubleClick": plasmoid.configuration.useDoubleClick
            })

            overlayWindow.shown.connect(function() {
                inhibitActive = true
                inhibitionControl.inhibit(i18n("Darkstore overlay is active"))
                if (plasmoid.configuration.enableDND) {
                    toggleDnd(true)
                }
            })

            overlayWindow.closing.connect(function() {
                overlayActive = false
                overlayWindow = null
                inhibitActive = false
                inhibitionControl.uninhibit()
                if (plasmoid.configuration.enableDND) {
                    toggleDnd(false)
                }
            })

            overlayWindow.showFullScreen()
        }
    }
}