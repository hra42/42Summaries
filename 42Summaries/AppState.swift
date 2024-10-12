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
        self.notificationManager = NotificationManager()
        self.transcriptionManager = TranscriptionManager(notificationManager: self.notificationManager)
        self.summaryService = SummaryService()
        self.powerMode = UserDefaults.standard.string(forKey: "powerMode") ?? "fast"
        self.transcription = UserDefaults.standard.string(forKey: "savedTranscription") ?? ""
        self.summary = UserDefaults.standard.string(forKey: "savedSummary") ?? ""
    }

    func initializeWhisperKit() async {
        await MainActor.run {
            self.modelState = .downloading
            self.errorMessage = nil
        }

        do {
            // Download the model first
            _ = try await WhisperKit.download(variant: "openai_whisper-large-v3", from: "argmaxinc/whisperkit-coreml") { progress in
                Task { @MainActor in
                    self.modelDownloadProgress = Float(progress.fractionCompleted)
                }
            }

            try await configureWhisperKit()
        } catch {
            await handleError(error)
        }
    }

    private func configureWhisperKit() async throws {
        let config = WhisperKitConfig(
            model: "openai_whisper-large-v3",
            computeOptions: ModelComputeOptions(
                audioEncoderCompute: .cpuAndGPU,
                textDecoderCompute: powerMode == "fast" ? .cpuAndGPU : .cpuAndNeuralEngine
            ),
            verbose: true,
            logLevel: .debug,
            prewarm: true,
            load: true,
            download: true,
            useBackgroundDownloadSession: true
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
    case unloaded, downloading, loaded, reconfiguring, error
    
    var description: String {
        switch self {
        case .unloaded: return "Unloaded"
        case .downloading: return "Downloading"
        case .loaded: return "Loaded"
        case .reconfiguring: return "Reconfiguring"
        case .error: return "Error"
        }
    }
}
