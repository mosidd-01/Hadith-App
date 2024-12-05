//
//  SavedView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct SavedView: SwiftUI.View {
    @StateObject private var savedManager = SavedHadithsManager()
    @State private var hadiths: [(id: String, number: String, textArabic: String, textEnglish: String, chainIndx: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading saved hadiths...")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if hadiths.isEmpty {
                Text("No saved hadiths")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(hadiths, id: \.id) { hadith in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reference: \(hadith.id) | Hadith \(hadith.number)")
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                
                                Text(hadith.textArabic)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                
                                Text(hadith.textEnglish)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [
                                    Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                    Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                ]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Hadiths")
        .onAppear(perform: loadSavedHadiths)
    }
    
    private func loadSavedHadiths() {
        isLoading = true
        hadiths = []
        
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            errorMessage = "Database file not found"
            isLoading = false
            return
        }
        
        do {
            let db = try Connection(dbPath)
            var loadedHadiths: [(id: String, number: String, textArabic: String, textEnglish: String, chainIndx: String)] = []
            
            for savedId in savedManager.savedHadiths {
                let components = savedId.components(separatedBy: "_")
                guard components.count == 2 else { continue }
                
                let source = components[0]
                let hadithNo = components[1]
                
                let query = """
                    SELECT 
                        hadith_no,
                        text_ar,
                        text_en,
                        chain_indx
                    FROM narrations
                    WHERE source = ?
                    AND hadith_no = ?
                    LIMIT 1
                """
                
                let statement = try db.prepare(query)
                
                for row in try statement.bind(source, hadithNo) {
                    loadedHadiths.append((
                        id: source,
                        number: row[0] as? String ?? "",
                        textArabic: row[1] as? String ?? "",
                        textEnglish: row[2] as? String ?? "",
                        chainIndx: row[3] as? String ?? ""
                    ))
                }
            }
            
            DispatchQueue.main.async {
                self.hadiths = loadedHadiths
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading saved hadiths: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    SavedView()
}
