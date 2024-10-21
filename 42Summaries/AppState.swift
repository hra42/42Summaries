import SwiftUI
import WhisperKit

class AppState: ObservableObject {
    @Published var selectedFile: URL? {
        didSet {
            DispatchQueue.main.async {
                if let url = self.selectedFile {
                    self.transcriptionManager.setSelectedFile(url)
                }
            }
        }
    }
    @Published var transcriptionManager: TranscriptionManager
    @Published var summaryService: SummaryService!
    @Published var modelDownloadProgress: Float = 0.0
    @Published var modelState: ModelState = .unloaded
    @Published var whisperKit: WhisperKit?
    @Published var powerMode: String {
        didSet {
            if oldValue != powerMode {
                Task {
                    await reinitializeWhisperKit()
                }
            }
        }
    }
    @Published var errorMessage: String?
    @Published var transcription: String = "" {
        didSet {
            saveTranscription()
        }
    }
    @Published var summary: String = "" {
        didSet {
            saveSummary()
        }
    }
    let notificationManager: NotificationManager
    
    @Published var llmProvider: LLMProvider = .ollama {
        didSet {
            UserDefaults.standard.set(llmProvider.rawValue, forKey: "llmProvider")
            updateSummaryService()
        }
    }
    @Published var anthropicApiKey: String = "" {
        didSet {
            UserDefaults.standard.set(anthropicApiKey, forKey: "anthropicApiKey")
            if llmProvider == .anthropic {
                updateSummaryService()
            }
        }
    }
    @Published var openAIApiKey: String = "" {
        didSet {
            UserDefaults.standard.set(openAIApiKey, forKey: "openAIApiKey")
            if llmProvider == .openAI {
                updateSummaryService()
            }
        }
    }
    
    @Published var selectedModel: String = "" {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
            updateSummaryService()
        }
    }

    init() {
        copyModelFilesIfNeeded()
        self.notificationManager = NotificationManager()
        self.transcriptionManager = TranscriptionManager(notificationManager: self.notificationManager)
        self.powerMode = UserDefaults.standard.string(forKey: "powerMode") ?? "fast"
        self.transcription = UserDefaults.standard.string(forKey: "savedTranscription") ?? ""
        self.summary = UserDefaults.standard.string(forKey: "savedSummary") ?? ""
        self.llmProvider = LLMProvider(rawValue: UserDefaults.standard.string(forKey: "llmProvider") ?? "ollama") ?? .ollama
        self.anthropicApiKey = UserDefaults.standard.string(forKey: "anthropicApiKey") ?? ""
        self.openAIApiKey = UserDefaults.standard.string(forKey: "openAIApiKey") ?? ""
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? ""
        
        setupSummaryService()
    }
    
    private func setupSummaryService() {
        self.summaryService = SummaryService(appState: self)
    }

    private func updateSummaryService() {
        self.summaryService = SummaryService(appState: self)
    }

    func initializeWhisperKit() async {
        await MainActor.run {
            self.modelState = .loading
            self.errorMessage = nil
        }

        do {
            try await configureWhisperKit()
        } catch {
            await handleError(error)
        }
    }

    private func configureWhisperKit() async throws {
        let modelPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "tech.postrausch.42Summaries")!
            .appendingPathComponent("Documents/huggingface/models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3-v20240930_547MB")
        
        let config = WhisperKitConfig(
            model: "openai_whisper-large-v3-v20240930_547MB",
            modelFolder: modelPath.path,
            computeOptions: ModelComputeOptions(
                audioEncoderCompute: .cpuAndGPU,
                textDecoderCompute: powerMode == "fast" ? .cpuAndGPU : .cpuAndNeuralEngine
            ),
            verbose: false,
            logLevel: .none,
            prewarm: true,
            load: true,
            download: false
        )
        
        let newWhisperKit = try await WhisperKit(config)
        
        await MainActor.run {
            self.whisperKit = newWhisperKit
            self.transcriptionManager.whisperKit = self.whisperKit
            self.modelState = .loaded
            self.modelDownloadProgress = 1.0
        }
    }

    func updateLLMProvider(_ newProvider: LLMProvider) {
        self.llmProvider = newProvider
    }
    
    func reinitializeWhisperKit() async {
        await MainActor.run {
            self.modelState = .reconfiguring
            self.errorMessage = nil
        }

        do {
            try await configureWhisperKit()
        } catch {
            await handleError(error)
        }
    }

    private func handleError(_ error: Error) async {
        let errorMessage = "Error: \(error.localizedDescription)"
        print(errorMessage)
        await MainActor.run {
            self.modelState = .error
            self.errorMessage = errorMessage
        }
    }

    func updatePowerMode(_ newMode: String) {
        UserDefaults.standard.set(newMode, forKey: "powerMode")
        self.powerMode = newMode
    }

    private func saveTranscription() {
        UserDefaults.standard.set(transcription, forKey: "savedTranscription")
    }

    private func saveSummary() {
        UserDefaults.standard.set(summary, forKey: "savedSummary")
    }
}

