import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';

@isTest
void mockPackageInfo() {
  PackageInfo.setMockInitialValues(
    appName: 'pedax.test',
    packageName: 'sensuikan1973.pedax.test',
    version: '0.0.0.',
    buildNumber: '1',
    buildSignature: 'foo',
    installerStore: null,
  );
}
