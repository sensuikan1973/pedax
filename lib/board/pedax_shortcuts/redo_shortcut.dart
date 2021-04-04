import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class RedoShorcut implements PedaxShorcut {
  const RedoShorcut(this.boardNotifier);

  @override
  final BoardNotifier boardNotifier;

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelRedo;

  @override
  String get keys => '${logicalKeyR.keyLabel.toUpperCase()} or →';

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKeyR) || keyEvent.isKeyPressed(logicalKeyArrowRight);

  @override
  Future<void> runEvent() async => boardNotifier.requestRedo();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyR => LogicalKeyboardKey.keyR;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowRight => LogicalKeyboardKey.arrowRight;
}
