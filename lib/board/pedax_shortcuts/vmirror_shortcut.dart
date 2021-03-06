import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class VmirrorShorcut extends PedaxShorcut {
  const VmirrorShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelVmirror;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(RawKeyEvent keyEvent) => keyEvent.isKeyPressed(logicalKey);

  @override
  Future<void> runEvent() async => boardNotifier.requestVmirror();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyM;
}
