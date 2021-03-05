import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class RedoShorcut extends PedaxShorcut {
  const RedoShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelRedo;

  @override
  String get keys => 'R';

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(LogicalKeyboardKey.keyR);

  @override
  Future<void> runEvent() async => boardNotifier.requestRedo();
}
