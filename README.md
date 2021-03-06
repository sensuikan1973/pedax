<h1>
<img src="https://github.com/sensuikan1973/pedax/blob/main/assets/images/pedax_logo.png?raw=true" alt="pedax_logo" height="35"/>
<span>pedax</span>
</h1>

<img align="left" src="https://user-images.githubusercontent.com/23427957/111070799-ac371d80-8516-11eb-819b-f0d417e1e470.png" alt="screenshot_macos" height="350" hspace="10">
<div>
  <br/>
  <br/>
  <em>pedax</em> is Board GUI with <a href="https://sensuikan1973.github.io/edax-reversi">edax</a>, which is the strongest othello program.
  <br/>
  <br/>
  <em>pedax</em> has 4 features.
  <li><b>comfortably</b>, you can see <code>evaluation value</code> (e.g. <code>+4</code>, <code>-10</code>).</li>
  <li>support <b>Mac/Windows/Linux</b>.</li>
  <li>support important options (e.g. <code>book file path</code>, <code>search level</code>).</li>
  <li>support English/Japanese.</li>
</div>
<br clear="all">

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
flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart -d macos --keep-app-running
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
  - [Desktop Plugins](https://github.com/google/flutter-desktop-embedding/tree/master/plugins)
  - [official experimental desktop app sample](https://github.com/flutter/samples/tree/master/experimental/desktop_photo_search)
- [Binding to native code using dart:ffi](https://flutter.dev/docs/development/platform-integration/c-interop)
- [macos](https://developer.apple.com/account/#/overview)
  - [Flutter macOS-specific support](https://flutter.dev/desktop#macos-specific-support)
  - [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
    - [Enabling App Sandbox](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html#//apple_ref/doc/uid/TP40011195-CH4-SW1)
    - [About App Sandbox](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AboutAppSandbox/AboutAppSandbox.html#//apple_ref/doc/uid/TP40011183-CH1-SW1)
  - [Harded Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
  - [macOS distribution](https://developer.apple.com/jp/macos/distribution/)
  - [Distribute outside the Mac App Store (macOS)](https://help.apple.com/xcode/mac/current/#/dev033e997ca)
  - [Notarizing macOS Software Before Distribution](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution)
- windows
  - [windows sandbox](https://docs.microsoft.com/ja-jp/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview)
  - [DevOps for Windows Desktop Apps Using GitHub Actions](https://github.com/microsoft/github-actions-for-desktop-apps)
- linux
  - [Build and release a Linux app](https://flutter.dev/docs/deployment/linux)
