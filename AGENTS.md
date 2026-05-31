# Yoyotime - Project Memory

## Project Info
- Flutter project, CI builds APK via GitHub Actions
- Version: 0.1.0

## CI Workflow
- `.github/workflows/build-apk.yml`
- On push to `main`: flutter analyze → test → build APK (split-per-abi) → upload artifact
- On tag push `v*.*.*`: additionally creates GitHub Release with APK downloads

## Release Process
- Tag with `v*.*.*` (e.g. `v0.1.0`) and push: `git tag v0.1.0 && git push origin v0.1.0`
- CI auto-builds and publishes release

## App
- Package: com.yoyotime.app
- Homepage shows "Yoyotime / 悠悠好时光!" with gradient background and animation
