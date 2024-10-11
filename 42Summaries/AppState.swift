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
    let summaryService: SummaryService
    
    init() {
        self.transcriptionManager = TranscriptionManager()
        self.summaryService = SummaryService()
    }

    func initializeWhisperKit() async throws {
        await MainActor.run {
            self.modelState = .downloading
        }

        // Download the model first
        _ = try await WhisperKit.download(variant: "openai_whisper-large-v3", from: "argmaxinc/whisperkit-coreml") { progress in
            Task { @MainActor in
                self.modelDownloadProgress = Float(progress.fractionCompleted)
            }
        }

        // Initialize WhisperKit with the downloaded model
        let config = WhisperKitConfig(
            model: "openai_whisper-large-v3",
            computeOptions: ModelComputeOptions(
                audioEncoderCompute: .cpuAndGPU,
                textDecoderCompute: .cpuAndGPU
            ),
            verbose: false,
            logLevel: .none,
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
}

enum ModelState: CustomStringConvertible {
    case unloaded, downloading, loaded
    
    var description: String {
        switch self {
        case .unloaded: return "Unloaded"
        case .downloading: return "Downloading"
        case .loaded: return "Loaded"
        }
    }
}
