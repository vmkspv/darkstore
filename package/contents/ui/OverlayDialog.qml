/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.kwindowsystem
import "." as Local

PlasmaCore.Dialog {
    id: overlayDialog

    signal closing()
    signal shown()

    property double overlayOpacity: 1.0
    property bool showClock: false
    property int clockSize: 96
    property bool showBattery: false
    property bool useDoubleClick: false
    property bool enableQuickPeek: false

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint | Qt.X11BypassWindowManagerHint

    location: PlasmaCore.Types.Floating
    hideOnWindowDeactivate: false
    backgroundHints: PlasmaCore.Dialog.NoBackground

    type: PlasmaCore.Dialog.OnScreenDisplay

    x: 0
    y: 0
    width: Screen.width
    height: Screen.height

    onVisibleChanged: {
        if (!visible) {
            closing()
        } else {
            shown()
        }
    }

    mainItem: Rectangle {
        id: overlay
        width: Screen.width
        height: Screen.height
        color: "black"
        opacity: peekActive ? 0.3 : overlayDialog.overlayOpacity

        property bool peekActive: false

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.BlankCursor

            property bool longPressed: false

            onPressed: {
                if (overlayDialog.enableQuickPeek) {
                    longPressTimer.restart()
                }
            }

            onReleased: {
                longPressTimer.stop()
                if (overlay.peekActive) {
                    overlay.peekActive = false
                } else if (!longPressed && !overlayDialog.useDoubleClick) {
                    overlayDialog.close()
                    overlayDialog.destroy()
                }
                longPressed = false
            }

            onClicked: {
                if (!longPressed && !overlayDialog.useDoubleClick) {
                    overlayDialog.close()
                    overlayDialog.destroy()
                }
            }

            onDoubleClicked: {
                if (overlayDialog.useDoubleClick) {
                    overlayDialog.close()
                    overlayDialog.destroy()
                }
            }

            Timer {
                id: longPressTimer
                interval: 600
                repeat: false
                onTriggered: {
                    if (overlayDialog.enableQuickPeek) {
                        mouseArea.longPressed = true
                        overlay.peekActive = true
                    }
                }
            }
        }

        Item {
            id: clockContainer
            visible: overlayDialog.showClock
            x: clock.xPos
            y: clock.yPos
            width: Math.max(clock.width, batteryStatus.width)
            height: clock.height + (batteryStatus.visible ? batteryStatus.height + Math.round(overlayDialog.clockSize * 0.1) : 0)

            Text {
                id: clock
                color: "#80ffffff"
                font.pixelSize: overlayDialog.clockSize
                font.bold: true

                property int xDirection: 1
                property int yDirection: 1
                property int xPos: Math.random() * (parent.parent.width - parent.width)
                property int yPos: Math.random() * (parent.parent.height - parent.height)
                property int speed: 1
            }

            Local.BatteryStatus {
                id: batteryStatus
                anchors {
                    top: clock.bottom
                    horizontalCenter: clock.horizontalCenter
                }
                visible: overlayDialog.showClock && overlayDialog.showBattery
                clockSize: overlayDialog.clockSize
            }

            Timer {
                interval: 1000
                running: overlayDialog.showClock
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    clock.text = Qt.formatTime(date, Qt.LocaleTime)
                }
            }

            Timer {
                interval: 32
                running: overlayDialog.showClock
                repeat: true

                onTriggered: {
                    clock.xPos += clock.xDirection * clock.speed
                    clock.yPos += clock.yDirection * clock.speed

                    if (clock.xPos <= 0) {
                        clock.xDirection = 1
                        clock.xPos = 0
                    } else if (clock.xPos >= overlay.width - clockContainer.width) {
                        clock.xDirection = -1
                        clock.xPos = overlay.width - clockContainer.width
                    }

                    if (clock.yPos <= 0) {
                        clock.yDirection = 1
                        clock.yPos = 0
                    } else if (clock.yPos >= overlay.height - clockContainer.height) {
                        clock.yDirection = -1
                        clock.yPos = overlay.height - clockContainer.height
                    }
                }
            }
        }

        Keys.onEscapePressed: {
            overlayDialog.close()
            overlayDialog.destroy()
        }

        Component.onCompleted: {
            forceActiveFocus()
        }
    }

    function showFullScreen() {
        visible = true
        KWindowSystem.setType(overlayDialog.winId, KWindowSystem.OnScreenDisplay)
        KWindowSystem.setState(overlayDialog.winId,
            KWindowSystem.FullScreen |
            KWindowSystem.KeepAbove |
            KWindowSystem.SkipTaskbar |
            KWindowSystem.SkipPager |
            KWindowSystem.StaysOnTop)

        KWindowSystem.forceActiveWindow(overlayDialog.winId)
    }
}