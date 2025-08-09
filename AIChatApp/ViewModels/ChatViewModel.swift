import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var currentAgent: AgentProfile?
    private var aiService: AIService?
    
    init() {
        setupCurrentAgent()
    }
    
    private func setupCurrentAgent() {
        currentAgent = AgentManager.shared.getCurrentProfile() ?? AgentManager.shared.createDefaultProfile()
        updateAIService()
    }
    
    private func updateAIService() {
        guard let agent = currentAgent else { return }
        
        let apiKey = APIKeyManager.shared.getAPIKey(for: agent.service)
        
        switch agent.service {
        case "OpenAI":
            if let apiKey = apiKey {
                aiService = OpenAIService(apiKey: apiKey, model: agent.model)
            }
        case "OpenRouter":
            if let apiKey = apiKey {
                aiService = OpenRouterService(apiKey: apiKey, model: agent.model)
            }
        default:
            aiService = nil
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(text: inputText, isUser: true)
        messages.append(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        // Add to memory if enabled
        if let agent = currentAgent, agent.isMemoryEnabled {
            MemoryService.shared.addToMemory(for: agent.id, message: "Kullanıcı: \(userInput)")
        }
        
        // Generate AI response
        generateAIResponse(for: userInput)
    }
    
    private func generateAIResponse(for userInput: String) {
        guard let agent = currentAgent, let aiService = aiService else {
            showError("AI servisi ayarlanmamış")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Load memory if enabled
                var memory: [String]?
                if agent.isMemoryEnabled {
                    memory = MemoryService.shared.loadMemory(for: agent.id)
                }
                
                // Perform web search if enabled and needed
                var webSearchResults: String?
                if agent.isWebSearchEnabled && WebSearchService.shared.shouldTriggerSearch(for: userInput) {
                    do {
                        webSearchResults = try await WebSearchService.shared.performSearchAsync(query: userInput)
                    } catch {
                        // If web search fails, continue without it
                        print("Web search failed: \(error)")
                    }
                }
                
                // Generate AI response
                let response = try await aiService.generateResponse(
                    prompt: userInput,
                    systemPrompt: agent.systemPrompt,
                    memory: memory,
                    webSearchResults: webSearchResults
                )
                
                // Add AI response to memory if enabled
                if agent.isMemoryEnabled {
                    MemoryService.shared.addToMemory(for: agent.id, message: "AI: \(response)")
                }
                
                // Add response to UI
                await MainActor.run {
                    let aiMessage = Message(text: response, isUser: false)
                    self.messages.append(aiMessage)
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.errorMessage = nil
        }
    }
    
    func clearMemory() {
        guard let agent = currentAgent else { return }
        MemoryService.shared.clearMemory(for: agent.id)
    }
    
    func updateAgent(_ agent: AgentProfile) {
        currentAgent = agent
        updateAIService()
    }
}
