# AI Chat App

SwiftUI ile geliştirilmiş, iOS 15.8.4 uyumlu, iPhone 7'de çalışan bir AI Agent uygulaması.

## Özellikler

- **Platform & Uyumluluk**
  - SwiftUI ve Combine kullanıldı
  - Deployment Target: iOS 15
  - iPhone 7 uyumlu
  - MVVM mimarisi ile modüler yapı

- **Servisler ve API Entegrasyonu**
  - OpenAI (gpt-4o, gpt-4o-mini, gpt-3.5-turbo vb.)
  - OpenRouter (gpt-4, deepseek-chat vb.)
  - Yeni servislerin kolayca eklenebileceği yapı
  - API Key yönetimi (UserDefaults'ta saklama)
  - Hata yönetimi (geçersiz key, kota dolması, API hataları)

- **AI Agent Özellikleri**
  - Birden fazla "agent" profili oluşturma
  - Her profil için:
    - Kullanılacak AI servisi ve modeli
    - Memory açık/kapalı durumu
    - Web arama açık/kapalı durumu
    - Sistem promptu (role instruction)
  - Görev bazlı çalışma geçmişi

- **Memory Sistemi**
  - Sınırsız uzunlukta hafıza
  - JSON dosyasında saklama
  - Agent bazlı hafıza
  - Geçmişi temizleme özelliği

- **Web Arama Entegrasyonu**
  - Otomatik tetikleme (belirli anahtar kelimelerde)
  - Anahtar kelime listesinin kolayca düzenlenebilmesi
  - Arama sonucu özetlenerek AI cevabına eklenme

- **UI Özellikleri**
  - iMessage tarzı modern baloncuk tasarımı
  - Kullanıcı mesajları sağda, AI cevapları solda
  - Zaman damgası gösterimi
  - Ayar ikonu ile:
    - Web Arama Aç/Kapat
    - Memory Aç/Kapat
    - Geçmişi Temizle
  - Hata mesajları özel baloncukta
  - Modern ve minimalist ayar ekranları

## Kurulum

### Gereksinimler
- Xcode 13.0 veya daha yeni sürüm
- iOS 15.8.4 veya daha yeni bir sürümü çalıştıran bir cihaz veya simülatör

### Adımlar

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/aichatapp.git
   cd aichatapp
   ```

2. Xcode projeyi açın:
   ```bash
   open AIChatApp.xcodeproj
   ```

3. Gerekli bağımlılıkları yükleyin:
   ```bash
   pod install
   ```

4. Proje ayarlarını yapın:
   - Hedef cihazı iPhone 7 olarak seçin
   - Deployment Target'ı iOS 15 olarak ayarlayın

5. API anahtarlarınızı ayarlayın:
   - Uygulamayı çalıştırın
   - Ayarlar > API Anahtarlarım bölümüne gidin
   - Kullanmak istediğiniz AI servisi için API anahtarı ekleyin

## Codemagic ile Derleme ve Yayın

Bu proje, Codemagic CI/CD platformu ile otomatik derleme ve yayın için yapılandırılmıştır.

### Gerekli Ortam Değişkenleri

Codemagic hesabınızda aşağıdaki ortam değişkenlerini ayarlamanız gerekir:

- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API anahtarınızın ID'si
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect API anahtarınızın issuer ID'si
- `APP_STORE_CONNECT_API_KEY_CONTENT`: App Store Connect API anahtarınızın içeriği
- `CERTIFICATES_P12`: Kod imzalama sertifikalarınızın base64 kodlanmış hali
- `CERTIFICATES_PASSWORD`: Sertifika parolanız
- `PROVISIONING_PROFILE`: Dağıtım profili base64 kodlanmış hali
- `KEYCHAIN_PASSWORD`: Anahtarlık parolanız

### Adımlar

1. Codemagic hesabınızda yeni bir uygulama oluşturun
2. Bu depoyu bağlayın
3. Ortam değişkenlerini yukarıda belirtilen şekilde ayarlayın
4. `codemagic.yaml` dosyasını depoya commit edin
5. Derlemeyi başlatın

### Yapılandırma Detayları

`codemagic.yaml` dosyası aşağıdaki adımları içerir:

1. **Bağımlılıkların Kurulumu**: CocoaPods kurulumu
2. **Kod İmzalama Ayarları**: Sertifikalar ve profillerin import edilmesi
3. **Uygulama Derlemesi**: Xcode ile derleme
4. **TestFlight'e Yükleme**: App Store Connect üzerinden TestFlight'e yükleme

### Yapılandırma Dosyası

Proje kök dizinindeki `codemagic.yaml` dosyası, CI/CD sürecini yapılandırır. Bu dosya:
- iOS 15.8.4 hedefli derleme
- iPhone 7 uyumluluğu
- App Store Connect entegrasyonu
- TestFlight'e otomatik yükleme

## Lisans

Bu proje MIT lisansı altındadır.
