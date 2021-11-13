import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class NewShorcut implements PedaxShorcut {
  const NewShorcut(this.boardNotifier);

  final BoardNotifier boardNotifier;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelNew;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKey);

  @override
  Future<void> runEvent() async => boardNotifier.requestNew();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyN;
}
