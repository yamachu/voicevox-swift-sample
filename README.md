# Voicevox Swift Sample

[voicevox_core 0.17.0](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.17.0) を Swift から利用するサンプルプロジェクト。
iOS と macOS の両方で動作する。

## 使用ライブラリ

- [VOICEVOX/onnxruntime_builder voicevox_onnxruntime-1.23.2](https://github.com/VOICEVOX/onnxruntime-builder/releases/tag/voicevox_onnxruntime-1.23.2)
  - Voicevox向けにカスタマイズされた ONNX Runtime。その中でも本番 VVM （提供されている Voicevox で使用出来る音声モデル）が利用できるようにビルドされたもの。
- [VOICEVOX/voicevox_core 0.17.0](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.17.0)
  - 音声合成エンジン本体。
- [VoicevoxCoreSwift](https://github.com/yamachu/VoicevoxCoreSwift)
  - voicevox_core を Swift から利用するためのラッパーライブラリ。
- [VoicevoxCoreSwiftPM](https://github.com/yamachu/VoicevoxCoreSwiftPM)
  - voicevox_core の xcframework を SwiftPM から利用するためのパッケージ。

## ビルド

### 事前準備

依存ライブラリのダウンロードやパッチを Makefile で一括で行う。

```sh
$ make setup
```

### ビルド

Xcode で行う場合は、`voicevox-swift-sample.xcodeproj` を開いてビルドする。

```sh
$ make xcode
```

## macOS でのコード署名について

配布されている `voicevox_core` / `voicevox_onnxruntime` は VOICEVOX 側の
Developer ID (Team ID: `DNQ8BH9GZG`) で署名されている。

一方 Hardened Runtime の Library Validation は「アプリ本体と同じ Team ID」または
Apple 署名のライブラリしかロードを許可しないため、そのままでは起動時に以下のエラーで落ちる。

```
dyld: Library not loaded: @rpath/voicevox_core.framework/voicevox_core
  Reason: ... mapping process and mapped file (non-platform) have different Team IDs
```

（`.app` に埋め込まれる framework は Xcode の Embed & Sign で自分の証明書に再署名されるが、
Xcode から Run した場合は `DYLD_FRAMEWORK_PATH` 経由で DerivedData 内の
再署名前バイナリが先に解決されるため発生する）

本リポジトリでは App ターゲットに Library Validation の例外を付与して回避している。

- ビルド設定: `RUNTIME_EXCEPTION_DISABLE_LIBRARY_VALIDATION = YES`
- entitlement: `com.apple.security.cs.disable-library-validation`
- Xcode UI では Signing & Capabilities → Hardened Runtime → "Disable Library Validation"

設定済みのため利用者側での追加作業は不要。App Sandbox との併用も可能で、公証 (notarization) も通る。
