import Foundation

class SummaryService {
    private var llmService: LLMService
    
    static let defaultPrompt = """
    Summarize the following transcript concisely:
    - Focus on the main ideas and key points
    - Maintain the original tone and context
    - Include any important quotes or statistics
    - Limit the summary to 3-5 sentences
    - Exclude any redundant or unnecessary information
    """
    
    init(appState: AppState) {
        switch appState.llmProvider {
        case .ollama:
            self.llmService = OllamaSummaryService()
        case .anthropic:
            self.llmService = AnthropicSummaryService(apiKey: appState.anthropicApiKey)
        case .openAI:
            self.llmService = OpenAISummaryService(apiKey: appState.openAIApiKey)
        }
    }
    
    func generateSummary(from transcription: String) async throws -> String {
        let customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? SummaryService.defaultPrompt
        
        return try await llmService.generateSummary(systemPrompt: customPrompt, userPrompt: transcription)
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
