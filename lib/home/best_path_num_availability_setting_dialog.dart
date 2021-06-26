import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../engine/options/best_path_num_availability_option.dart';
import '../models/board_notifier.dart';

const _documentationLinkOfBestPathNum =
    'https://sensuikan1973.github.io/libedax4dart/libedax4dart/LibEdax/computeBestPathNumWithLink.html';

class BestPathNumAvailabilitySettingDialog extends StatelessWidget {
  BestPathNumAvailabilitySettingDialog({final Key? key}) : super(key: key);

  BestPathNumAvailabilityOption get _option => const BestPathNumAvailabilityOption();
  final _enabled = ValueNotifier<bool?>(null);

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bestPathNumAvailabilitySetting, textAlign: TextAlign.center),
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
                    Text(AppLocalizations.of(context)!.bestPathNumAvailabilityDescription),
                    ElevatedButton(
                      onPressed: () async {
                        if (await canLaunch(_documentationLinkOfBestPathNum)) {
                          await launch(_documentationLinkOfBestPathNum);
                        }
                      },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                      child: Text(
                        AppLocalizations.of(context)!.bestPathNumAvailabilityDocumentationLink,
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Switch(
                      value: _enabled.value!,
                      onChanged: (final value) {
                        context.read<BoardNotifier>().switchBestPathNumAvailability(enabled: value);
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
