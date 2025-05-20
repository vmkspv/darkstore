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

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint | Qt.X11BypassWindowManagerHint

    location: PlasmaCore.Types.FullScreen
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
        width: Screen.width
        height: Screen.height
        color: "black"
        opacity: 1.0

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.BlankCursor
            onClicked: {
                overlayDialog.close()
                overlayDialog.destroy()
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