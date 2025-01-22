.PHONY: setup patch/voicevox_core
setup: native/fat_onnxruntime.xcframework native/fat_voicevox_core.xcframework

native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-osx-arm64-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core-osx-x64-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-osx-x64-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core.xcframework: native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native

native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16: native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native

native/voicevox_core-osx-x64-cpu-0.15.0-preview.16: native/voicevox_core-osx-x64-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native

native/voicevox_core-osx:
	mkdir -p $@

native/voicevox_core-osx/libvoicevox_core.dylib: native/voicevox_core-osx native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16 native/voicevox_core-osx-x64-cpu-0.15.0-preview.16
	lipo -create \
		native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16/libvoicevox_core.dylib \
		native/voicevox_core-osx-x64-cpu-0.15.0-preview.16/libvoicevox_core.dylib \
		-output $@

native/voicevox_core-osx/Headers: native/voicevox_core.xcframework
	cp -r $</ios-arm64/Headers $@

native/fat_voicevox_core.xcframework: native/voicevox_core-osx/libvoicevox_core.dylib native/voicevox_core-osx/Headers native/voicevox_core.xcframework patch/voicevox_core
	xcodebuild -create-xcframework \
		-library native/voicevox_core-osx/libvoicevox_core.dylib \
		-headers native/voicevox_core-osx/Headers \
		-library native/voicevox_core.xcframework/ios-arm64/libvoicevox_core.dylib \
		-headers native/voicevox_core.xcframework/ios-arm64/Headers \
		-library native/voicevox_core.xcframework/ios-arm64_x86_64-simulator/libvoicevox_core.dylib \
		-headers native/voicevox_core.xcframework/ios-arm64_x86_64-simulator/Headers \
		-output $@

native/onnxruntime-ios-xcframework-1.14.1.zip:
	curl https://github.com/VOICEVOX/onnxruntime-builder/releases/download/1.14.1/onnxruntime-ios-xcframework-1.14.1.zip -L -o $@

native/onnxruntime.xcframework: native/onnxruntime-ios-xcframework-1.14.1.zip
	unzip -o $< -d native

native/onnxruntime-osx:
	mkdir -p $@

native/onnxruntime-osx/libonnxruntime.1.14.0.dylib: native/onnxruntime-osx native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16 native/voicevox_core-osx-x64-cpu-0.15.0-preview.16
	lipo -create \
		native/voicevox_core-osx-arm64-cpu-0.15.0-preview.16/libonnxruntime.1.14.0.dylib \
		native/voicevox_core-osx-x64-cpu-0.15.0-preview.16/libonnxruntime.1.14.0.dylib \
		-output $@

native/fat_onnxruntime.xcframework: native/onnxruntime-osx/libonnxruntime.1.14.0.dylib native/onnxruntime.xcframework
	xcodebuild -create-xcframework \
		-library native/onnxruntime-osx/libonnxruntime.1.14.0.dylib \
		-library native/onnxruntime.xcframework/ios-arm64/libonnxruntime.1.14.1.dylib \
		-library native/onnxruntime.xcframework/ios-arm64_x86_64-simulator/libonnxruntime.1.14.1.dylib \
		-output $@

# otool -L native/voicevox_core.xcframework/ios-arm64/libvoicevox_core.dylib をすると、1.14.0 が参照されているので、書き換える
patch/voicevox_core: native/voicevox_core.xcframework
	install_name_tool -change "@rpath/libonnxruntime.1.14.0.dylib" "@rpath/libonnxruntime.1.14.1.dylib" $</ios-arm64/libvoicevox_core.dylib
	install_name_tool -change "@rpath/libonnxruntime.1.14.0.dylib" "@rpath/libonnxruntime.1.14.1.dylib" $</ios-arm64_x86_64-simulator/libvoicevox_core.dylib

xcode/swiftpm:
	xed .

xcode:
	open App/voicevox-swift-sample.xcodeproj
