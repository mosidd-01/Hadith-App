//
//  HadithsView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct HadithsView: SwiftUI.View {
    let bookName: String
    let chapterName: String
    let chapterNumber: String
    let hadithRange: String
    
    @State private var hadiths: [(number: String, textArabic: String, textEnglish: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            Group {
                if isLoading {
                    ProgressView("Loading hadiths...")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(hadiths, id: \.number) { hadith in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Hadith \(hadith.number)")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 4)
                                    
                                    Text(hadith.textArabic)
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 8)
                                    
                                    Text(hadith.textEnglish.trimmingCharacters(in: .whitespacesAndNewlines))
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
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle(chapterName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadHadiths)
    }
    
    private func loadHadiths() {
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }

        do {
            let db = try Connection(dbPath)
            let query = """
                SELECT 
                    CAST(hadith_no AS TEXT) as hadith_no,
                    text_ar,
                    text_en
                FROM narrations 
                WHERE source = ? 
                AND chapter_no = ?
                AND text_en IS NOT NULL 
                AND text_en != '' 
                ORDER BY CAST(hadith_no AS INTEGER)
            """
            
            let results = try db.prepare(query, bookName, chapterNumber).map { row in
                (
                    number: row[0] as! String,
                    textArabic: row[1] as! String,
                    textEnglish: row[2] as! String
                )
            }
            
            DispatchQueue.main.async {
                self.hadiths = results
                self.isLoading = false
                print("Loaded \(results.count) hadiths for chapter \(chapterNumber)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading hadiths: \(error.localizedDescription)"
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationView {
        HadithsView(
            bookName: " Sahih Bukhari ",
            chapterName: "Revelation",
            chapterNumber: "1",
            hadithRange: "1-7"
        )
    }
}
