# pedax

<p align="center">
<img src="https://github.com/sensuikan1973/pedax/blob/main/assets/images/pedax_logo.png?raw=true" alt="pedax_logo" width="200"/>
</p>
<br/>
TODO: paste GUI image.

_pedax_ is Board with [edax](https://sensuikan1973.github.io/edax-reversi) which is the strongest othello program.

- support Mac/Windows/Linux.
- you can see `eval value`(e.g. `+4`, `-10`) comfortably.

---

## Development

[![flutter-channel](https://img.shields.io/badge/Flutter-dev-64B5F6.svg?logo=flutter)](https://flutter.dev/docs/development/tools/sdk/releases)  
![Flutter CI](https://github.com/sensuikan1973/pedax/workflows/Flutter%20CI/badge.svg)
![Flutter Build](https://github.com/sensuikan1973/pedax/workflows/Flutter%20Build/badge.svg)
![Flutter Integration Test](https://github.com/sensuikan1973/pedax/workflows/Flutter%20Integration%20Test/badge.svg)
[![codecov](https://codecov.io/gh/sensuikan1973/pedax/branch/main/graph/badge.svg?token=DoMWFhOPN3)](https://codecov.io/gh/sensuikan1973/pedax)

### commands

#### format

```sh
flutter format -l 120 .
```

#### run

```sh
flutter run -d macos
```

#### test

##### widget test

```sh
flutter test
```

##### integration test

```sh
flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart -d mac
```

#### analyze

```sh
flutter analyze .
```

#### fetch libedax assets as pedax assets for Linux/Windows

```sh
./scripts/fetch_libedax_assets.sh
```

### reference

- [Desktop support for Flutter](https://flutter.dev/desktop)
- [Binding to native code using dart:ffi](https://flutter.dev/docs/development/platform-integration/c-interop)
- [macos](https://developer.apple.com/account/#/overview)
  - [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
    - [(archived document) About App Sandbox](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AboutAppSandbox/AboutAppSandbox.html#//apple_ref/doc/uid/TP40011183-CH1-SW1)
  - [Harded Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
  - [Distribute outside the Mac App Store (macOS)](https://help.apple.com/xcode/mac/current/#/dev033e997ca)
  - [Notarizing macOS Software Before Distribution](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution)
- windows
  - [windows sandbox](https://docs.microsoft.com/ja-jp/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview)
- linux
  - [Build and release a Linux app](https://flutter.dev/docs/deployment/linux)
