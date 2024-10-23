//
//  ChapterView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct ChapterView: SwiftUI.View {
    let bookName: String
    @State private var chapters: [(number: String, name: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        Group {
            if isLoading {
                ProgressView("Loading chapters...")
            } else if let error = errorMessage {
                Text("Error: \(error)")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(chapters, id: \.number) { chapter in
                            Button(action: {
                                print("Selected chapter: \(chapter.name)")
                            }) {
                                HStack {
                                    Text(chapter.number)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text(chapter.name)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                        Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                    ]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .background(Color(red: 40/255, green: 40/255, blue: 40/255))
            }
        }
        .navigationTitle(bookName)
        .onAppear(perform: loadChapters)
    }
    
    private func loadChapters() {
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }

        do {
            let db = try Connection(dbPath)
            let query = """
                SELECT DISTINCT chapter_no, chapter 
                FROM narrations 
                WHERE source = ? 
                AND text_en IS NOT NULL 
                AND text_en != '' 
                ORDER BY CAST(chapter_no AS INTEGER)
            """
            
            let results = try db.prepare(query, bookName).map { row in
                // Convert Int64 to String properly
                let chapterNo = row[0] as! Int64
                let chapterName = row[1] as! String
                return (number: String(chapterNo), name: chapterName)
            }
            
            DispatchQueue.main.async {
                self.chapters = results
                self.isLoading = false
                print("Loaded \(results.count) chapters for \(bookName)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading chapters: \(error.localizedDescription)"
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationView {
        ChapterView(bookName: "Sahih Bukhari")
    }
}
