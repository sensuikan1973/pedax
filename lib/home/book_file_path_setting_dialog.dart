import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../engine/edax.dart';

class BookFilePathSettingDialog extends StatelessWidget {
  BookFilePathSettingDialog({required this.edax, Key? key}) : super(key: key);

  final Edax edax;
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
      future: edax.bookPath,
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.bookFilePathSetting),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _textController..text = snapshot.data!,
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (path) {
                if (path == null) return null;
                if (path.isEmpty) return null; // use default book
                if (!File(path).existsSync()) return AppLocalizations.of(context)!.userSpecifiedFileNotFound;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancelOnDialog),
            ),
            TextButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final newBookFilePath = _textController.text;
                await edax.setBookPath(newBookFilePath);
                if (snapshot.data != newBookFilePath) {
                  // TODO: load asynchronously. this is slow when book is big.
                  edax.lib.edaxBookLoad(newBookFilePath);
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
            ),
          ],
        );
      });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Edax>('edax', edax));
  }
}
