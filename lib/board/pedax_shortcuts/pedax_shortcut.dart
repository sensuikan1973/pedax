import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart';

import '../../models/board_notifier.dart';
import 'capture_board_image_shortcut.dart';
import 'copy_local_info_shortcut.dart';
import 'copy_moves_shortcut.dart';
import 'init_shortcut.dart';
import 'new_shortcut.dart';
import 'paste_moves_shortcut.dart';
import 'redo_all_shortcut.dart';
import 'redo_shortcut.dart';
import 'rotate180_shortcut.dart';
import 'switch_hint_visibility_shortcut.dart';
import 'undo_all_shortcut.dart';
import 'undo_shortcut.dart';

@immutable
abstract class PedaxShortcut {
  String label(final AppLocalizations localizations);
  String get keys;
  bool fired(final KeyEvent keyEvent);
  Future<void> runEvent(final PedaxShortcutEventArguments argus);
}

class PedaxShortcutEventArguments {
  const PedaxShortcutEventArguments(this.boardNotifier, this.captureKey);

  final BoardNotifier boardNotifier;
  final GlobalKey captureKey;
}

List<PedaxShortcut> get shortcutList => const [
  InitShortcut(),
  NewShortcut(),
  UndoShortcut(),
  RedoShortcut(),
  UndoAllShortcut(),
  RedoAllShortcut(),
  CopyMovesShortcut(),
  PasteMovesShortcut(),
  SwitchHintVisibilityShortcut(),
  Rotate180Shortcut(),
  CaptureBoardImageShortcut(),
  CopyLocalInfoShortcut(),
];
