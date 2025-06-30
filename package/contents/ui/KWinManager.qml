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

            'if command -v kwriteconfig6 >/dev/null 2>&1; then ' +
                'KREADCONFIG="kreadconfig6"; ' +
                'KWRITECONFIG="kwriteconfig6"; ' +
            'elif command -v kwriteconfig5 >/dev/null 2>&1; then ' +
                'KREADCONFIG="kreadconfig5"; ' +
                'KWRITECONFIG="kwriteconfig5"; ' +
            'fi; ' +

            'CURRENT_COUNT=$($KREADCONFIG --file "$RULE_FILE" --group "General" --key "count" 2>/dev/null); ' +
            'CURRENT_RULES=$($KREADCONFIG --file "$RULE_FILE" --group "General" --key "rules" 2>/dev/null); ' +
            'if [ -z "$CURRENT_COUNT" ]; then CURRENT_COUNT=0; fi; ' +
            'NEW_COUNT=$((CURRENT_COUNT + 1)); ' +
            'if [ -z "$CURRENT_RULES" ]; then NEW_RULES="' + ruleId + '"; else NEW_RULES="$CURRENT_RULES,' + ruleId + '"; fi; ' +

            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "Description" "' + i18n("Overlay settings for Darkstore") + '"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "above" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "aboverule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "disableglobalshortcuts" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "disableglobalshortcutsrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "fullscreen" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "fullscreenrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "layer" "fullscreen"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "layerrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "noborder" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "noborderrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skippager" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skippagerrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skipswitcher" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skipswitcherrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skiptaskbar" "true"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "skiptaskbarrule" "2"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "title" "Darkstore"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "titlematch" "1"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "wmclass" "plasmashell"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "' + ruleId + '" --key "wmclassmatch" "2"; ' +

            '$KWRITECONFIG --file "$RULE_FILE" --group "General" --key "count" "$NEW_COUNT"; ' +
            '$KWRITECONFIG --file "$RULE_FILE" --group "General" --key "rules" "$NEW_RULES"; ' +
            'qdbus org.kde.KWin /KWin reconfigure; ' +
            'fi'

        kwinRuleSource.connectSource(command)
    }

    Component.onCompleted: {
        importRule()
    }
}