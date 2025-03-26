.PHONY: setup
setup: native/voicevox_core.xcframework native/voicevox_onnxruntime.xcframework

ARCH:=$(shell uname -m | grep -q 'x86_64' && echo "x64" || echo "arm64")
DOWNLOADER:=native/bin/downloader

CORE_TAG=0.16.0-preview.1
ONNXRUNTIME_TAG=voicevox_onnxruntime-1.17.3

$(DOWNLOADER):
	mkdir -p $(dir $@)
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/$(CORE_TAG)/download-osx-$(ARCH) -L -o $@
	chmod +x $@

native/tmp/voicevox_core-ios-xcframework.zip:
	mkdir -p $(dir $@)
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/$(CORE_TAG)/voicevox_core-ios-xcframework-cpu-$(CORE_TAG).zip -L -o $@

native/raw/osx-arm64: $(DOWNLOADER)
	$(DOWNLOADER) --exclude additional-libraries models dict --cpu-arch arm64 --os osx --c-api-version $(CORE_TAG) --onnxruntime-version $(ONNXRUNTIME_TAG) -o $@

native/raw/osx-x64: $(DOWNLOADER)
	$(DOWNLOADER) --exclude additional-libraries models dict --cpu-arch x64 --os osx --c-api-version $(CORE_TAG) --onnxruntime-version $(ONNXRUNTIME_TAG) -o $@

native/tmp/osx-arm64_x86_64/voicevox_core: native/raw/osx-arm64 native/raw/osx-x64
	mkdir -p $(dir $@)
	lipo -create \
		native/raw/osx-arm64/c_api/lib/libvoicevox_core.dylib \
		native/raw/osx-x64/c_api/lib/libvoicevox_core.dylib \
		-output $@
	install_name_tool -id "@rpath/voicevox_core.framework/voicevox_core" $@

native/raw/voicevox_core.xcframework: native/tmp/voicevox_core-ios-xcframework.zip
	unzip -o $< -d native/raw

FrameworkTemplate/voicevox_core.framework/Headers/voicevox_core.h: native/raw/osx-arm64
	mkdir -p $(dir $@)
	cp -r $</c_api/include/voicevox_core.h $@

native/tmp/osx/voicevox_core.framework: FrameworkTemplate/voicevox_core.framework/Headers/voicevox_core.h native/tmp/osx-arm64_x86_64/voicevox_core
	mkdir -p $(dir $@)
	cp -r FrameworkTemplate/voicevox_core.framework $(dir $@)
	cp native/tmp/osx-arm64_x86_64/voicevox_core $@/voicevox_core

native/voicevox_core.xcframework: native/tmp/osx/voicevox_core.framework native/raw/voicevox_core.xcframework
	xcodebuild -create-xcframework \
		-framework native/raw/voicevox_core.xcframework/ios-arm64/voicevox_core.framework \
		-framework native/raw/voicevox_core.xcframework/ios-arm64_x86_64-simulator/voicevox_core.framework \
		-framework native/tmp/osx/voicevox_core.framework \
		-output $@

# 

native/tmp/voicevox_onnxruntime-ios-xcframework.zip:
	mkdir -p $(dir $@)
	curl https://github.com/VOICEVOX/onnxruntime-builder/releases/download/$(ONNXRUNTIME_TAG)/voicevox_onnxruntime-ios-xcframework-1.17.3.zip -L -o $@

native/tmp/osx-arm64_x86_64/voicevox_onnxruntime: native/raw/osx-arm64 native/raw/osx-x64
	mkdir -p $(dir $@)
	lipo -create \
		native/raw/osx-arm64/onnxruntime/lib/libvoicevox_onnxruntime.1.17.3.dylib \
		native/raw/osx-x64/onnxruntime/lib/libvoicevox_onnxruntime.1.17.3.dylib \
		-output $@
	install_name_tool -id "@rpath/voicevox_onnxruntime.framework/voicevox_onnxruntime" $@

native/raw/voicevox_onnxruntime.xcframework: native/tmp/voicevox_onnxruntime-ios-xcframework.zip
	unzip -o $< -d native/raw

native/tmp/osx/voicevox_onnxruntime.framework: native/tmp/osx-arm64_x86_64/voicevox_onnxruntime
	mkdir -p $(dir $@)
	cp -r FrameworkTemplate/voicevox_onnxruntime.framework $@
	cp native/tmp/osx-arm64_x86_64/voicevox_onnxruntime $@/voicevox_onnxruntime

native/voicevox_onnxruntime.xcframework: native/tmp/osx/voicevox_onnxruntime.framework native/raw/voicevox_onnxruntime.xcframework
	xcodebuild -create-xcframework \
		-framework native/raw/voicevox_onnxruntime.xcframework/ios-arm64/voicevox_onnxruntime.framework \
		-framework native/raw/voicevox_onnxruntime.xcframework/ios-arm64_x86_64-simulator/voicevox_onnxruntime.framework \
		-framework native/tmp/osx/voicevox_onnxruntime.framework \
		-output $@

xcode/swiftpm:
	xed .

xcode:
	open App/voicevox-swift-sample.xcodeproj
