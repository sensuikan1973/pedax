import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

@isTest
void fakeFileSelector() {
  FileSelectorPlatform.instance = FakeFileSelector();
}

@isTest
class FakeFileSelector extends Fake
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        FileSelectorPlatform {
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async =>
      null;
}
