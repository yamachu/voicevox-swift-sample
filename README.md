# Voicevox Swift Sample

[voicevox_core 0.16.0-preview.1](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.16.0-preview.1) を Swift から利用するサンプルプロジェクト。
iOS と macOS の両方で動作する。

## 使用ライブラリ

- [VOICEVOX/onnxruntime_builder voicevox_onnxruntime-1.17.3](https://github.com/VOICEVOX/onnxruntime-builder/releases/tag/voicevox_onnxruntime-1.17.3)
  - Voicevox向けにカスタマイズされた ONNX Runtime。その中でも本番 VVM （提供されている Voicevox で使用出来る音声モデル）が利用できるようにビルドされたもの。
- [VOICEVOX/voicevox_core 0.16.0-preview.1](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.16.0-preview.1)
  - 音声合成エンジン本体。

## ビルド

### 事前準備

依存ライブラリのダウンロードやパッチを Makefile で一括で行う。

```sh
$ make setup
```

### ビルド

Xcode で行う場合は、`voicevox-swift-sample.xcodeproj` を開いてビルドする。

```sh
$ open voicevox-swift-sample.xcodeproj
```
