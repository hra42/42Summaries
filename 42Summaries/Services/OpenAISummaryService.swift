// OpenAISummaryService.swift
import Foundation
import LLMChatOpenAI

class OpenAISummaryService: LLMService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
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
            let completion = try await openAI.send(model: "gpt-4", messages: messages)
            return completion.choices.first?.message.content ?? ""
        } catch {
            throw SummaryError.summaryGenerationFailed(error.localizedDescription)
        }
    }
}

