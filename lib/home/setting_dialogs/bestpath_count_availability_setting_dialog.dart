import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../engine/options/pedax/bestpath_count_availability_option.dart';
import '../../models/board_notifier.dart';

final _documentationUrlOfBestpathCount = Uri.https(
  'sensuikan1973.github.io',
  'libedax4dart/libedax4dart/LibEdax/edaxBookCountBestpath.html',
);

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
                    ElevatedButton(
                      onPressed: () async {
                        if (await canLaunchUrl(_documentationUrlOfBestpathCount)) {
                          await launchUrl(_documentationUrlOfBestpathCount);
                        }
                      },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                      child: Text(
                        AppLocalizations.of(context)!.bestpathCountAvailabilityDocumentationLink,
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
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
