import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import '../../models/board_notifier.dart';
import 'capture_board_image_shortcut.dart';
import 'copy_local_info.dart';
import 'copy_moves_shortcut.dart';
import 'init_shortcut.dart';
import 'new_shortcut.dart';
import 'paste_moves_shortcut.dart';
import 'redo_all_shortcut.dart';
import 'redo_shortcut.dart';
import 'rotate180_shortcut.dart';
import 'switch_hint_visibility.dart';
import 'undo_all_shortcut.dart';
import 'undo_shortcut.dart';

@immutable
abstract class PedaxShorcut {
  String label(final AppLocalizations localizations);
  String get keys;
  bool fired(final RawKeyEvent keyEvent);
  Future<void> runEvent(final PedaxShortcutEventArguments argus);
}

class PedaxShortcutEventArguments {
  const PedaxShortcutEventArguments(this.boardNotifier, this.captureKey);

  final BoardNotifier boardNotifier;
  final GlobalKey captureKey;
}

List<PedaxShorcut> get shortcutList => const [
      InitShorcut(),
      NewShorcut(),
      UndoShorcut(),
      RedoShorcut(),
      UndoAllShorcut(),
      RedoAllShorcut(),
      CopyMovesShorcut(),
      PasteMovesShorcut(),
      SwitchHintVisibilityShorcut(),
      Rotate180Shorcut(),
      CaptureBoardImageShorcut(),
      CopyLocalInfoShorcut(),
    ];
