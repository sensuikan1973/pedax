import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class UndoShortcut implements PedaxShortcut {
  const UndoShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelUndo;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyU => LogicalKeyboardKey.keyU;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowLeft => LogicalKeyboardKey.arrowLeft;

  @override
  String get keys => '${logicalKeyU.keyLabel.toUpperCase()} or ←';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      keyEvent.isKeyPressed(logicalKeyU) || keyEvent.isKeyPressed(logicalKeyArrowLeft);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestUndo();
}
