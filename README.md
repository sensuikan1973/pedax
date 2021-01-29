# pedax

<p align="center">
<img src="https://github.com/sensuikan1973/pedax/blob/main/assets/pedax_logo.png?raw=true" alt="pedax_logo" width="200"/>
</p>
<br/>

TODO: describe

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

#### build

```sh
flutter build macos
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
flutter analyze
```

#### fetch libedax assets as pedax assets

```sh
./scripts/fetch_libedax_assets.sh
```

### reference

- [Desktop support for Flutter](https://flutter.dev/desktop)
- [Effective Dart: Documentation](https://dart.dev/guides/language/effective-dart/documentation)
