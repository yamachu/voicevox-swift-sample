native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core.xcframework: native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native

native/onnxruntime-ios-xcframework-1.14.1.zip:
	curl https://github.com/VOICEVOX/onnxruntime-builder/releases/download/1.14.1/onnxruntime-ios-xcframework-1.14.1.zip -L -o $@

native/onnxruntime.xcframework: native/onnxruntime-ios-xcframework-1.14.1.zip
	unzip -o $< -d native
