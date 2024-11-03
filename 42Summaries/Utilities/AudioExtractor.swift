import Foundation
import AVFoundation

enum AudioExtractionError: LocalizedError {
    case failedToLoadAsset
    case noAudioTrack
    case exportFailed(Error)
    case invalidOutputURL
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadAsset:
            return "Failed to load the media asset"
        case .noAudioTrack:
            return "No audio track found in the media file"
        case .exportFailed(let error):
            return "Failed to export audio: \(error.localizedDescription)"
        case .invalidOutputURL:
            return "Invalid output URL for temporary audio file"
        }
    }
}

class AudioExtractor {
    private var exportSession: AVAssetExportSession?
    private var progressHandler: ((Float) -> Void)?
    private var timer: Timer?
    
    func extractAudio(from videoURL: URL, progressHandler: ((Float) -> Void)? = nil) async throws -> URL {
        self.progressHandler = progressHandler
        
        // Create asset from video URL
        let asset = AVAsset(url: videoURL)
        
        // Check if the asset has an audio track
        let audioTracks: [AVAssetTrack]
        do {
            audioTracks = try await asset.loadTracks(withMediaType: .audio)
        } catch {
            throw AudioExtractionError.failedToLoadAsset
        }
        
        guard !audioTracks.isEmpty else {
            throw AudioExtractionError.noAudioTrack
        }
        
        // Create temporary file URL for the audio
        let outputURL = try createTemporaryAudioFileURL()
        
        // Configure export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw AudioExtractionError.failedToLoadAsset
        }
        
        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.audioTimePitchAlgorithm = .spectral
        
        // Start progress monitoring
        startProgressMonitoring()
        
        // Perform the export
        await exportSession.export()
        
        // Stop progress monitoring
        stopProgressMonitoring()
        
        // Check for export errors
        if let error = exportSession.error {
            throw AudioExtractionError.exportFailed(error)
        }
        
        return outputURL
    }
    
    private func createTemporaryAudioFileURL() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".m4a"
        return tempDir.appendingPathComponent(fileName)
    }
    
    private func startProgressMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let exportSession = self.exportSession else { return }
            
            self.progressHandler?(exportSession.progress)
        }
    }
    
    private func stopProgressMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func cleanup(audioURL: URL) {
        try? FileManager.default.removeItem(at: audioURL)
    }
}

