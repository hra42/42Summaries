import SwiftUI
import AppKit
import OllamaKit
import LLMChatOpenAI
import LLMChatAnthropic

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("customPrompt") private var customPrompt = "Summarize the following transcript concisely:"
    @AppStorage("powerMode") private var powerMode = "fast"
    
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var modelLoadError: String?
    @State private var selectedModel: String = ""
    
    private let ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                settingsSection("Transcription Settings") {
                    Picker("Power Mode", selection: Binding(
                        get: { self.appState.powerMode },
                        set: { self.appState.updatePowerMode($0) }
                    )) {
                        ForEach(["fast", "energy efficient"], id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }
                }
                
                settingsSection("LLM Provider Settings") {
                    Picker("LLM Provider", selection: $appState.llmProvider) {
                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue.capitalized).tag(provider)
                        }
                    }
                    .onChange(of: appState.llmProvider) { oldValue, newValue in
                        loadAvailableModels()
                    }
                    
                    if appState.llmProvider == .anthropic {
                        SecureField("Anthropic API Key", text: $appState.anthropicApiKey)
                    } else if appState.llmProvider == .openAI {
                        SecureField("OpenAI API Key", text: $appState.openAIApiKey)
                    }
                    
                    if isLoadingModels {
                        ProgressView("Loading models...")
                    } else if let error = modelLoadError {
                        Text("Error loading models: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Picker("Model", selection: $selectedModel) {
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    }
                    
                    Button("Refresh Models") {
                        loadAvailableModels()
                    }
                }

                settingsSection("Custom Prompt") {
                    Text("Custom Prompt")
                    TextEditor(text: $customPrompt)
                        .frame(height: 100)
                        .border(Color.secondary.opacity(0.2), width: 1)
                    
                    Button("Reset to Default Prompt") {
                        customPrompt = "Summarize the following transcript concisely:"
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
        availableModels = []
        
        Task {
            do {
                switch appState.llmProvider {
                case .ollama:
                    let modelResponse = try await ollama.models()
                    await MainActor.run {
                        self.availableModels = modelResponse.models.map { $0.name }
                    }
                case .openAI:
                    let openAI = LLMChatOpenAI(apiKey: appState.openAIApiKey)
                    let models = try await openAI.models()
                    await MainActor.run {
                        self.availableModels = models.data
                            .map { $0.id }
                            .filter { $0.lowercased().starts(with: "gpt") || $0.lowercased().starts(with: "chatgpt") }
                            .sorted()
                    }
                case .anthropic:
                    // Anthropic doesn't have a models endpoint, so we'll use a predefined list
                    await MainActor.run {
                        self.availableModels = ["claude-3-5-sonnet-20240620", "claude-3-opus-20240229", "claude-3-haiku-20240307"]
                    }
                }
                
                await MainActor.run {
                    self.isLoadingModels = false
                    if !self.availableModels.isEmpty {
                        self.selectedModel = self.availableModels[0]
                    }
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
