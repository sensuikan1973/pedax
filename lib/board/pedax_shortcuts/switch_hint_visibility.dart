import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class SwitchHintVisibilityShorcut extends PedaxShorcut {
  const SwitchHintVisibilityShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelSwitchHintVisiblity;

  @override
  String get keys => 'H';

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(LogicalKeyboardKey.keyH);

  @override
  Future<void> runEvent() async => boardNotifier.switchHintVisibility();
}
