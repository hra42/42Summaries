import SwiftUI
import WhisperKit

class AppState: ObservableObject {
    @Published var selectedFile: URL? {
        didSet {
            DispatchQueue.main.async {
                print("AppState: Selected file changed to \(self.selectedFile?.path ?? "nil")")
                if let url = self.selectedFile {
                    self.transcriptionManager.setSelectedFile(url)
                }
            }
        }
    }
    @Published var transcriptionManager: TranscriptionManager
    @Published var modelDownloadProgress: Float = 0.0
    @Published var whisperKit: WhisperKit?
    
    init() {
        self.transcriptionManager = TranscriptionManager()
    }

    func initializeWhisperKit(progressCallback: @escaping (Float) -> Void) async throws {
        let config = WhisperKitConfig(
            model: "openai_whisper-large-v3",
            computeOptions: ModelComputeOptions(
                audioEncoderCompute: .cpuAndGPU,
                textDecoderCompute: .cpuAndGPU
            ),
            verbose: true,
            logLevel: .debug,
            prewarm: true,
            load: true,
            download: true
        )
        
        let newWhisperKit = try await WhisperKit(config)
        
        await MainActor.run {
            self.whisperKit = newWhisperKit
            self.transcriptionManager.whisperKit = self.whisperKit
        }
    }
    
    private func updateModelDownloadProgress(_ progress: Float) {
        DispatchQueue.main.async {
            self.modelDownloadProgress = progress
        }
    }
}
