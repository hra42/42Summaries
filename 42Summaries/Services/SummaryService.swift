import Foundation

class SummaryService {
    private var llmService: LLMService
    
    init(appState: AppState) {
        switch appState.llmProvider {
        case .ollama:
            self.llmService = OllamaSummaryService(model: appState.selectedModel)
        case .anthropic:
            self.llmService = AnthropicSummaryService(apiKey: appState.anthropicApiKey, model: appState.selectedModel)
        case .openAI:
            self.llmService = OpenAISummaryService(apiKey: appState.openAIApiKey, model: appState.selectedModel)
        }
    }
    
    func generateSummary(from transcription: String, using prompt: String) async throws -> String {
        return try await llmService.generateSummary(systemPrompt: prompt, userPrompt: transcription)
    }
}

enum SummaryError: Error, CustomStringConvertible {
    case ollamaServerNotReachable
    case summaryGenerationFailed(String)
    case invalidAPIKey
    
    var description: String {
        switch self {
        case .ollamaServerNotReachable:
            return "Ollama server is not reachable. Please make sure it's running."
        case .summaryGenerationFailed(let message):
            return "Failed to generate summary: \(message)"
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        }
    }
}
