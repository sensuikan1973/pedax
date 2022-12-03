<h1>
<img src="https://github.com/sensuikan1973/pedax/blob/main/assets/images/pedax_logo.png?raw=true" alt="pedax_logo" height="35"/>
<a href="https://sensuikan1973.github.io/pedax/">pedax</a>
</h1>

<img align="left" src="https://raw.githubusercontent.com/sensuikan1973/pedax/main/website/static/img/en/analysis_mode_board_view.png" alt="screenshot_macos" width="380" hspace="10">
<div>
  <br/>
  <br/>
  <em>pedax</em> is Reversi Board GUI with <a href="https://sensuikan1973.github.io/edax-reversi">edax</a>, which is the strongest reversi program.
  <br/>
  <br/>
  <em>pedax</em> has 4 features.
  <ul>
    <li>
      <b>Mac/Windows/Linux</b> are supported. <a href="https://sensuikan1973.github.io/pedax/">You can install from Mac App Store or Microsoft Store</a>.
    </li>
    <li>
      <b>Seamlessly</b>, you can see <code>evaluation value</code>, e.g. <code>+4</code>, <code>-10</code>.
    </li>
    <li>
      <b>Customizable</b> important options, e.g. <code>book file path</code>, <code>search level</code>, <code>advanced indicator</code>.
    </li>
    <li>
      <b>2 languages (English, Japanese)</b> are supported.
    </li>
  </ul>
</div>
<br clear="all">

---

## Development

![Flutter CI](https://github.com/sensuikan1973/pedax/workflows/Flutter%20CI/badge.svg)
![Flutter Build](https://github.com/sensuikan1973/pedax/workflows/Flutter%20Build/badge.svg)
[![codecov](https://codecov.io/gh/sensuikan1973/pedax/branch/main/graph/badge.svg?token=DoMWFhOPN3)](https://codecov.io/gh/sensuikan1973/pedax)

### run

```sh
./scripts/setup_flutter.sh

# https://docs.flutter.dev/desktop#create-and-run
flutter run --dart-define "SENTRY_DSN=xxx" # env is optional.
```

### reference

- [`important` issues and PR](https://github.com/sensuikan1973/pedax/issues?q=label%3Aimportant+)
- [Desktop support for Flutter](https://flutter.dev/desktop)
  - [Desktop Plugins](https://github.com/google/flutter-desktop-embedding/tree/master/plugins)
  - [official experimental desktop app sample](https://github.com/flutter/samples/tree/master/experimental/desktop_photo_search)
  - [Real World example "Flutter Gallery"](https://github.com/flutter/gallery)
  - [Real World example "authpass"](https://github.com/authpass/authpass)
  - [Real World example "Mixin Messenger Desktop"](https://github.com/MixinNetwork/flutter-app)
    - plugins: https://github.com/MixinNetwork/flutter-plugins
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
- [windows](https://partner.microsoft.com/ja-jp/dashboard/windows/overview)
  - [How to publish your MSIX package to the Microsoft Store?](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)
  - [windows sandbox](https://docs.microsoft.com/ja-jp/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview)
  - [DevOps for Windows Desktop Apps Using GitHub Actions](https://github.com/microsoft/github-actions-for-desktop-apps)
- linux
  - [Build and release a Linux app](https://flutter.dev/docs/deployment/linux)
- [Sentry](https://sentry.io/organizations/naoki-shimizu/issues/?project=6595416)
