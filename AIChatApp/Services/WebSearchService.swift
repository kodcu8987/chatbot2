import Foundation

class WebSearchService {
    static let shared = WebSearchService()
    
    // Configuration for web search keywords
    static var searchKeywords: [String] = [
        "son haberler", "güncel", "haber", "son dakika", "en yeni",
        "ne demek", "anlamı", "tanımı", "açıklaması",
        "nasıl yapılır", "rehber", "adım adım",
        "fiyatı", "maliyeti", "ne kadar",
        "en iyi", "karşılaştırma", "değerlendirmesi",
        "nerede", "nerede bulunur", "adresi",
        "telefon numarası", "iletişim bilgileri"
    ]
    
    private init() {}
    
    func shouldTriggerSearch(for message: String) -> Bool {
        let lowercasedMessage = message.lowercased()
        
        // Check if any keyword is in the message
        for keyword in Self.searchKeywords {
            if lowercasedMessage.contains(keyword.lowercased()) {
                return true
            }
        }
        
        // Check for question marks which often indicate information-seeking
        if message.contains("?") {
            return true
        }
        
        return false
    }
    
    func performSearch(query: String, completion: @escaping (Result<String, Error>) -> Void) {
        // In a real implementation, this would call a SERP API
        // For now, we'll simulate a search result
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Simulate a search result
            let searchResult = """
            Web arama sonuçları: "\(query)" için
            
            1. [Örnek Site 1] - Bu konu hakkında detaylı bilgiler içerir.
            2. [Örnek Site 2] - Güncel gelişmeler ve trendler.
            3. [Örnek Site 3] - Uzman görüşleri ve analizler.
            
            Özet: Aradığınız konu hakkında çeşitli kaynaklardan bilgi bulunabilir.
            """
            
            completion(.success(searchResult))
        }
    }
    
    func performSearchAsync(query: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            performSearch(query: query) { result in
                switch result {
                case .success(let searchResult):
                    continuation.resume(returning: searchResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func addKeyword(_ keyword: String) {
        if !Self.searchKeywords.contains(keyword) {
            Self.searchKeywords.append(keyword)
        }
    }
    
    func removeKeyword(_ keyword: String) {
        Self.searchKeywords.removeAll { $0.lowercased() == keyword.lowercased() }
    }
    
    func getKeywords() -> [String] {
        return Self.searchKeywords
    }
}
