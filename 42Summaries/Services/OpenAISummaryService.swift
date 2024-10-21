// OpenAISummaryService.swift
import Foundation
import LLMChatOpenAI

class OpenAISummaryService: LLMService {
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
        
        let openAI = LLMChatOpenAI(apiKey: apiKey)
        
        let messages = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userPrompt)
        ]
        
        do {
            let completion = try await openAI.send(model: model, messages: messages)
            return completion.choices.first?.message.content ?? ""
        } catch {
            throw SummaryError.summaryGenerationFailed(error.localizedDescription)
        }
    }
}
