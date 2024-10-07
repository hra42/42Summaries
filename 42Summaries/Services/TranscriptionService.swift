import Foundation
import WhisperKit

class TranscriptionService {
    func transcribeAudioFile(
        url: URL,
        whisperKit: WhisperKit,
        progressHandler: @escaping (Float) -> Void,
        completionHandler: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                let audioSamples = try await Task {
                    try autoreleasepool {
                        let audioFileBuffer = try AudioProcessor.loadAudio(fromPath: url.path)
                        return AudioProcessor.convertBufferToArray(buffer: audioFileBuffer)
                    }
                }.value

                let options = DecodingOptions(
                    verbose: true,
                    task: .transcribe,
                    language: "en",
                    temperature: 0,
                    sampleLength: 224
                )

                let chunkSize = 30 * WhisperKit.sampleRate // 30 seconds of audio
                let totalChunks = (audioSamples.count + chunkSize - 1) / chunkSize
                var transcribedText = ""

                for (index, chunk) in audioSamples.chunked(into: chunkSize).enumerated() {
                    let chunkStartProgress = Float(index) / Float(totalChunks)
                    let chunkEndProgress = Float(index + 1) / Float(totalChunks)

                    let decodingCallback: ((TranscriptionProgress) -> Bool?) = { progress in
                        let chunkProgress = Float(progress.tokens.count) / Float(whisperKit.textDecoder.kvCacheMaxSequenceLength ?? 224)
                        let overallProgress = chunkStartProgress + (chunkEndProgress - chunkStartProgress) * chunkProgress
                        progressHandler(overallProgress)
                        return nil
                    }

                    let transcriptionResults = try await whisperKit.transcribe(
                        audioArray: Array(chunk),
                        decodeOptions: options,
                        callback: decodingCallback
                    )

                    if let transcription = transcriptionResults.first {
                        transcribedText += transcription.segments.map { $0.text }.joined(separator: " ") + " "
                    }
                }

                if !transcribedText.isEmpty {
                    completionHandler(.success(transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completionHandler(.failure(TranscriptionError.noTranscriptionResult))
                }
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}

enum TranscriptionError: Error {
    case noTranscriptionResult
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
