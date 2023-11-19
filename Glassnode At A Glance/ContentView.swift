//
//  ContentView.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 17.11.23.
//

import SwiftUI

struct ContentView: View {
    @State private var apiKey: String = ""
    @State private var apiKeyPreview: String = ""
    @State private var isApiKeyPresent: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading) {
                Text("This is not an official app. Therefore, you need to provide your own API key to get widgets working.")
                    .opacity(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)
                
                
                HStack(spacing: 12) {
                    TextField("Your API Key", text: $apiKey)
                        .disableAutocorrection(true)
                    
                    Button("Save API Key") {
                        saveApiKey()
                    }.keyboardShortcut(.defaultAction)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 0)
            
            Spacer()
            Divider()
            
            HStack {
                if isApiKeyPresent {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(apiKeyPreview)")
                    }
                    Spacer()
                }
                
                Link(
                    "Get API Key in Glassnode Studio",
                    destination: URL(string: "https://studio.glassnode.com/settings/api")!
                )
            }
            .padding(.all, 8.0)
        }
        .onAppear() {
            loadApiKey()
        }
    }
    

    private func saveApiKey() {
        if apiKey == "" {
            KeychainStore.shared.setApiKey(nil)
        } else {
            KeychainStore.shared.setApiKey(apiKey)
        }
        loadApiKey()
    }

    private func loadApiKey() {
        
        if let key = KeychainStore.shared.getApiKey(), !key.isEmpty {
            let previewStart = String(key.prefix(4))
            let previewEnd = String(key.suffix(4))
            apiKeyPreview = "\(previewStart)...\(previewEnd)"
            isApiKeyPresent = true
        } else {
            isApiKeyPresent = false
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 160)
}
