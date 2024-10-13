import Foundation

class SummaryService {
    private var llmService: LLMService
    
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
        let customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? "Summarize the following transcript concisely:"
        let ollamaModel = UserDefaults.standard.string(forKey: "ollamaModel") ?? "llama3.2:latest"
        let defaultPrompt = """
        Summarize the following transcript concisely:
        - Focus on the main ideas and key points
        - Maintain the original tone and context
        - Include any important quotes or statistics
        - Limit the summary to 3-5 sentences
        - Exclude any redundant or unnecessary information
        """

        let customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? defaultPrompt
        
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
            return "Failed to generate summary: \(message)"y
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        }
    }
}

class SummaryService {
    private let ollama: OllamaKit
    
    init() {
        self.ollama = OllamaKit(baseURL: URL(string: "http://127.0.0.1:11434")!)
    }
    
    func generateSummary(from transcription: String) async throws -> String {
        let defaultPrompt = """
        Summarize the following transcript concisely:
        - Focus on the main ideas and key points
        - Maintain the original tone and context
        - Include any important quotes or statistics
        - Limit the summary to 3-5 sentences
        - Exclude any redundant or unnecessary information
        """

        let customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? defaultPrompt
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
