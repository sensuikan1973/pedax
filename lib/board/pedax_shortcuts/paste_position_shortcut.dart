import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart'; // Assuming this path is correct
import 'package:pedax/models/board_notifier.dart'; // Assuming this path is correct

import 'pedax_shortcut.dart'; // Assuming this path is correct

// Constants defined in plan step 1
const int EXPECTED_STRING_LENGTH = 65;
const Set<String> VALID_BOARD_CHARS = {'X', 'O', '-'};
const Set<String> VALID_PLAYER_CHARS = {'X', 'O'};

@immutable
class PastePositionShortcut implements PedaxShortcut {
  const PastePositionShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelPastePosition; // This localization key will need to be added

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyV;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();

  // Using Alt+V for MacOS, Alt+V for other platforms.
  // Flutter's RawKeyboardListener/FocusShortcut might handle Alt detection differently
  // across platforms or might need isControlPressed / isMetaPressed for Cmd/Ctrl.
  // For now, let's try with isAltPressed.
  @override
  String get keys {
    if (Platform.isMacOS) {
      return '⌥$_keyLabel (Alt + $_keyLabel)';
    } else {
      return 'Alt + $_keyLabel';
    }
  }

  @override
  bool fired(final KeyEvent keyEvent) {
    // This checks for Alt key.
    // Note: On some systems, Alt might be AltGr.
    // Consider if isModifierPressed(ModifierKey.altModifier) is more robust or if specific platform checks are needed.
    // For simplicity, using isAltPressed.
    return HardwareKeyboard.instance.isAltPressed &&
           HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey) &&
           keyEvent is KeyDownEvent; // Ensure it fires only on key down
  }

  bool isValidPositionString(String? text) {
    if (text == null) return false;
    if (text.length != EXPECTED_STRING_LENGTH) return false;

    for (int i = 0; i < EXPECTED_STRING_LENGTH - 1; i++) {
      if (!VALID_BOARD_CHARS.contains(text[i])) return false;
    }

    if (!VALID_PLAYER_CHARS.contains(text[EXPECTED_STRING_LENGTH - 1])) return false;

    return true;
  }

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null || clipboardData.text == null) {
      debugPrint("PastePositionShortcut: Clipboard data is null.");
      return;
    }

    final String textToPaste = clipboardData.text!;
    if (isValidPositionString(textToPaste)) {
      // Call the new method on BoardNotifier.
      // This method will be created in the next plan step.
      args.boardNotifier.requestSetBoardFromString(textToPaste);
      debugPrint("PastePositionShortcut: Valid position string pasted and request sent.");
    } else {
      // Optionally, provide feedback to the user about invalid format.
      // For now, just a debug print.
      debugPrint("PastePositionShortcut: Invalid position string format. Text: '$textToPaste'");
    }
  }
}
