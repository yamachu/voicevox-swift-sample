//
//  ContentView.swift
//  voicevox-swift-sample
//
//  Created by Yusuke Yamada on 2025/01/15.
//

import SwiftUI
import VoicevoxCore

public struct ContentView: View {
    public var body: some View {
        VStack {
           Text(String (cString: VoicevoxCore.voicevox_get_version()))
        }
        .padding()
    }

    public init() {
    }
}

#Preview {
    ContentView()
}
