/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.private.volume

QtObject {
    id: volumeManager

    property bool isMuted: false
    property real savedVolume: 0

    property var sink: PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")

    function muteVolume() {
        if (!sinkAvailable || isMuted) {
            return
        }
        savedVolume = sink.volume
        sink.volume = 0
        isMuted = true
    }

    function restoreVolume() {
        if (!sinkAvailable || !isMuted) {
            return
        }
        if (savedVolume > 0) {
            sink.volume = savedVolume
        }
        isMuted = false
    }

    function toggleMute() {
        if (isMuted) {
            restoreVolume()
        } else {
            muteVolume()
        }
    }
}