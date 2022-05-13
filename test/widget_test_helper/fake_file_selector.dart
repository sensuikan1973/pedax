import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

@isTest
void mockFileSelector() {
  FileSelectorPlatform.instance = FakeFileSelector();
}

// ignore: prefer_mixin
class FakeFileSelector extends Fake with MockPlatformInterfaceMixin implements FileSelectorPlatform {
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async =>
      null;
}
