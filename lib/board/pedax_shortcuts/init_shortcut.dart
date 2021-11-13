import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class InitShorcut implements PedaxShorcut {
  const InitShorcut(this.boardNotifier);

  final BoardNotifier boardNotifier;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelInit;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKey);

  @override
  Future<void> runEvent() async => boardNotifier.requestInit();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyI;
}
