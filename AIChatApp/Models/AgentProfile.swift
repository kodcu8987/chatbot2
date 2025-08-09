import Foundation

struct AgentProfile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var service: String
    var model: String
    var systemPrompt: String
    var isMemoryEnabled: Bool
    var isWebSearchEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, service: String, model: String, systemPrompt: String = "") {
        self.name = name
        self.service = service
        self.model = model
        self.systemPrompt = systemPrompt
        self.isMemoryEnabled = false
        self.isWebSearchEnabled = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    mutating func update(name: String? = nil, service: String? = nil, model: String? = nil, systemPrompt: String? = nil, isMemoryEnabled: Bool? = nil, isWebSearchEnabled: Bool? = nil) {
        if let name = name { self.name = name }
        if let service = service { self.service = service }
        if let model = model { self.model = model }
        if let systemPrompt = systemPrompt { self.systemPrompt = systemPrompt }
        if let isMemoryEnabled = isMemoryEnabled { self.isMemoryEnabled = isMemoryEnabled }
        if let isWebSearchEnabled = isWebSearchEnabled { self.isWebSearchEnabled = isWebSearchEnabled }
        self.updatedAt = Date()
    }
}
