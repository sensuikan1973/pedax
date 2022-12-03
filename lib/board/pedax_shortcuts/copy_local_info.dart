import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';

import '../../engine/options/native/book_file_option.dart';
import '../../engine/options/native/eval_file_option.dart';
import '../../engine/options/native/level_option.dart';
import '../../engine/options/native/n_tasks_option.dart';
import '../../engine/options/pedax/bestpath_count_availability_option.dart';
import '../../engine/options/pedax/bestpath_count_opponent_lower_limit.dart';
import '../../engine/options/pedax/bestpath_count_player_lower_limit.dart';
import '../../engine/options/pedax/hint_step_by_step_option.dart';
import 'pedax_shortcut.dart';

@immutable
class CopyLocalInfoShorcut implements PedaxShorcut {
  const CopyLocalInfoShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelCopyLocalInfo;

  @override
  String get keys => Platform.isMacOS ? '^$_keyLabel or ⌘$_keyLabel' : 'Ctrl + $_keyLabel';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(logicalKey)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(logicalKey));

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async {
    final compactHintsWithStepByStep = List<Map<String, String>>.empty(growable: true);
    for (final h in args.boardNotifier.value.hintsWithStepByStep) {
      compactHintsWithStepByStep.add(
        {
          'isLastStep': h.isLastStep.toString(),
          'hint.moveString': h.hint.moveString,
          'hint.scoreString': h.hint.scoreString,
          'hint.isBookMove': h.hint.isBookMove.toString(),
          'hint.depth': h.hint.depth.toString(),
        },
      );
    }
    final packageInfo = await PackageInfo.fromPlatform();
    // https://dart.dev/guides/libraries/library-tour#decoding-and-encoding-json
    final jsonText = jsonEncode({
      'app': {
        'name': packageInfo.appName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      },
      'config': {
        'bestpathCountAvailabilityOption': await const BestpathCountAvailabilityOption().val,
        'bestpathCountPlayerLowerLimitOption': await const BestpathCountPlayerLowerLimitOption().val,
        'bestpathCountOpponentLowerLimitOption': await const BestpathCountOpponentLowerLimitOption().val,
        'hintStepByStepOption': await const HintStepByStepOption().val,
        'bookFileOption': await const BookFileOption().val,
        'evalFileOption': await const EvalFileOption().val,
        'levelOption': await const LevelOption().val,
        'nTasksOption': await const NTasksOption().val,
      },
      'system': {
        'numberOfProcessors': Platform.numberOfProcessors,
        'operatingSystemVersion': Platform.operatingSystemVersion,
      },
      'board': {
        'modeName': args.boardNotifier.value.mode.name,
        'currentMovesWithoutPassString': args.boardNotifier.value.currentMovesWithoutPassString,
        'bookHasBeenLoaded': args.boardNotifier.value.bookHasBeenLoaded,
        'positionFullNum': args.boardNotifier.value.positionFullNum,
        'hintsWithStepByStep': compactHintsWithStepByStep,
      }
    });
    await Clipboard.setData(ClipboardData(text: jsonText));
  }

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyL;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();
}
