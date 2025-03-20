import AVFoundation
import SwiftUI
import voicevox_core

struct SpeechSynthesisView: View {
    @EnvironmentObject var voicevoxEnvironment: VoicevoxEnvironmentObject
    @State private var inputText: String = ""
    @State private var isSynthesizing: Bool = false

    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            TextField("Enter text to synthesize", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                self.isSynthesizing = true
                synthesizeSpeech(text: inputText)
                self.isSynthesizing = false
            }) {
                Text("Synthesize")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(
                inputText.isEmpty || voicevoxEnvironment.selectedVoiceModel == nil || isSynthesizing
            )
        }
        .padding()
    }

    private func synthesizeSpeech(text: String) {
        guard
            let dictPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(dictionaryExtractPath),
            let modelBasePath = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            )
            .first?
            .appendingPathComponent(modelsDownloadPath),
            let model = voicevoxEnvironment.selectedVoiceModel
        else {
            print("Failed to get dictionary path")
            return
        }

        let modelPath = modelBasePath.appendingPathComponent(model.vvm)
        let styleId = model.styleId

        // 1. OpenJTalk辞書の初期化
        var openJtalk: OpaquePointer? = nil
        let openJtalkResult = voicevox_open_jtalk_rc_new(dictPath.path, &openJtalk)
        guard openJtalkResult.magnitude == VOICEVOX_RESULT_OK.rawValue, openJtalk != nil else {
            print(
                "Failed to initialize OpenJTalk: \(voicevox_error_result_to_message(openJtalkResult))"
            )
            return
        }

        // 2. ONNX Runtimeの初期化
        var onnxruntime: OpaquePointer? = nil
        #if os(iOS)
            let onnxResult = voicevox_onnxruntime_init_once(&onnxruntime)
        #else
            let onnxResult = voicevox_onnxruntime_load_once(
                voicevox_make_default_load_onnxruntime_options(), &onnxruntime)
        #endif
        guard onnxResult.magnitude == VOICEVOX_RESULT_OK.rawValue, onnxruntime != nil else {
            print(
                "Failed to initialize ONNX Runtime: \(voicevox_error_result_to_message(onnxResult))"
            )
            voicevox_open_jtalk_rc_delete(openJtalk)
            return
        }

        // 3. Synthesizerの初期化
        var synthesizer: OpaquePointer? = nil
        var initializeOptions = voicevox_make_default_initialize_options()
        let synthesizerResult = voicevox_synthesizer_new(
            onnxruntime, openJtalk, initializeOptions, &synthesizer)
        guard synthesizerResult.magnitude == VOICEVOX_RESULT_OK.rawValue, synthesizer != nil else {
            print(
                "Failed to initialize Synthesizer: \(voicevox_error_result_to_message(synthesizerResult))"
            )
            voicevox_open_jtalk_rc_delete(openJtalk)
            return
        }

        // 4. 音声モデルの読み込み
        var voiceModel: OpaquePointer? = nil
        var modelResult = voicevox_voice_model_file_open(
            modelPath.standardizedFileURL.path, &voiceModel)
        guard modelResult.magnitude == VOICEVOX_RESULT_OK.rawValue, voiceModel != nil else {
            print("Failed to load voice model: \(voicevox_error_result_to_message(modelResult))")
            voicevox_synthesizer_delete(synthesizer)
            voicevox_open_jtalk_rc_delete(openJtalk)
            return
        }

        // NOTE: Debug executableしてる状態で、かつVoicevoxOnnxruntimeを使用しているとクラッシュする
        let loadModelResult = voicevox_synthesizer_load_voice_model(synthesizer, voiceModel)
        guard loadModelResult.magnitude == VOICEVOX_RESULT_OK.rawValue else {
            print(
                "Failed to load voice model into synthesizer: \(voicevox_error_result_to_message(loadModelResult))"
            )
            voicevox_voice_model_file_delete(voiceModel)
            voicevox_synthesizer_delete(synthesizer)
            voicevox_open_jtalk_rc_delete(openJtalk)
            return
        }

        // FIXME: 型いい感じにしたい
        var modelId:
            (
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        voicevox_voice_model_file_id(voiceModel, &modelId)

        // 5. TTSの実行
        var wavLength: UInt = 0
        var wavData: UnsafeMutablePointer<UInt8>? = nil
        var ttsOptions = voicevox_make_default_tts_options()
        let ttsResult = voicevox_synthesizer_tts(
            synthesizer, text, UInt32(styleId), ttsOptions, &wavLength, &wavData)
        guard ttsResult.magnitude == VOICEVOX_RESULT_OK.rawValue, let wavData = wavData else {
            print("Failed to synthesize speech: \(voicevox_error_result_to_message(ttsResult))")
            voicevox_synthesizer_unload_voice_model(synthesizer, &modelId)
            voicevox_voice_model_file_delete(voiceModel)
            voicevox_synthesizer_delete(synthesizer)
            voicevox_open_jtalk_rc_delete(openJtalk)
            return
        }

        let wavBuffer = Data(bytes: wavData, count: Int(wavLength))

        do {
            audioPlayer = try AVAudioPlayer(data: wavBuffer)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play WAV data: \(error.localizedDescription)")
        }

        // 6. リソースの解放
        voicevox_wav_free(wavData)
        voicevox_synthesizer_unload_voice_model(synthesizer, &modelId)
        voicevox_voice_model_file_delete(voiceModel)
        voicevox_synthesizer_delete(synthesizer)
        voicevox_open_jtalk_rc_delete(openJtalk)

        return
    }

}
