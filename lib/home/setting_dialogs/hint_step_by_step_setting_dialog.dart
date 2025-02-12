import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../engine/options/pedax/hint_step_by_step_option.dart';
import '../../models/board_notifier.dart';

class HintStepByStepSettingDialog extends StatelessWidget {
  HintStepByStepSettingDialog({super.key});

  HintStepByStepOption get _option => const HintStepByStepOption();
  final _enabled = ValueNotifier<bool?>(null);

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.hintStepByStepSetting, textAlign: TextAlign.center),
    content: FutureBuilder<bool>(
      future: _option.val,
      builder: (final context, final snapshot) {
        if (snapshot.hasData) _enabled.value = snapshot.data;
        return ValueListenableBuilder<bool?>(
          valueListenable: _enabled,
          builder: (final _, final value, final __) {
            if (value == null) return const CupertinoActivityIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.hintStepByStepDescription),
                Switch(
                  value: _enabled.value!,
                  onChanged: (final value) async {
                    context.read<BoardNotifier>().switchHintStepByStep(enabled: value);
                    await _option.update(value);
                    _enabled.value = value;
                  },
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
