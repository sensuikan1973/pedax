import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../../engine/options/native/book_file_option.dart';
import '../../models/board_notifier.dart';

@immutable
class BookFilePathSettingDialog extends StatefulWidget {
  const BookFilePathSettingDialog({super.key});

  @override
  State<BookFilePathSettingDialog> createState() => _BookFilePathSettingDialogState();
}

class _BookFilePathSettingDialogState extends State<BookFilePathSettingDialog> {
  final _option = BookFileOption();
  final _selectedFilePath = ValueNotifier<String?>(null);

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting, textAlign: TextAlign.center),
        content: FutureBuilder<String>(
          future: _option.val,
          builder: (final _, final snapshot) {
            if (snapshot.hasData) _selectedFilePath.value = snapshot.data;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    const typeGroup = XTypeGroup(label: 'edax book file', extensions: ['dat']);
                    final openedFile = await openFile(acceptedTypeGroups: [typeGroup]);
                    if (openedFile != null) _selectedFilePath.value = openedFile.path;
                  },
                  child: Text(AppLocalizations.of(context)!.chooseBookFile),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedFilePath,
                  builder: (final _, final value, final __) {
                    if (value == null) return const Text(' ');
                    return Expanded(child: SelectableText(value));
                  },
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelOnDialog),
          ),
          TextButton(
            onPressed: () async {
              if (_selectedFilePath.value == null) return;

              final newBookFilePath = _selectedFilePath.value!;
              final isValidBookFilePath = _validateBookFilePath(newBookFilePath);
              if (!isValidBookFilePath) {
                if (!context.mounted) return;
                return await showDialog(
                  context: context,
                  builder: (_) => SimpleDialog(
                    title: Text(AppLocalizations.of(context)!.bookFilePathInvalidMessage),
                  ),
                );
              }

              final currentBookFilePath = await _option.val;
              if (context.mounted) {
                if (newBookFilePath == currentBookFilePath) return Navigator.pop(context);
                await _option.update(newBookFilePath);
                if (context.mounted) {
                  context.read<BoardNotifier>().requestBookLoad(newBookFilePath);
                  Navigator.pop(context);
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      );

  bool _validateBookFilePath(String filePath) {
    // See: https://github.com/sensuikan1973/pedax/issues/592
    if (Platform.isWindows) {
      return RegExp(r'^([ -~]|[¥])+$').hasMatch(filePath); // ref: https://stackoverflow.com/a/14608823
    }
    return true;
  }
}
