import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class UndoShorcut implements PedaxShorcut {
  const UndoShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelUndo;

  @override
  String get keys => '${logicalKey.keyLabel.toUpperCase()} or ←';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      keyEvent.isKeyPressed(logicalKey) || keyEvent.isKeyPressed(logicalKeyArrowLeft);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestUndo();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyU;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowLeft => LogicalKeyboardKey.arrowLeft;
}
