//
//  SearchView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct SearchResultView: SwiftUI.View {
    let hadith: (
        id: String, 
        number: String, 
        textArabic: String, 
        textEnglish: String, 
        chainIndx: String,
        chapter: String,
        chapterNo: String
    )
    
    var body: some SwiftUI.View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reference: \(hadith.id) | Hadith \(hadith.number)")
                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                .padding(.bottom, 4)
            
            Text(hadith.textEnglish.components(separatedBy: ":").count > 1 
                ? hadith.textEnglish.components(separatedBy: ":")[0] + ":"
                : "Narrated:")
                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                .padding(.bottom, 4)
            
            Text(hadith.textArabic)
                .font(.title3)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                .padding(.bottom, 8)
            
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

struct SearchView: SwiftUI.View {
    @State private var searchText = ""
    @State private var hadiths: [(id: String, number: String, textArabic: String, textEnglish: String, chainIndx: String)] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            VStack {
                TextField("Search hadiths...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { _ in
                        if searchText.count >= 3 {
                            searchHadiths()
                        }
                    }
                
                if isLoading {
                    ProgressView("Searching...")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if hadiths.isEmpty && !searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(hadiths, id: \.id) { hadith in
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Reference: \(hadith.id) | Hadith \(hadith.number)")
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 4)
                                    
                                    Text(hadith.textEnglish.components(separatedBy: ":").count > 1 
                                        ? hadith.textEnglish.components(separatedBy: ":")[0] + ":"
                                        : "Narrated:")
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 4)
                                    
                                    Text(hadith.textArabic)
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 8)
                                    
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
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func searchHadiths() {
        guard searchText.count >= 3 else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }
        
        do {
            let db = try Connection(dbPath)
            
            let query = """
                SELECT 
                    hadith_no,
                    text_ar,
                    text_en,
                    chain_indx,
                    source
                FROM narrations
                WHERE (text_en LIKE ? 
                    OR text_ar LIKE ? 
                    OR source LIKE ? 
                    OR hadith_no LIKE ?)
                AND text_en IS NOT NULL 
                AND text_en != ''
                LIMIT 100
            """
            
            let searchPattern = "%\(searchText)%"
            let statement = try db.prepare(query)
            var results: [(id: String, number: String, textArabic: String, textEnglish: String, chainIndx: String)] = []
            
            for row in try statement.bind(searchPattern, searchPattern, searchPattern, searchPattern) {
                let hadithNo = row[0] as? String ?? ""
                let textAr = row[1] as? String ?? ""
                let textEn = row[2] as? String ?? ""
                let chainIndx = row[3] as? String ?? ""
                let source = row[4] as? String ?? ""
                
                results.append((
                    id: source.trimmingCharacters(in: .whitespaces),
                    number: hadithNo.trimmingCharacters(in: .whitespaces),
                    textArabic: textAr,
                    textEnglish: textEn,
                    chainIndx: chainIndx
                ))
            }
            
            DispatchQueue.main.async {
                self.hadiths = results
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error searching hadiths: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    SearchView()
}
