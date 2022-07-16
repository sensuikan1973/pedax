import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../../engine/options/pedax/bestpath_count_availability_option.dart';
import '../../models/board_notifier.dart';

class BestpathCountAvailabilitySettingDialog extends StatelessWidget {
  BestpathCountAvailabilitySettingDialog({super.key});

  BestpathCountAvailabilityOption get _option => const BestpathCountAvailabilityOption();
  final _enabled = ValueNotifier<bool?>(null);

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bestpathCountAvailabilitySetting, textAlign: TextAlign.center),
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
                    Text(AppLocalizations.of(context)!.bestpathCountAvailabilityDescription),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Switch(
                      value: _enabled.value!,
                      onChanged: (final value) {
                        context.read<BoardNotifier>().switchCountBestpathAvailability(enabled: value);
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
