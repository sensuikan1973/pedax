<h1>
<img src="https://github.com/sensuikan1973/pedax/blob/main/assets/images/pedax_logo.png?raw=true" alt="pedax_logo" height="35"/>
<a href="https://sensuikan1973.github.io/pedax/">pedax</a>
</h1>

<img align="left" src="https://raw.githubusercontent.com/sensuikan1973/pedax/main/website/static/img/en/analysis_mode_board_view.png" alt="screenshot_macos" width="380" hspace="10">
<div>
  <br/>
  <br/>
  <em>pedax</em> is Board GUI with <a href="https://sensuikan1973.github.io/edax-reversi">edax</a>, which is the strongest reversi program.
  <br/>
  <br/>
  <em>pedax</em> has 4 features.
  <ul>
    <li>
      <b>Mac/Windows/Linux</b> are supported. <a href="https://sensuikan1973.github.io/pedax/">You can install from Mac App Store or Microsoft Store</a>.
    </li>
    <li>
      <b>Comfortably</b>, you can see <code>evaluation value</code>, e.g. <code>+4</code>, <code>-10</code>.
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

### setup

```sh
./scripts/setup_flutter.sh
```

### [format](https://docs.flutter.dev/development/tools/formatting)

```sh
flutter format -l 120 .
```

### [run](https://docs.flutter.dev/desktop#create-and-run)

```sh
flutter run -d macos
```

### [test](https://docs.flutter.dev/testing)

#### [widget test](https://docs.flutter.dev/testing#widget-tests)

```sh
flutter test --concurrency=1
```

#### [integration test](https://docs.flutter.dev/testing#integration-tests)

```sh
flutter test integration_test
```

#### [linter](https://dart-lang.github.io/linter/lints/)

```sh
flutter analyze .

# auto fix
# See: https://flutter.dev/docs/development/tools/flutter-fix#applying-project-wide-fixes
dart fix --apply
```

#### fetch libedax assets as pedax assets

```sh
./scripts/fetch_libedax_assets.sh
```

#### release

1. create `new_release` branch.
2. create PR by https://github.com/sensuikan1973/pedax/compare/new_release?expand=1&template=new_release.md&title=prepare+for+release+%60X%2EY%2EZ%60.
3. create release by https://github.com/sensuikan1973/pedax/actions/workflows/create_release.yaml.

##### deploy to apple store

```sh
REVISION=xxx
P8_PATH=xxx

ASC_KEY_ID=xxx \
ASC_ISSUER_ID=xxx \
APPLE_ID=xxx \
ITC_TEAM_ID=xxx \
./scripts/deploy_macos_app_to_app_store.sh -revision $REVISION -p8-file-path $P8_PATH
```

After that, submit [Apple developer console](https://developer.apple.com/account/#/overview).

##### deploy to microsoft store

1. download `pedax.msix` from the release.
2. update and submit [Microsoft developer console](https://partner.microsoft.com/ja-jp/dashboard/products/9NLNZCKH0L9H/overview).

### reference

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
