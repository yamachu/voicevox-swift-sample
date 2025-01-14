# Voicevox Swift Sample

[voicevox_core 0.15.0-preview.16](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.15.0-preview.16) を Swift から利用するサンプルプロジェクト。
音声合成などは行わず、一旦リンクが出来て voicevox_core から提供されている関数が呼び出せるかを確認できるかどうかにフォーカスしている。

## 使用ライブラリ

- [VOICEVOX/onnxruntime_builder 1.14.1](https://github.com/VOICEVOX/onnxruntime-builder/releases/tag/1.14.1)
  - Pods などでダウンロードできる onnxruntime は StaticLibrary の形式になっているが、DynamicLibrary が voicevox core から利用するために必要であるため、カスタムされた onnxruntime を利用している。
- [VOICEVOX/voicevox_core 0.15.0-preview.16](https://github.com/VOICEVOX/voicevox_core/releases/tag/0.15.0-preview.16)
  - 音声合成エンジン本体。iOS 向けのビルドがあるなかでの最新。
