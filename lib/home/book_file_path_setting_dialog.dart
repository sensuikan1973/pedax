import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../engine/edax.dart';
import '../engine/options/book_file_option.dart';

class BookFilePathSettingDialog extends StatelessWidget {
  BookFilePathSettingDialog({required this.edax, Key? key}) : super(key: key);

  final Edax edax;
  final _option = const BookFileOption();
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting),
        content: FutureBuilder<String>(
          future: _option.val,
          builder: (_, snapshot) => Form(
            key: _formKey,
            child: TextFormField(
              controller: _textController..text = snapshot.hasData ? snapshot.data! : '',
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (path) {
                if (path == null) return null;
                if (path.isEmpty) return null; // use default book
                if (!File(path).existsSync()) return AppLocalizations.of(context)!.userSpecifiedFileNotFound;
              },
            ),
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
              await _option.update(newBookFilePath);
              // TODO: load asynchronously. this is slow when book is big.
              edax.lib.edaxBookLoad(newBookFilePath);
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
