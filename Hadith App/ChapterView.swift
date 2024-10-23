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
    @State private var chapters: [(number: String, name: String, range: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    init(bookName: String) {
        self.bookName = bookName
        
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some SwiftUI.View {
        ZStack {
            // Background color that extends behind the tab bar
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            Group {
                if isLoading {
                    ProgressView("Loading chapters...")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(chapters, id: \.number) { chapter in
                                NavigationLink(destination: HadithsView(
                                    bookName: bookName,
                                    chapterName: chapter.name,
                                    chapterNumber: chapter.number,
                                    hadithRange: chapter.range
                                )) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(chapter.number)
                                                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                                .frame(width: 50, alignment: .leading)
                                            
                                            Text(chapter.name.trimmingCharacters(in: .whitespaces))
                                                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        Text("Hadith: \(chapter.range)")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 50)
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
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle(bookName)
        .navigationBarTitleDisplayMode(.inline)
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
                SELECT 
                    chapter_no,
                    chapter,
                    MIN(CAST(hadith_no AS INTEGER)) as min_hadith,
                    MAX(CAST(hadith_no AS INTEGER)) as max_hadith
                FROM narrations 
                WHERE source = ? 
                AND text_en IS NOT NULL 
                AND text_en != '' 
                GROUP BY chapter_no, chapter
                ORDER BY CAST(chapter_no AS INTEGER)
            """
            
            let results = try db.prepare(query, bookName).map { row in
                let chapterNo = row[0] as! Int64
                let chapterName = row[1] as! String
                let minHadith = row[2] as! Int64
                let maxHadith = row[3] as! Int64
                
                return (
                    number: String(chapterNo),
                    name: chapterName,
                    range: "\(minHadith)-\(maxHadith)"
                )
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
        ChapterView(bookName: " Sahih Bukhari ")
    }
}
