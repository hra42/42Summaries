import Foundation

protocol LLMService {
    func generateSummary(systemPrompt: String, userPrompt: String) async throws -> String
}
