// AnthropicSummaryService.swift
import Foundation
import LLMChatAnthropic

class AnthropicSummaryService: LLMService {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String) {
        self.apiKey = apiKey
        self.model = model
    }
    
    func generateSummary(systemPrompt: String, userPrompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw SummaryError.invalidAPIKey
        }
        
        let anthropic = LLMChatAnthropic(
            apiKey: apiKey,
            headers: ["anthropic-beta": "prompt-caching-2024-07-31"]
        )
        
        let messages = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userPrompt)
        ]
        
        do {
            let completion = try await anthropic.send(model: model, messages: messages)
            return completion.content.first?.text ?? ""
        } catch {
            throw SummaryError.summaryGenerationFailed(error.localizedDescription)
        }
    }
}
