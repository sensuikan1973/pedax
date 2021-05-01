import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../engine/options/hint_step_by_step_option.dart';
import '../models/board_notifier.dart';

class HintStepByStepSettingDialog extends StatelessWidget {
  HintStepByStepSettingDialog({Key? key}) : super(key: key);

  HintStepByStepOption get _option => const HintStepByStepOption();
  final _enabled = ValueNotifier<bool?>(null);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.hintStepByStepSetting, textAlign: TextAlign.center),
        content: FutureBuilder<bool>(
          future: _option.val,
          builder: (context, snapshot) {
            if (snapshot.hasData) _enabled.value = snapshot.data;
            return ValueListenableBuilder<bool?>(
              valueListenable: _enabled,
              builder: (_, value, __) {
                if (value == null) return const CupertinoActivityIndicator();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.hintStepByStepDescription),
                    Switch(
                      value: _enabled.value!,
                      onChanged: (value) {
                        context.read<BoardNotifier>().switchHintStepByStep(enabled: value);
                        _option.update(value);
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
