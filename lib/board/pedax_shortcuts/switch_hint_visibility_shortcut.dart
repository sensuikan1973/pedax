import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class SwitchHintVisibilityShorcut implements PedaxShorcut {
  const SwitchHintVisibilityShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelSwitchHintVisibility;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyH;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKey);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.switchHintVisibility();
}
