# Document for Publisher [sensuikan1973](https://github.com/sensuikan1973)

## monitoring

- [Sentry](https://sentry.io/organizations/naoki-shimizu/issues/?project=6595416)

## upgrade external assets

```zsh
./scripts/fetch_libedax_assets.sh
```

## deploy

### 1) create [GitHub Release](https://github.com/sensuikan1973/pedax/releases)

Use https://github.com/sensuikan1973/pedax/actions/workflows/create_release_pr.yaml.

### 2) deploy

#### [Mac App Store](https://apps.apple.com/app/pedax/id1557500142)

```zsh
REVISION=xxx
P8_PATH=xxx
SENTRY_DSN=xxx

ASC_KEY_ID=xxx \
ASC_ISSUER_ID=xxx \
APPLE_ID=xxx \
ITC_TEAM_ID=xxx \
./scripts/deploy_macos_app_to_app_store.sh \
-revision "$REVISION" -p8-file-path "$P8_PATH" -sentry-dsn "$SENTRY_DSN" --skip-test
```

After that, submit on [Apple developer console](https://developer.apple.com/account/#/overview).

#### [Microsoft Store](https://apps.microsoft.com/store/detail/pedax/9NLNZCKH0L9H)

1. download `pedax.msix` from the [GitHub Release](https://github.com/sensuikan1973/pedax/releases).
2. update and submit on [Microsoft developer console](https://partner.microsoft.com/ja-jp/dashboard/products/9NLNZCKH0L9H/overview).
