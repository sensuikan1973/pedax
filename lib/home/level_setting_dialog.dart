import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../engine/edax.dart';
import '../engine/options/level_option.dart';

class LevelSettingDialog extends StatelessWidget {
  LevelSettingDialog({required this.edax, Key? key}) : super(key: key);

  final Edax edax;
  final _option = const LevelOption();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.nTasksSetting),
        content: FutureBuilder<int>(
          future: _option.val,
          builder: (_, snapshot) => TextFormField(
            controller: _textController..text = snapshot.hasData ? snapshot.data!.toString() : ' ',
            autofocus: true,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelOnDialog),
          ),
          TextButton(
            onPressed: () async {
              final n = int.tryParse(_textController.text);
              if (n != null) {
                edax.lib.edaxSetOption(_option.nativeName, n.toString());
                await _option.update(n);
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Edax>('edax', edax));
  }
}
