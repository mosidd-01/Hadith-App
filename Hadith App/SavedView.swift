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
                        ForEach(hadiths.indices, id: \.self) { index in
                            let hadith = hadiths[index]
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Reference: \(hadith.id) | Hadith \(hadith.number)")
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        let hadithId = "\(hadith.id)_\(hadith.number)"
                                        savedManager.toggleSaved(hadithId: hadithId)
                                        hadiths.remove(at: index)
                                        
                                        // If this was the last hadith, trigger empty state
                                        if hadiths.isEmpty {
                                            isLoading = false
                                        }
                                    }) {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                
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
            
            print("Attempting to load saved hadiths with IDs: \(savedManager.savedHadiths)")
            
            // Create a single query to fetch all saved hadiths
            let placeholders = Array(repeating: "?", count: savedManager.savedHadiths.count * 2).joined(separator: ",")
            let query = """
                SELECT 
                    source,
                    hadith_no,
                    text_ar,
                    text_en,
                    chain_indx
                FROM narrations
                WHERE (TRIM(source) || '_' || TRIM(hadith_no)) IN (
                    SELECT TRIM(source) || '_' || TRIM(hadith_no)
                    FROM narrations
                    WHERE (TRIM(source) || '_' || TRIM(hadith_no)) IN (\(savedManager.savedHadiths.map { _ in "?" }.joined(separator: ",")))
                )
                COLLATE NOCASE
            """
            
            let statement = try db.prepare(query)
            
            // Bind all saved hadith IDs
            let bindValues = savedManager.savedHadiths.map { $0 }
            
            for row in try statement.bind(bindValues) {
                let source = row[0] as? String ?? ""
                let hadithNo = row[1] as? String ?? ""
                let textAr = row[2] as? String ?? ""
                let textEn = row[3] as? String ?? ""
                let chainIndx = row[4] as? String ?? ""
                
                let loadedHadith = (
                    id: source.trimmingCharacters(in: .whitespaces),
                    number: hadithNo.trimmingCharacters(in: .whitespaces),
                    textArabic: textAr,
                    textEnglish: textEn,
                    chainIndx: chainIndx
                )
                print("Loaded hadith: \(loadedHadith.id)_\(loadedHadith.number)")
                loadedHadiths.append(loadedHadith)
            }
            
            DispatchQueue.main.async {
                self.hadiths = loadedHadiths
                self.isLoading = false
                print("Final loaded hadiths count: \(self.hadiths.count)")
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading saved hadiths: \(error.localizedDescription)"
                self.isLoading = false
                print("Error loading saved hadiths: \(error)")
            }
        }
    }
}

#Preview {
    SavedView()
}
