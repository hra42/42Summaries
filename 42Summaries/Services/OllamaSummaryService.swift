// OllamaSummaryService.swift
import Foundation
import OllamaKit

class OllamaSummaryService: LLMService {
    private let ollama: OllamaKit
    
    init() {
        self.ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    }
    
    func generateSummary(systemPrompt: String, userPrompt: String) async throws -> String {
        let ollamaModel = UserDefaults.standard.string(forKey: "ollamaModel") ?? "llama3.2:latest"
        
        let fullPrompt = """
        \(systemPrompt)
        
        \(userPrompt)
        
        Summary:
        """
        
        let requestData = OKGenerateRequestData(
            model: ollamaModel,
            prompt: fullPrompt
        )
        
        do {
            let isReachable = await ollama.reachable()
            if !isReachable {
                throw SummaryError.ollamaServerNotReachable
            }
            
            let responseStream: AsyncThrowingStream<OKGenerateResponse, Error> = ollama.generate(data: requestData)
            
            var fullResponse = ""
            for try await partialResponse in responseStream {
                fullResponse += partialResponse.response
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
