import Foundation

protocol AIService {
    func generateResponse(prompt: String, systemPrompt: String?, memory: [String]?, webSearchResults: String?) async throws -> String
}

enum AIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case quotaExceeded
    case networkError(Error)
    case serviceUnavailable
    case unknown(Error?)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Geçersiz API anahtarı"
        case .quotaExceeded:
            return "API kotası aşıldı"
        case .networkError(let error):
            return "Ağ hatası: \(error.localizedDescription)"
        case .serviceUnavailable:
            return "AI servisi geçici olarak kullanılamıyor"
        case .unknown(let error):
            return "Bilinmeyen hata: \(error?.localizedDescription ?? "Hata detayı yok")"
        }
    }
}
