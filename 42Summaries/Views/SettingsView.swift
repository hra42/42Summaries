//
//  SettingsView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("summaryLength") private var summaryLength = SummaryLength.medium
    @AppStorage("enableAutoSave") private var enableAutoSave = true
    @AppStorage("ollamaModel") private var ollamaModel = "llama2"
    @AppStorage("customPrompt") private var customPrompt = "Summarize the following transcript concisely:"
    @AppStorage("transcriptionConfidence") private var transcriptionConfidence = 0.65
    @AppStorage("exportFontSize") private var exportFontSize: Double = 9.0
    @AppStorage("exportTextAlignment") private var exportTextAlignment = NSTextAlignment.left
    
    let ollamaModels = ["llama2", "mistral", "mixtral", "phi", "orca-mini"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                settingsSection("Transcription Settings") {
                    Toggle("Enable Auto-Save", isOn: $enableAutoSave)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Transcription Confidence: \(transcriptionConfidence, specifier: "%.2f")")
                        Slider(value: $transcriptionConfidence, in: 0.5...1.0, step: 0.05)
                    }
                }
                
                settingsSection("Summary Settings") {
                    Picker("Summary Length", selection: $summaryLength) {
                        ForEach(SummaryLength.allCases, id: \.self) { length in
                            Text(length.rawValue.capitalized).tag(length)
                        }
                    }
                }
                
                settingsSection("Ollama Settings") {
                    Picker("Model", selection: $ollamaModel) {
                        ForEach(ollamaModels, id: \.self) { model in
                            Text(model.capitalized).tag(model)
                        }
                    }
                    
                    Text("Custom Prompt")
                    TextEditor(text: $customPrompt)
                        .frame(height: 100)
                        .border(Color.secondary.opacity(0.2), width: 1)
                    
                    Button("Reset to Default Prompt") {
                        customPrompt = "Summarize the following transcript concisely:"
                    }
                }
                
                settingsSection("Export Settings") {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Font Size: \(Int(exportFontSize))")
                        Slider(value: $exportFontSize, in: 8...24, step: 1)
                    }
                    
                    Picker("Text Alignment", selection: $exportTextAlignment) {
                        Text("Left").tag(NSTextAlignment.left)
                        Text("Center").tag(NSTextAlignment.center)
                        Text("Right").tag(NSTextAlignment.right)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

enum SummaryLength: String, CaseIterable {
    case short, medium, long
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
}
