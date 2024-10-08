import Foundation
import OllamaKit

enum SummaryError: Error, CustomStringConvertible {
    case ollamaServerNotReachable
    case summaryGenerationFailed(String)
    
    var description: String {
        switch self {
        case .ollamaServerNotReachable:
            return "Ollama server is not reachable. Please make sure it's running."
        case .summaryGenerationFailed(let message):
            return "Failed to generate summary: \(message)"
        }
    }
}

class SummaryService {
    private let ollama: OllamaKit
    
    init() {
        self.ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    }
    
    func generateSummary(from transcription: String) async throws -> String {
        let customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? "Summarize the following transcript concisely:"
        let ollamaModel = UserDefaults.standard.string(forKey: "ollamaModel") ?? "llama3.2:latest"
        
        let prompt = """
        \(customPrompt)
        
        \(transcription)
        
        Summary:
        """
        
        let requestData = OKGenerateRequestData(
            model: ollamaModel,
            prompt: prompt
        )
        
        do {
            let isReachable = await ollama.reachable()
            if !isReachable {
                throw SummaryError.ollamaServerNotReachable
            }
            
            print("Generating summary with model: \(ollamaModel)")
            let responseStream: AsyncThrowingStream<OKGenerateResponse, Error> = ollama.generate(data: requestData)
            
            var fullResponse = ""
            for try await partialResponse in responseStream {
                fullResponse += partialResponse.response
                print("Received partial response: \(partialResponse.response)")
            }
            
            if fullResponse.isEmpty {
                throw SummaryError.summaryGenerationFailed("Generated summary is empty")
            }
            
            return fullResponse
        } catch let error as SummaryError {
            throw error
        } catch {
            throw SummaryError.summaryGenerationFailed(error.localizedDescription)
        }
    }
}
