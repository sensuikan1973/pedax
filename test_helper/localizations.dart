import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

@isTest
Future<AppLocalizations> loadLocalizations(Locale locale) async => AppLocalizations.delegate.load(locale);
