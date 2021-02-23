import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../engine/options/hint_step_by_step_option.dart';

class HintStepByStepSettingDialog extends StatefulWidget {
  const HintStepByStepSettingDialog({Key? key}) : super(key: key);

  @override
  _HintStepByStepSettingDialogState createState() => _HintStepByStepSettingDialogState();
}

class _HintStepByStepSettingDialogState extends State<HintStepByStepSettingDialog> {
  HintStepByStepOption get _option => const HintStepByStepOption();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.hintStepByStepSetting),
        content: FutureBuilder<bool>(
          future: _option.val,
          builder: (_, snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.hintStepByStepDescription),
              Switch(
                value: snapshot.hasData && snapshot.data!,
                onChanged: (value) {
                  setState(() {
                    _option.update(value);
                  });
                },
              ),
            ],
          ),
        ),
      );
}
