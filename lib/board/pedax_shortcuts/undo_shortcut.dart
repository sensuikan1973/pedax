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
  String get keys => logicalKeyU.keyLabel.toUpperCase();

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKeyU) || keyEvent.isKeyPressed(logicalKeyArrowLeft);

  @override
  Future<void> runEvent() async => boardNotifier.requestUndo();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyU => LogicalKeyboardKey.keyU;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowLeft => LogicalKeyboardKey.arrowLeft;
}
