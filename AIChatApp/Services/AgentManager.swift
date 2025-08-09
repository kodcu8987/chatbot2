import Foundation

class AgentManager {
    static let shared = AgentManager()
    
    private let profilesKey = "AgentProfiles"
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func saveProfile(_ profile: AgentProfile) {
        var profiles = getProfiles()
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        saveProfiles(profiles)
    }
    
    func getProfile(id: UUID) -> AgentProfile? {
        return getProfiles().first { $0.id == id }
    }
    
    func getProfiles() -> [AgentProfile] {
        guard let data = defaults.data(forKey: profilesKey) else { return [] }
        do {
            return try JSONDecoder().decode([AgentProfile].self, from: data)
        } catch {
            print("Error decoding agent profiles: \(error)")
            return []
        }
    }
    
    func deleteProfile(id: UUID) {
        var profiles = getProfiles()
        profiles.removeAll { $0.id == id }
        saveProfiles(profiles)
    }
    
    func setCurrentProfile(_ profile: AgentProfile) {
        defaults.set(profile.id.uuidString, forKey: "CurrentProfileID")
    }
    
    func getCurrentProfile() -> AgentProfile? {
        guard let profileIDString = defaults.string(forKey: "CurrentProfileID"),
              let profileID = UUID(uuidString: profileIDString) else {
            return nil
        }
        return getProfile(id: profileID)
    }
    
    func createDefaultProfile() -> AgentProfile {
        let defaultProfile = AgentProfile(
            name: "Genel Asistan",
            service: "OpenAI",
            model: "gpt-3.5-turbo",
            systemPrompt: "Sen yardımcı bir AI asistansın. Kullanıcının sorularını mümkün olan en iyi şekilde yanıtla."
        )
        saveProfile(defaultProfile)
        setCurrentProfile(defaultProfile)
        return defaultProfile
    }
    
    private func saveProfiles(_ profiles: [AgentProfile]) {
        do {
            let data = try JSONEncoder().encode(profiles)
            defaults.set(data, forKey: profilesKey)
        } catch {
            print("Error encoding agent profiles: \(error)")
        }
    }
}
