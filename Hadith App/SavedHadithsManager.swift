import SwiftUI

class SavedHadithsManager: ObservableObject {
    @AppStorage("savedHadiths") private var savedHadithsData: Data = Data()
    @Published var savedHadiths: Set<String> = []
    
    init() {
        loadSavedHadiths()
        cleanupSavedHadiths()
    }
    
    private func loadSavedHadiths() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: savedHadithsData) {
            DispatchQueue.main.async {
                self.savedHadiths = decoded
                print("Loaded saved hadiths: \(self.savedHadiths)")
            }
        }
    }
    
    private func cleanupSavedHadiths() {
        let cleanedIds = savedHadiths.map { standardizeHadithId($0) }
        savedHadiths = Set(cleanedIds)
        saveToDisk()
    }
    
    private func standardizeHadithId(_ id: String) -> String {
        let components = id.components(separatedBy: "_")
        guard components.count == 2 else { return id }
        
        let book = components[0].trimmingCharacters(in: .whitespaces)
        let number = components[1].trimmingCharacters(in: .whitespaces)
        return "\(book)_\(number)"
    }
    
    func toggleSaved(hadithId: String) {
        DispatchQueue.main.async {
            let standardId = self.standardizeHadithId(hadithId)
            if self.savedHadiths.contains(standardId) {
                self.savedHadiths.remove(standardId)
                print("Removed hadith ID: \(standardId)")
            } else {
                self.savedHadiths.insert(standardId)
                print("Added hadith ID: \(standardId)")
            }
            
            self.saveToDisk()
        }
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedHadiths) {
            savedHadithsData = encoded
            print("Saved to disk: \(savedHadiths)")
        }
    }
    
    func isSaved(hadithId: String) -> Bool {
        let standardId = standardizeHadithId(hadithId)
        return savedHadiths.contains(standardId)
    }
} 