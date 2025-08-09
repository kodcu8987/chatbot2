import Foundation

class OpenAIService: AIService {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "gpt-3.5-turbo") {
        self.apiKey = apiKey
        self.model = model
    }
    
    func generateResponse(prompt: String, systemPrompt: String?, memory: [String]?, webSearchResults: String?) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIServiceError.invalidAPIKey
        }
        
        var messages: [MessageData] = []
        
        // Add system prompt if provided
        if let systemPrompt = systemPrompt {
            messages.append(MessageData(role: "system", content: systemPrompt))
        }
        
        // Add memory if provided
        if let memory = memory, !memory.isEmpty {
            let memoryText = memory.joined(separator: "\n")
            messages.append(MessageData(role: "system", content: "Geçmiş konuşma:\n\(memoryText)"))
        }
        
        // Add web search results if provided
        if let webSearchResults = webSearchResults, !webSearchResults.isEmpty {
            messages.append(MessageData(role: "system", content: "Web arama sonuçları:\n\(webSearchResults)"))
        }
        
        // Add user prompt
        messages.append(MessageData(role: "user", content: prompt))
        
        let requestBody = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.7
        )
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIServiceError.serviceUnavailable
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw AIServiceError.unknown(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.serviceUnavailable
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw AIServiceError.invalidAPIKey
        case 429:
            throw AIServiceError.quotaExceeded
        default:
            throw AIServiceError.serviceUnavailable
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let choice = response.choices.first else {
                throw AIServiceError.serviceUnavailable
            }
            
            return choice.message.content
        } catch {
            throw AIServiceError.unknown(error)
        }
    }
    
    private struct MessageData: Codable {
        let role: String
        let content: String
    }
    
    private struct OpenAIRequest: Codable {
        let model: String
        let messages: [MessageData]
        let temperature: Double
    }
    
    private struct OpenAIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let role: String
                let content: String
            }
        }
    }
}
