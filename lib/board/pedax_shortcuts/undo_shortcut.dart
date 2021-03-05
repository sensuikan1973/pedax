import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class UndoShorcut extends PedaxShorcut {
  const UndoShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelUndo;

  @override
  String get keys => _logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(_logicalKey);

  @override
  Future<void> runEvent() async => boardNotifier.requestUndo();

  LogicalKeyboardKey get _logicalKey => LogicalKeyboardKey.keyU;
}
