import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'copy_moves_shortcut.dart';
import 'paste_moves_shortcut.dart';
import 'redo_all_shortcut.dart';
import 'redo_shortcut.dart';
import 'rotate180_shortcut.dart';
import 'switch_hint_visibility.dart';
import 'undo_all_shortcut.dart';
import 'undo_shortcut.dart';

@immutable
abstract class PedaxShorcut {
  BoardNotifier get boardNotifier;
  String label(final AppLocalizations localizations);
  String get keys;
  bool fired(final RawKeyEvent keyEvent);
  Future<void> runEvent();
}

List<PedaxShorcut> shortcutList(final BoardNotifier boardNotifier) => [
      UndoShorcut(boardNotifier),
      RedoShorcut(boardNotifier),
      UndoAllShorcut(boardNotifier),
      RedoAllShorcut(boardNotifier),
      CopyMovesShorcut(boardNotifier),
      PasteMovesShorcut(boardNotifier),
      SwitchHintVisibilityShorcut(boardNotifier),
      Rotate180Shorcut(boardNotifier),
    ];
