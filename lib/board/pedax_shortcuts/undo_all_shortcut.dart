import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class UndoAllShortcut implements PedaxShortcut {
  const UndoAllShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelUndoAll;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyS;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKey);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestUndoAll();
}
