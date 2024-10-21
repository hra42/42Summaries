// OllamaSummaryService.swift
import Foundation
import OllamaKit

class OllamaSummaryService: LLMService {
    private let ollama: OllamaKit
    private let model: String
    
    init(model: String) {
        self.ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
        self.model = model
    }
    
    func generateSummary(systemPrompt: String, userPrompt: String) async throws -> String {
        let fullPrompt = """
        \(systemPrompt)
        
        \(userPrompt)
        
        Summary:
        """
        
        let requestData = OKGenerateRequestData(
            model: model,
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

