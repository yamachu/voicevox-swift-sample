native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip:
	curl https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.16/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip -L -o $@

native/voicevox_core.xcframework: native/voicevox_core-ios-xcframework-cpu-0.15.0-preview.16.zip
	unzip -o $< -d native