enum ModelState: CustomStringConvertible {
    case unloaded, loading, loaded, reconfiguring, error
    
    var description: String {
        switch self {
        case .unloaded: return "Unloaded"
        case .loading: return "Loading"
        case .loaded: return "Loaded"
        case .reconfiguring: return "Reconfiguring"
        case .error: return "Error"
        }
    }
}

struct FileInfo {
    let sourceName: String
    let destinationName: String
    
    init(_ name: String) {
        self.sourceName = name
        self.destinationName = name
    }
    
    init(source: String, destination: String) {
        self.sourceName = source
        self.destinationName = destination
    }
}

func copyModelFilesIfNeeded() {
    let fileManager = FileManager.default
    guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "tech.postrausch.42Summaries") else {
        print("Failed to get container URL")
        return
    }
    
    let targetFolders = [
        containerURL.appendingPathComponent("Documents/huggingface/models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3-v20240930_547MB"),
        containerURL.appendingPathComponent("Documents/huggingface/models/openai/whisper-large-v3")
    ]
    
    let whisperKitFiles: [FileInfo] = [
        FileInfo("AudioEncoder.mlmodelc"),
        FileInfo("config.json"),
        FileInfo("generation_config.json"),
        FileInfo("MelSpectrogram.mlmodelc"),
        FileInfo("TextDecoder.mlmodelc")
    ]
    
    let additionalFiles: [FileInfo] = [
        FileInfo(source: "config2.json", destination: "config.json"),
        FileInfo("tokenizer.json"),
        FileInfo("tokenizer_config.json")
    ]
    
    for (index, targetFolder) in targetFolders.enumerated() {
        do {
            try fileManager.createDirectory(at: targetFolder, withIntermediateDirectories: true, attributes: nil)
            print("Created target folder successfully: \(targetFolder.path)")
        } catch {
            print("Failed to create target folder: \(error)")
            continue
        }
        
        let filesToCopy = index == 0 ? whisperKitFiles : additionalFiles
        
        for fileInfo in filesToCopy {
            let destinationURL = targetFolder.appendingPathComponent(fileInfo.destinationName)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("\(fileInfo.destinationName) already exists in the target location")
                continue
            }
            
            guard let sourceURL = Bundle.main.url(forResource: fileInfo.sourceName, withExtension: nil) else {
                print("Failed to find source file in bundle: \(fileInfo.sourceName)")
                continue
            }
            
            do {
                if fileInfo.sourceName.hasSuffix(".mlmodelc") {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                } else {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                }
                print("Copied \(fileInfo.sourceName) successfully to \(targetFolder.lastPathComponent) as \(fileInfo.destinationName)")
            } catch {
                print("Failed to copy \(fileInfo.sourceName): \(error)")
            }
        }
        
        print("Contents of target folder \(targetFolder.lastPathComponent):")
        do {
            let contents = try fileManager.contentsOfDirectory(at: targetFolder, includingPropertiesForKeys: nil, options: [])
            for item in contents {
                print(" - \(item.lastPathComponent)")
            }
        } catch {
            print("Failed to list contents of target folder: \(error)")
        }
    }
}

enum LLMProvider: String, CaseIterable {
    case ollama
    case anthropic
    case openAI
}
