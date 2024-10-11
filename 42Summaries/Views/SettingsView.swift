import SwiftUI
import AppKit
import OllamaKit

struct SettingsView: View {
    @AppStorage("ollamaModel") private var ollamaModel = "llama3.2:latest"
    @AppStorage("customPrompt") private var customPrompt = "Summarize the following transcript concisely:"
    
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var modelLoadError: String?
    
    private let ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                settingsSection("Ollama Settings") {
                    if isLoadingModels {
                        ProgressView("Loading models...")
                    } else if let error = modelLoadError {
                        Text("Error loading models: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Picker("Model", selection: $ollamaModel) {
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    }
                    
                    Text("Custom Prompt")
                    TextEditor(text: $customPrompt)
                        .frame(height: 100)
                        .border(Color.secondary.opacity(0.2), width: 1)
                    
                    Button("Reset to Default Prompt") {
                        customPrompt = "Summarize the following transcript concisely:"
                    }
                    
                    Button("Refresh Models") {
                        loadAvailableModels()
                    }
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadAvailableModels()
        }
    }
    
    private func loadAvailableModels() {
        isLoadingModels = true
        modelLoadError = nil
        
        Task {
            do {
                let modelResponse = try await ollama.models()
                await MainActor.run {
                    self.availableModels = modelResponse.models.map { $0.name }
                    self.isLoadingModels = false
                }
            } catch {
                await MainActor.run {
                    self.modelLoadError = error.localizedDescription
                    self.isLoadingModels = false
                }
            }
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
}
