import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class RedoShorcut implements PedaxShorcut {
  const RedoShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelRedo;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyR => LogicalKeyboardKey.keyR;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowRight => LogicalKeyboardKey.arrowRight;

  @override
  String get keys => '${logicalKeyR.keyLabel.toUpperCase()} or →';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      keyEvent.isKeyPressed(logicalKeyR) || keyEvent.isKeyPressed(logicalKeyArrowRight);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestRedo();
}
