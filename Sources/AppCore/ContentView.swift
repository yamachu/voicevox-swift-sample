//
//  ContentView.swift
//  voicevox-swift-sample
//
//  Created by Yusuke Yamada on 2025/01/15.
//

import SwiftUI
import voicevox_core

public struct ContentView: View {
    @StateObject private var voicevoxEnvironmentObject = VoicevoxEnvironmentObject()

    public var body: some View {
        VStack {
            Text(String(cString: voicevox_get_version()))

            DictionaryDownloaderView()
                .padding()
                .environmentObject(voicevoxEnvironmentObject)
        }
        .padding()
    }

    public init() {
    }
}

#Preview {
    ContentView()
}
