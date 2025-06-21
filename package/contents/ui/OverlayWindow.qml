/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.kirigami as Kirigami
import "." as Local

Kirigami.AbstractApplicationWindow {
    id: overlayWindow

    signal overlayClosing()
    signal overlayShown()

    property double overlayOpacity: 1.0
    property bool showClock: false
    property int clockSize: 96
    property bool showBattery: false
    property bool useDoubleClick: false
    property bool enableQuickPeek: false

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint | Qt.X11BypassWindowManagerHint
    color: Qt.rgba(0, 0, 0, mouseArea.peekActive ? 0.3 : overlayOpacity)
    visibility: Window.FullScreen

    onVisibleChanged: {
        if (!visible) {
            overlayClosing()
        } else {
            overlayShown()
        }
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.BlankCursor

            property bool longPressed: false
            property bool peekActive: false

            onPressed: {
                if (overlayWindow.enableQuickPeek) {
                    longPressTimer.restart()
                }
            }

            onReleased: {
                longPressTimer.stop()
                if (peekActive) {
                    peekActive = false
                } else if (!longPressed && !overlayWindow.useDoubleClick) {
                    overlayWindow.close()
                    overlayWindow.destroy()
                }
                longPressed = false
            }

            onClicked: {
                if (!longPressed && !overlayWindow.useDoubleClick) {
                    overlayWindow.close()
                    overlayWindow.destroy()
                }
            }

            onDoubleClicked: {
                if (overlayWindow.useDoubleClick) {
                    overlayWindow.close()
                    overlayWindow.destroy()
                }
            }

            Timer {
                id: longPressTimer
                interval: 600
                repeat: false
                onTriggered: {
                    if (overlayWindow.enableQuickPeek) {
                        mouseArea.longPressed = true
                        mouseArea.peekActive = true
                    }
                }
            }
        }

        Item {
            id: clockContainer
            visible: overlayWindow.showClock
            x: clock.xPos
            y: clock.yPos
            width: Math.max(clock.width, batteryStatus.width)
            height: clock.height + (batteryStatus.visible ? batteryStatus.height + Math.round(overlayWindow.clockSize * 0.1) : 0)

            Text {
                id: clock
                color: "#80ffffff"
                font.pixelSize: overlayWindow.clockSize
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
                visible: overlayWindow.showClock && overlayWindow.showBattery
                clockSize: overlayWindow.clockSize
            }

            Timer {
                interval: 1000
                running: overlayWindow.showClock
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    clock.text = Qt.formatTime(date, Qt.LocaleTime)
                }
            }

            Timer {
                interval: 32
                running: overlayWindow.showClock
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
            overlayWindow.close()
            overlayWindow.destroy()
        }

        Component.onCompleted: {
            forceActiveFocus()
        }
    }

    function showFullScreen() {
        show()
        raise()
        requestActivate()
        overlayShown()
    }
}