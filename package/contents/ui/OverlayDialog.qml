/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.kwindowsystem

PlasmaCore.Dialog {
    id: overlayDialog

    signal closing()
    signal shown()

    property double overlayOpacity: 1.0
    property bool showClock: false
    property int clockSize: 96
    property bool useDoubleClick: false

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
        opacity: overlayDialog.overlayOpacity

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.BlankCursor

            onClicked: {
                if (!overlayDialog.useDoubleClick) {
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
        }

        Text {
            id: clock
            color: "#80ffffff"
            font.pixelSize: overlayDialog.clockSize
            font.bold: true
            visible: overlayDialog.showClock

            property int xDirection: 1
            property int yDirection: 1
            property int xPos: Math.random() * (parent.width - width)
            property int yPos: Math.random() * (parent.height - height)
            property int speed: 1

            x: xPos
            y: yPos

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
                    } else if (clock.xPos >= overlay.width - clock.width) {
                        clock.xDirection = -1
                        clock.xPos = overlay.width - clock.width
                    }

                    if (clock.yPos <= 0) {
                        clock.yDirection = 1
                        clock.yPos = 0
                    } else if (clock.yPos >= overlay.height - clock.height) {
                        clock.yDirection = -1
                        clock.yPos = overlay.height - clock.height
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