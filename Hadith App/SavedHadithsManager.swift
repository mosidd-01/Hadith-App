import SwiftUI

class SavedHadithsManager: ObservableObject {
    @AppStorage("savedHadiths") private var savedHadithsData: Data = Data()
    @Published var savedHadiths: Set<String> = []
    
    init() {
        loadSavedHadiths()
    }
    
    private func loadSavedHadiths() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: savedHadithsData) {
            savedHadiths = decoded
        }
    }
    
    func toggleSaved(hadithId: String) {
        if savedHadiths.contains(hadithId) {
            savedHadiths.remove(hadithId)
        } else {
            savedHadiths.insert(hadithId)
        }
        
        if let encoded = try? JSONEncoder().encode(savedHadiths) {
            savedHadithsData = encoded
        }
    }
    
    func isSaved(hadithId: String) -> Bool {
        return savedHadiths.contains(hadithId)
    }
} 