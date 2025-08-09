import Foundation

class MemoryService {
    static let shared = MemoryService()
    
    private let memoryDirectory: URL
    private let memoryFileExtension = "json"
    
    private init() {
        // Get documents directory
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.memoryDirectory = documentsURL.appendingPathComponent("AgentMemory")
            
            // Create directory if it doesn't exist
            if !FileManager.default.fileExists(atPath: memoryDirectory.path) {
                try? FileManager.default.createDirectory(at: memoryDirectory, withIntermediateDirectories: true)
            }
        } else {
            // Fallback to temporary directory if documents directory is not available
            self.memoryDirectory = FileManager.default.temporaryDirectory
        }
    }
    
    func saveMemory(for agentId: UUID, memory: [String]) {
        let memoryData = MemoryData(agentId: agentId, messages: memory, timestamp: Date())
        
        do {
            let data = try JSONEncoder().encode(memoryData)
            let fileURL = memoryDirectory.appendingPathComponent("\(agentId.uuidString).\(memoryFileExtension)")
            try data.write(to: fileURL)
        } catch {
            print("Error saving memory: \(error)")
        }
    }
    
    func loadMemory(for agentId: UUID) -> [String] {
        let fileURL = memoryDirectory.appendingPathComponent("\(agentId.uuidString).\(memoryFileExtension)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let memoryData = try JSONDecoder().decode(MemoryData.self, from: data)
            return memoryData.messages
        } catch {
            print("Error loading memory: \(error)")
            return []
        }
    }
    
    func addToMemory(for agentId: UUID, message: String) {
        var memory = loadMemory(for: agentId)
        memory.append(message)
        
        // Keep only the last 50 messages to prevent memory from growing too large
        if memory.count > 50 {
            memory.removeFirst(memory.count - 50)
        }
        
        saveMemory(for: agentId, memory: memory)
    }
    
    func clearMemory(for agentId: UUID) {
        let fileURL = memoryDirectory.appendingPathComponent("\(agentId.uuidString).\(memoryFileExtension)")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error clearing memory: \(error)")
        }
    }
    
    func getAllMemories() -> [(agentId: UUID, memory: [String])] {
        var memories: [(agentId: UUID, memory: [String])] = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: memoryDirectory, includingPropertiesForKeys: nil) else {
            return memories
        }
        
        for fileURL in files {
            guard fileURL.pathExtension == memoryFileExtension else { continue }
            
            do {
                let data = try Data(contentsOf: fileURL)
                let memoryData = try JSONDecoder().decode(MemoryData.self, from: data)
                memories.append((agentId: memoryData.agentId, memory: memoryData.messages))
            } catch {
                print("Error reading memory file: \(error)")
            }
        }
        
        return memories
    }
    
    private struct MemoryData: Codable {
        let agentId: UUID
        let messages: [String]
        let timestamp: Date
    }
}
