import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../engine/edax.dart';

class NTasksSettingDialog extends StatelessWidget {
  NTasksSettingDialog({required this.edax, Key? key}) : super(key: key);

  final Edax edax;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.nTasksSetting),
        content: FutureBuilder<int>(
          future: edax.nTasks,
          builder: (_, snapshot) => TextFormField(
            controller: _textController..text = snapshot.hasData ? snapshot.data!.toString() : ' ',
            autofocus: true,
            decoration: InputDecoration(hintText: '1 ~ ${Platform.numberOfProcessors}'),
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
              if (n != null) await edax.setNTasks(n);
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
