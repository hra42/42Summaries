// AnthropicSummaryService.swift
import Foundation
import LLMChatAnthropic

class AnthropicSummaryService: LLMService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateSummary(systemPrompt: String, userPrompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw SummaryError.invalidAPIKey
        }
        
        let anthropic = LLMChatAnthropic(apiKey: apiKey, customHeaders: ["anthropic-beta": "prompt-caching-2024-07-31"])
        
        let messages = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userPrompt)
        ]
        
        do {
            let completion = try await anthropic.send(model: "claude-3-5-sonnet-20240620", messages: messages)
            return completion.content.first?.text ?? ""
        } catch {
            throw SummaryError.summaryGenerationFailed(error.localizedDescription)
        }
    }
}
