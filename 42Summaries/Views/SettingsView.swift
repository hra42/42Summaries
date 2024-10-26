import SwiftUI
import AppKit
import OllamaKit
import LLMChatOpenAI
import LLMChatAnthropic
import AIModelRetriever

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("selectedPromptId") private var selectedPromptId: String = ""
    @AppStorage("prompts") private var storedPrompts: Data = try! JSONEncoder().encode(defaultPrompts)
    @AppStorage("powerMode") private var powerMode = "fast"
    @AppStorage("selectedModel") private var selectedModel: String = ""
    
    @State private var prompts: [Prompt] = []
    @State private var editedPromptName = ""
    @State private var editedPromptContent = ""
    @State private var availableModels: [String] = []
    @State private var isLoadingModels = false
    @State private var modelLoadError: String?
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    private let ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    
    static let defaultPrompts: [Prompt] = [
        Prompt(id: UUID(), name: "Default", content: """
        Summarize the following transcript concisely:
        - Only answer in the language of the transcript
        - Focus on the main ideas and key points
        - Maintain the original tone and context
        - Include any important quotes or statistics
        - Limit the summary to 3-5 sentences
        - Exclude any redundant or unnecessary information
        - Keep Line Breaks to a minimum
        """),
        Prompt(id: UUID(), name: "Bullet Points", content: """
        Create a bullet-point summary of the main points in the transcript:
        - Only answer in the language of the transcript
        - Extract key ideas and concepts
        - Use concise language
        - Maintain the original order of information
        - Limit to 5-7 bullet points
        - Keep Line Breaks to a minimum
        """),
    ]
    
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
                        .disabled(availableModels.isEmpty)
                        .onChange(of: selectedModel) { oldValue, newValue in
                            UserDefaults.standard.set(newValue, forKey: "selectedModel")
                        }
                    }
                    
                    Button("Refresh Models") {
                        loadAvailableModels()
                    }
                }
                
                settingsSection("Prompt Library") {
                    Picker("Select Prompt", selection: $selectedPromptId) {
                        ForEach(prompts) { prompt in
                            Text(prompt.name).tag(prompt.id.uuidString)
                        }
                    }
                    .onChange(of: selectedPromptId) { _, newValue in
                        if let selectedPrompt = prompts.first(where: { $0.id.uuidString == newValue }) {
                            editedPromptName = selectedPrompt.name
                            editedPromptContent = selectedPrompt.content
                        }
                    }
                    
                    TextField("Prompt Name", text: $editedPromptName)
                    
                    TextEditor(text: $editedPromptContent)
                        .frame(height: 150)
                        .border(Color.secondary.opacity(0.2), width: 1)
                    
                    HStack {
                        Button("Save Changes") {
                            savePrompt()
                        }
                        
                        Button("Delete") {
                            showingDeleteAlert.toggle()
                        }
                        .disabled(prompts.count <= 1)
                        .alert("Delte Prompts", isPresented: $showingDeleteAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                deletePrompt()
                            }
                        } message: {
                            Text("This will delete the selected prompt. Are you sure?")
                        }
                        
                        Button("Add New Prompt") {
                            addNewPrompt()
                        }
                        
                        Button("Reset to Defaults") {
                            showingResetAlert.toggle()
                        }
                        .alert("Reset Prompts", isPresented: $showingResetAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Reset", role: .destructive) {
                                resetToDefaultPrompts()
                            }
                        } message: {
                            Text("This will reset the prompts to their default values. Your custom prompts will be kept. Are you sure?")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadPrompts()
            loadAvailableModels()
            if selectedModel.isEmpty {
                selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? ""
            }
        }
    }

    private func loadPrompts() {
        do {
            prompts = try JSONDecoder().decode([Prompt].self, from: storedPrompts)
        } catch {
            print("Error loading prompts: \(error)")
            prompts = Self.defaultPrompts
        }
        
        if prompts.isEmpty {
            prompts = Self.defaultPrompts
        }
        
        if selectedPromptId.isEmpty || !prompts.contains(where: { $0.id.uuidString == selectedPromptId }) {
            selectedPromptId = prompts[0].id.uuidString
        }
        
        if let selectedPrompt = prompts.first(where: { $0.id.uuidString == selectedPromptId }) {
            editedPromptName = selectedPrompt.name
            editedPromptContent = selectedPrompt.content
        } else {
            editedPromptName = prompts[0].name
            editedPromptContent = prompts[0].content
        }
    }

     private func savePrompt() {
         if let index = prompts.firstIndex(where: { $0.id.uuidString == selectedPromptId }) {
             prompts[index].name = editedPromptName
             prompts[index].content = editedPromptContent
             savePromptsToStorage()
         }
     }
     
     private func deletePrompt() {
         prompts.removeAll { $0.id.uuidString == selectedPromptId }
         if prompts.isEmpty {
             resetToDefaultPrompts()
         } else {
             selectedPromptId = prompts[0].id.uuidString
             editedPromptName = prompts[0].name
             editedPromptContent = prompts[0].content
             savePromptsToStorage()
         }
     }
     
     private func addNewPrompt() {
         let newPrompt = Prompt(id: UUID(), name: "New Prompt", content: "Enter your prompt here...")
         prompts.append(newPrompt)
         selectedPromptId = newPrompt.id.uuidString
         editedPromptName = newPrompt.name
         editedPromptContent = newPrompt.content
         savePromptsToStorage()
     }
     
     private func resetToDefaultPrompts() {
         let customPrompts = prompts.filter { prompt in
             !Self.defaultPrompts.contains { $0.name == prompt.name }
         }
         prompts = Self.defaultPrompts + customPrompts
         selectedPromptId = prompts[0].id.uuidString
         editedPromptName = prompts[0].name
         editedPromptContent = prompts[0].content
         savePromptsToStorage()
     }
     
    private func savePromptsToStorage() {
        do {
            let encoder = JSONEncoder()
            storedPrompts = try encoder.encode(prompts)
            UserDefaults.standard.set(selectedPromptId, forKey: "selectedPromptId")
        } catch {
            print("Error saving prompts: \(error)")
        }
    }

    private func loadAvailableModels() {
        isLoadingModels = true
        modelLoadError = nil
        availableModels = []
        
        let modelRetriever = AIModelRetriever()
        
        Task {
            do {
                switch appState.llmProvider {
                case .ollama:
                    let models = try await modelRetriever.ollama()
                    await MainActor.run {
                        self.availableModels = models.map { $0.name }
                    }
                    
                case .openAI:
                    let models = try await modelRetriever.openAI(apiKey: appState.openAIApiKey)
                    await MainActor.run {
                        self.availableModels = models
                            .map { $0.name }
                            .filter { $0.lowercased().starts(with: "gpt") || $0.lowercased().starts(with: "chatgpt") }
                            .sorted()
                    }
                    
                case .anthropic:
                    do {
                        let models = modelRetriever.anthropic()
                        await MainActor.run {
                            self.availableModels = models.map { $0.id }
                        }
                    }
                }
                
                await MainActor.run {
                    self.isLoadingModels = false
                    if self.selectedModel.isEmpty || !self.availableModels.contains(self.selectedModel) {
                        self.selectedModel = self.availableModels.first ?? ""
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
