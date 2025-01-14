.PHONY: setup patch/voicevox_core
setup: native/onnxruntime.xcframework patch/voicevox_core

native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core.xcframework: native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native

native/onnxruntime-ios-xcframework-1.14.1.zip:
	curl https://github.com/VOICEVOX/onnxruntime-builder/releases/download/1.14.1/onnxruntime-ios-xcframework-1.14.1.zip -L -o $@

native/onnxruntime.xcframework: native/onnxruntime-ios-xcframework-1.14.1.zip
	unzip -o $< -d native

# otool -L native/voicevox_core.xcframework/ios-arm64/libvoicevox_core.dylib をすると、1.14.0 が参照されているので、書き換える
patch/voicevox_core: native/voicevox_core.xcframework
	install_name_tool -change "@rpath/libonnxruntime.1.14.0.dylib" "@rpath/libonnxruntime.1.14.1.dylib" native/voicevox_core.xcframework/ios-arm64/libvoicevox_core.dylib
	install_name_tool -change "@rpath/libonnxruntime.1.14.0.dylib" "@rpath/libonnxruntime.1.14.1.dylib" native/voicevox_core.xcframework/ios-arm64_x86_64-simulator/libvoicevox_core.dylib
