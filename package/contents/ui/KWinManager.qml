/*
    SPDX-FileCopyrightText: 2025 Vladimir Kosolapov
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

Item {
    id: kwinManager

    property string ruleId: Plasmoid.metaData.pluginId
    property bool ruleImported: false

    P5Support.DataSource {
        id: kwinRuleSource
        engine: "executable"

        onNewData: function(sourceName, data) {
            if (data["exit code"] === 0) {
                ruleImported = true
            }
        }
    }

    function importRule() {
        var command =
            'RULE_FILE="$HOME/.config/kwinrulesrc"; ' +
            'if ! grep -q "\\[' + ruleId + '\\]" "$RULE_FILE" 2>/dev/null; then ' +

            'CURRENT_COUNT=$(kreadconfig5 --file "$RULE_FILE" --group "General" --key "count" 2>/dev/null); ' +
            'CURRENT_RULES=$(kreadconfig5 --file "$RULE_FILE" --group "General" --key "rules" 2>/dev/null); ' +
            'if [ -z "$CURRENT_COUNT" ]; then CURRENT_COUNT=0; fi; ' +
            'NEW_COUNT=$((CURRENT_COUNT + 1)); ' +
            'if [ -z "$CURRENT_RULES" ]; then NEW_RULES="' + ruleId + '"; else NEW_RULES="$CURRENT_RULES,' + ruleId + '"; fi; ' +

            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "Description" "' + i18n("Overlay settings for Darkstore") + '"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "above" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "aboverule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "disableglobalshortcuts" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "disableglobalshortcutsrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "fullscreen" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "fullscreenrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "layer" "fullscreen"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "layerrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "noborder" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "noborderrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skippager" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skippagerrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skipswitcher" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skipswitcherrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skiptaskbar" "true"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "skiptaskbarrule" "2"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "title" "Darkstore"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "titlematch" "1"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "wmclass" "plasmashell"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "' + ruleId + '" --key "wmclassmatch" "2"; ' +

            'kwriteconfig5 --file "$RULE_FILE" --group "General" --key "count" "$NEW_COUNT"; ' +
            'kwriteconfig5 --file "$RULE_FILE" --group "General" --key "rules" "$NEW_RULES"; ' +
            'qdbus org.kde.KWin /KWin reconfigure; ' +
            'fi'

        kwinRuleSource.connectSource(command)
    }

    Component.onCompleted: {
        importRule()
    }
}