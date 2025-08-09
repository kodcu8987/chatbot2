import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    
    private let keysKey = "APIKeys"
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func saveAPIKey(for service: String, key: String) {
        var keys = getAPIKeys()
        keys[service] = key
        defaults.set(keys, forKey: keysKey)
    }
    
    func getAPIKey(for service: String) -> String? {
        let keys = getAPIKeys()
        return keys[service]
    }
    
    func getAPIKeys() -> [String: String] {
        return defaults.dictionary(forKey: keysKey) as? [String: String] ?? [:]
    }
    
    func deleteAPIKey(for service: String) {
        var keys = getAPIKeys()
        keys.removeValue(forKey: service)
        defaults.set(keys, forKey: keysKey)
    }
    
    func getAllServices() -> [String] {
        return getAPIKeys().keys.map { $0 }
    }
    
    func hasAPIKey(for service: String) -> Bool {
        return getAPIKey(for: service) != nil
    }
}
