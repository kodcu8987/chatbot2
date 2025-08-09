import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChatViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("Ayarlar", selection: $selectedTab) {
                    Text("API Anahtarları").tag(0)
                    Text("Agent Profilleri").tag(1)
                    Text("Ayarlar").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                
                // Tab content
                Group {
                    switch selectedTab {
                    case 0:
                        APIKeysView()
                    case 1:
                        AgentProfilesView(viewModel: viewModel)
                    case 2:
                        AppSettingsView(viewModel: viewModel)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// API Keys View
struct APIKeysView: View {
    @State private var newService = "OpenAI"
    @State private var newApiKey = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Yeni API Anahtarı Ekle")) {
                    Picker("Servis", selection: $newService) {
                        Text("OpenAI").tag("OpenAI")
                        Text("OpenRouter").tag("OpenRouter")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    SecureField("API Anahtarı", text: $newApiKey)
                    
                    Button("Kaydet") {
                        saveAPIKey()
                    }
                    .disabled(newApiKey.isEmpty)
                }
                
                Section(header: Text("Mevcut API Anahtarları")) {
                    ForEach(APIKeyManager.shared.getAllServices(), id: \.self) { service in
                        HStack {
                            Text(service)
                            Spacer()
                            Button("Sil") {
                                deleteAPIKey(for: service)
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .alert("Uyarı", isPresented: $showingAlert) {
            Button("Tamam") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAPIKey() {
        APIKeyManager.shared.saveAPIKey(for: newService, key: newApiKey)
        newApiKey = ""
        alertMessage = "\(newService) API anahtarı başarıyla kaydedildi."
        showingAlert = true
    }
    
    private func deleteAPIKey(for service: String) {
        APIKeyManager.shared.deleteAPIKey(for: service)
        alertMessage = "\(service) API anahtarı silindi."
        showingAlert = true
    }
}

// Agent Profiles View
struct AgentProfilesView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showingAddProfile = false
    @State private var profiles = [AgentProfile]()
    @State private var selectedProfile: AgentProfile?
    
    var body: some View {
        VStack {
            List {
                ForEach(profiles) { profile in
                    Button(action: {
                        selectedProfile = profile
                        viewModel.updateAgent(profile)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.name)
                                    .font(.headline)
                                Text("\(profile.service) - \(profile.model)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if profile.isMemoryEnabled {
                                Image(systemName: "brain")
                                    .foregroundColor(.blue)
                            }
                            if profile.isWebSearchEnabled {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteProfile)
            }
            
            Button(action: {
                showingAddProfile = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Yeni Profil Oluştur")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            loadProfiles()
        }
        .sheet(isPresented: $showingAddProfile) {
            AddProfileView()
        }
        .sheet(item: $selectedProfile) { profile in
            EditProfileView(profile: profile) { updatedProfile in
                updateProfile(updatedProfile)
            }
        }
    }
    
    private func loadProfiles() {
        profiles = AgentManager.shared.getProfiles()
    }
    
    private func deleteProfile(at offsets: IndexSet) {
        for index in offsets {
            let profile = profiles[index]
            AgentManager.shared.deleteProfile(id: profile.id)
        }
        loadProfiles()
    }
    
    private func updateProfile(_ profile: AgentProfile) {
        AgentManager.shared.saveProfile(profile)
        loadProfiles()
    }
    
    private func dismiss() {
        // This will be handled by the parent view
    }
}

// Add Profile View
struct AddProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var service = "OpenAI"
    @State private var model = "gpt-3.5-turbo"
    @State private var systemPrompt = ""
    
    let services = ["OpenAI", "OpenRouter"]
    let openAIModels = ["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"]
    let openRouterModels = ["openai/gpt-4", "openai/gpt-3.5-turbo", "deepseek/deepseek-chat"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Bilgileri")) {
                    TextField("Profil Adı", text: $name)
                    
                    Picker("Servis", selection: $service) {
                        ForEach(services, id: \.self) { service in
                            Text(service).tag(service)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Model", selection: $model) {
                        ForEach(service == "OpenAI" ? openAIModels : openRouterModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextEditor(text: $systemPrompt)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .padding(.vertical)
                }
                
                Section {
                    Button("Oluştur") {
                        createProfile()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Yeni Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createProfile() {
        let profile = AgentProfile(
            name: name,
            service: service,
            model: model,
            systemPrompt: systemPrompt
        )
        
        AgentManager.shared.saveProfile(profile)
        dismiss()
    }
}

// Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State var profile: AgentProfile
    let onSave: (AgentProfile) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Bilgileri")) {
                    TextField("Profil Adı", text: $profile.name)
                    
                    Picker("Servis", selection: $profile.service) {
                        Text("OpenAI").tag("OpenAI")
                        Text("OpenRouter").tag("OpenRouter")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Model", selection: $profile.model) {
                        ForEach(profile.service == "OpenAI" ? ["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"] : ["openai/gpt-4", "openai/gpt-3.5-turbo", "deepseek/deepseek-chat"], id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextEditor(text: $profile.systemPrompt)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .padding(.vertical)
                }
                
                Section(header: Text("Özellikler")) {
                    Toggle("Hafıza Kullan", isOn: $profile.isMemoryEnabled)
                    Toggle("Web Arama", isOn: $profile.isWebSearchEnabled)
                }
                
                Section {
                    Button("Kaydet") {
                        onSave(profile)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// App Settings View
struct AppSettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showingClearMemoryAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Geçmiş Veriler")) {
                Button(action: {
                    showingClearMemoryAlert = true
                }) {
                    HStack {
                        Text("Geçmişi Temizle")
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .foregroundColor(.red)
            }
            
            Section(header: Text("Web Arama Anahtar Kelimeleri")) {
                ForEach(WebSearchService.shared.getKeywords(), id: \.self) { keyword in
                    Text(keyword)
                }
                .onDelete(perform: deleteKeyword)
            }
        }
        .alert("Geçmişi Temizle", isPresented: $showingClearMemoryAlert) {
            Button("İptal", role: .cancel) { }
            Button("Temizle", role: .destructive) {
                viewModel.clearMemory()
            }
        } message: {
            Text("Tüm geçmiş veriler kalıcı olarak silinecek. Bu işlemi geri alamazsınız.")
        }
    }
    
    private func deleteKeyword(at offsets: IndexSet) {
        for index in offsets {
            let keyword = WebSearchService.shared.getKeywords()[index]
            WebSearchService.shared.removeKeyword(keyword)
        }
    }
}

#Preview {
    SettingsView(viewModel: ChatViewModel())
}
