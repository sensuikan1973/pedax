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

### Run

```sh
./scripts/setup_flutter.sh
flutter run --dart-define "SENTRY_DSN=xxx" # env is optional
```

### Architecture

The technical point of pedax is as follows.

- pedax needs to call _Expensive_ _Native(C)_ logic such as computing evaluation value.
- _Native(C)_ logic needs allocated large data. It's desirable to daemonize _Native(C)_ process on background.

So, I have to use [isolate](https://dart.dev/guides/language/concurrency) with ffi([libedax4dart](https://github.com/sensuikan1973/libedax4dart)) skillfully to achieve _seamless non-blocking_ UI.

```mermaid
%% https://mermaid-js.github.io/mermaid/#/sequenceDiagram
sequenceDiagram
  actor User
  participant MainIsolate as Main Isolate
  participant EdaxServer as Edax Server
  participant EphemeralWorker as Ephemeral Worker
  participant EdaxProcess as Edax Process [C]

  link EdaxServer: source @ https://github.com/sensuikan1973/pedax/tree/main/lib/engine
  link EdaxServer: caller @ https://github.com/sensuikan1973/pedax/blob/main/lib/models/board_notifier.dart
  link EphemeralWorker: source @ https://github.com/sensuikan1973/pedax/tree/main/lib/engine
  link EdaxProcess: binding source (Dart) @ https://github.com/sensuikan1973/libedax4dart
  link EdaxProcess: origin source(C) @ https://github.com/sensuikan1973/edax-reversi/tree/libedax_sensuikan1973

  User ->> MainIsolate: launch pedax
  MainIsolate ->> EdaxServer: spawn and notify my SendPort
  EdaxServer ->> MainIsolate: notify my SendPort<br/>and start listening
  EdaxServer ->> EdaxProcess: initialize via ffi

  User ->> MainIsolate: action (e.g. tap)
  MainIsolate ->> EdaxServer: request EdaxCommand<br/>via SendPort

  alt light EdaxCommand
    EdaxServer ->> EdaxProcess: stop EdaxCommand being executed via ffi
    EdaxServer ->> EdaxProcess: execute requested EdaxCommand via ffi
    EdaxProcess ->> EdaxServer: return result
    EdaxServer ->> MainIsolate: notify result via SenPort
    MainIsolate ->> MainIsolate: update UI
  else heavy EdaxCommand
    note right of EdaxServer: spawn another isolate not to block EdaxServer.<br>Then, EdaxServer can accept other requests.
    EdaxServer ->>+ EphemeralWorker: spawn and notify Main Isolate SendPort
    EphemeralWorker ->> EdaxProcess: stop EdaxCommand being executed via ffi
    EphemeralWorker ->> EdaxProcess: execute requested EdaxCommand via ffi
    note over EdaxProcess: heavy...
    EdaxProcess ->> EphemeralWorker: return result
    EphemeralWorker ->>- MainIsolate: notify result via SenPort
    MainIsolate ->> MainIsolate: update UI
  end
```

### References

- [`important` issues and PR](https://github.com/sensuikan1973/pedax/issues?q=label%3Aimportant+)
- [Flutter on Desktop](https://flutter.dev/desktop)
  - [official prototype Desktop Plugins](https://github.com/google/flutter-desktop-embedding/tree/master/plugins)
  - [official desktop app sample | Photo Search app](https://github.com/flutter/samples/tree/master/desktop_photo_search)
  - Real World example
    - [Flutter Gallery](https://github.com/flutter/gallery)
    - [authpass](https://github.com/authpass/authpass)
    - [Mixin Messenger Desktop](https://github.com/MixinNetwork/flutter-app)
      - useful plugins: https://github.com/MixinNetwork/flutter-plugins
