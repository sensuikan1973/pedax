import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class RedoShorcut implements PedaxShorcut {
  const RedoShorcut(this.boardNotifier);

  @override
  final BoardNotifier boardNotifier;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelRedo;

  @override
  String get keys => '${logicalKey.keyLabel.toUpperCase()} or ${logicalKeyArrowRight.keyLabel.toUpperCase()}';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      keyEvent.isKeyPressed(logicalKey) || keyEvent.isKeyPressed(logicalKeyArrowRight);

  @override
  Future<void> runEvent() async => boardNotifier.requestRedo();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyR;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowRight => LogicalKeyboardKey.arrowRight;
}
