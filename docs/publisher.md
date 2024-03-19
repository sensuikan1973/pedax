# Document for Publisher [sensuikan1973](https://github.com/sensuikan1973)

## Monitoring

- [Sentry](https://sentry.io/organizations/naoki-shimizu/issues/?project=6595416)

## Upgrade external assets

```zsh
./scripts/fetch_libedax_assets.sh
```

## Deploy

### 1) Create [GitHub Release](https://github.com/sensuikan1973/pedax/releases)

Use https://github.com/sensuikan1973/pedax/actions/workflows/create_release_pr.yaml.

### 2) Deploy

#### [Mac App Store](https://apps.apple.com/app/pedax/id1557500142)

Use https://github.com/sensuikan1973/pedax/actions/workflows/deploy_macos.yaml.  
App Store Connect: https://appstoreconnect.apple.com/

#### [Microsoft Store](https://apps.microsoft.com/store/detail/pedax/9NLNZCKH0L9H)

1. download `pedax.msix` from the [GitHub Release](https://github.com/sensuikan1973/pedax/releases).
2. update and submit on [Microsoft developer console](https://partner.microsoft.com/ja-jp/dashboard/products/9NLNZCKH0L9H/overview).

## Macos/Fastlane

> Your certificate 'XXXXXXXXXX.cer' is not valid, please check end date and renew it if necessary

```sh
MATCH_GIT_BASIC_AUTHORIZATION="xxx" MATCH_PASSWORD="xxx" bundle exec fastlane match nuke distribution --platform macos --additional_cert_types mac_installer_distribution
MATCH_GIT_BASIC_AUTHORIZATION="xxx" MATCH_PASSWORD="xxx" bundle exec fastlane match appstore --platform macos --additional_cert_types mac_installer_distribution
```
