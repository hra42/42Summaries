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
    let summaryService: SummaryService
    let notificationManager: NotificationManager
    
    init() {
        copyModelFilesIfNeeded()
        self.notificationManager = NotificationManager()
        self.transcriptionManager = TranscriptionManager(notificationManager: self.notificationManager)
        self.summaryService = SummaryService()
        self.powerMode = UserDefaults.standard.string(forKey: "powerMode") ?? "fast"
        self.transcription = UserDefaults.standard.string(forKey: "savedTranscription") ?? ""
        self.summary = UserDefaults.standard.string(forKey: "savedSummary") ?? ""
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
            .appendingPathComponent("Documents/huggingface/models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3")
        
        let config = WhisperKitConfig(
            model: "openai_whisper-large-v3",
            modelFolder: modelPath.path(),
            computeOptions: ModelComputeOptions(
                audioEncoderCompute: .cpuAndGPU,
                textDecoderCompute: powerMode == "fast" ? .cpuAndGPU : .cpuAndNeuralEngine
            ),
            verbose: true,
            logLevel: .debug,
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

// Add this struct definition outside of the function
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
        containerURL.appendingPathComponent("Documents/huggingface/models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3"),
        containerURL.appendingPathComponent("Documents/huggingface/models/openai/whisper-large-v3")
    ]
    
    // Files for the first folder (WhisperKit models)
    let whisperKitFiles: [FileInfo] = [
        FileInfo("AudioEncoder.mlmodelc"),
        FileInfo("config.json"),
        FileInfo("generation_config.json"),
        FileInfo("MelSpectrogram.mlmodelc"),
        FileInfo("TextDecoder.mlmodelc")
    ]
    
    // Files for the second folder
    let additionalFiles: [FileInfo] = [
        FileInfo(source: "config2.json", destination: "config.json"),
        FileInfo("tokenizer.json"),
        FileInfo("tokenizer_config.json")
    ]
    
    for (index, targetFolder) in targetFolders.enumerated() {
        // Create the target folder if it doesn't exist
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
            
            // Check if the file already exists in the target location
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("\(fileInfo.destinationName) already exists in the target location")
                continue
            }
            
            // Get the source URL from the app bundle
            guard let sourceURL = Bundle.main.url(forResource: fileInfo.sourceName, withExtension: nil) else {
                print("Failed to find source file in bundle: \(fileInfo.sourceName)")
                continue
            }
            
            do {
                if fileInfo.sourceName.hasSuffix(".mlmodelc") {
                    // For .mlmodelc directories, we need to copy the entire directory
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                } else {
                    // For regular files, we can just copy the file
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                }
                print("Copied \(fileInfo.sourceName) successfully to \(targetFolder.lastPathComponent) as \(fileInfo.destinationName)")
            } catch {
                print("Failed to copy \(fileInfo.sourceName): \(error)")
            }
        }
        
        // Print the contents of the target folder
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

