// TranscriptionManager.swift
import Foundation
import WhisperKit
import AVFoundation

class TranscriptionManager: ObservableObject {
    @Published private(set) var progress: Double = 0.0
    @Published var status: TranscriptionStatus = .notStarted
    @Published var transcriptionResult: String = ""
    @Published var errorMessage: String?
    
    private var selectedFileURL: URL?
    private let transcriptionService: TranscriptionService = TranscriptionService()
    private let audioExtractor: AudioExtractor = AudioExtractor()
    var whisperKit: WhisperKit?
    private var transcribeTask: Task<Void, Never>?
    private var temporaryAudioURL: URL?
    
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func setSelectedFile(_ url: URL) {
        DispatchQueue.main.async {
            self.selectedFileURL = url
            self.status = .notStarted
            self.progress = 0.0
            self.transcriptionResult = ""
            self.errorMessage = nil
        }
    }
    
    func startTranscription() {
        guard let fileURL = selectedFileURL, let whisperKit = whisperKit else {
            DispatchQueue.main.async {
                self.errorMessage = "No file selected or WhisperKit not initialized"
            }
            return
        }
        
        transcribeTask = Task {
            await MainActor.run {
                self.status = .preparing
            }
            
            do {
                let audioURL: URL
                let isVideo = try await isVideoFile(fileURL)
                
                if isVideo {
                    // Extract audio from video
                    audioURL = try await audioExtractor.extractAudio(from: fileURL) { [weak self] progress in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            // Use first 20% of progress bar for audio extraction
                            self.progress = Double(progress) * 0.2
                        }
                    }
                    self.temporaryAudioURL = audioURL
                } else {
                    audioURL = fileURL
                }
                
                await MainActor.run {
                    self.status = .transcribing
                }
                
                // Start transcription
                transcriptionService.transcribeAudioFile(
                    url: audioURL,
                    whisperKit: whisperKit,
                    progressHandler: { [weak self] progress in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            // Use remaining 80% of progress bar for transcription
                            self.progress = 0.2 + (Double(progress) * 0.8)
                        }
                    },
                    completionHandler: { [weak self] result in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let transcription):
                                self.transcriptionResult = self.processTranscription(transcription)
                                self.status = .completed
                                self.progress = 1.0
                                self.notificationManager.showNotification(
                                    title: "Transcription Completed",
                                    body: "Your media file has been successfully transcribed."
                                )
                                
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                self.status = .notStarted
                                self.progress = 0.0
                                self.notificationManager.showNotification(
                                    title: "Transcription Failed",
                                    body: "An error occurred during transcription."
                                )
                            }
                            
                            // Clean up temporary audio file if it exists
                            if let tempURL = self.temporaryAudioURL {
                                self.audioExtractor.cleanup(audioURL: tempURL)
                                self.temporaryAudioURL = nil
                            }
                        }
                    }
                )
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.status = .notStarted
                    self.progress = 0.0
                    self.notificationManager.showNotification(
                        title: "Preparation Failed",
                        body: "Failed to prepare media file for transcription."
                    )
                }
            }
        }
    }
    
    func cancelTranscription() {
        transcribeTask?.cancel()
        transcribeTask = nil
        
        // Clean up temporary audio file if it exists
        if let tempURL = temporaryAudioURL {
            audioExtractor.cleanup(audioURL: tempURL)
            temporaryAudioURL = nil
        }
        
        DispatchQueue.main.async {
            self.status = .notStarted
            self.progress = 0.0
        }
    }
    
    private func isVideoFile(_ url: URL) async throws -> Bool {
        let asset = AVAsset(url: url)
        let tracks = asset.tracks(withMediaType: .video)
        return !tracks.isEmpty
    }
    
    private func processTranscription(_ raw: String) -> String {
        var cleanedText = raw
            .replacingOccurrences(of: "<|startoftranscript|>", with: "")
            .replacingOccurrences(of: "<|en|>", with: "")
            .replacingOccurrences(of: "<|transcribe|>", with: "")
            .replacingOccurrences(of: "<|endoftext|>", with: "")
        
        let timestampPattern = "<|\\d+\\.\\d+|>"
        cleanedText = cleanedText.replacingOccurrences(of: timestampPattern, with: "", options: .regularExpression)
        
        let segments = cleanedText.components(separatedBy: "||")
        let processedSegments = segments.map { segment -> String in
            let trimmedSegment = segment.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedSegment.isEmpty ? "" : trimmedSegment
        }.filter { !$0.isEmpty }
        
        let joinedText = processedSegments.joined(separator: "\n\n")
        
        let excessiveNewlinesPattern = "\n{3,}"
        let finalText = joinedText.replacingOccurrences(of: excessiveNewlinesPattern, with: "\n\n", options: .regularExpression)
        
        return finalText
    }
}

