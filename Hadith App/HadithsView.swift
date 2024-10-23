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
    
    @State private var hadiths: [(id: String, number: String, textArabic: String, textEnglish: String)] = []
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
                            ForEach(hadiths, id: \.id) { hadith in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Hadith \(String(Int(hadith.id)! + 1))")  // Add 1 to the ID
                                        .font(.headline)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 4)
                                    
                                    Text(formatArabicText(hadith.textArabic))
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 8)
                                    
                                    Text(hadith.textEnglish)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .padding(.bottom, 8)
                                    
                                    Divider()
                                        .background(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(bookName.trimmingCharacters(in: .whitespaces)), \(hadith.number)")  // Add 1 to the ID
                                            .font(.caption)
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        Text("In-Book Reference: Book \(chapterNumber), Hadith \(String(Int(hadith.id)! + 1))")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    }
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
    
    // Function to format Arabic text with bold quotes
    private func formatArabicText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Find all text between quotes
        let pattern = #""([^"]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return attributedString
        }
        
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: nsRange)
        
        // Apply bold attribute to matched text
        for match in matches.reversed() {
            if let range = Range(match.range, in: text),
               let attributedRange = Range(range, in: attributedString) {
                attributedString[attributedRange].inlinePresentationIntent = .stronglyEmphasized
            }
        }
        
        return attributedString
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
                    CAST(id AS TEXT) as id,
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
                    id: row[0] as! String,      // Now expecting String directly
                    number: row[1] as! String,
                    textArabic: row[2] as! String,
                    textEnglish: row[3] as! String
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
