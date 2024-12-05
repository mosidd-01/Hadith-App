//
//  ContentView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import SwiftUI
import SQLite

struct ContentView: SwiftUI.View {
    @State private var bookNames: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    
    // Dictionary mapping English book names to Arabic names
    let arabicNames: [String: String] = [
        "Sahih Bukhari": "صحيح البخاري",
        "Sahih Muslim": "صحيح مسلم",
        "Sunan Abi Da'ud": "سنن أبي داود",
        "Jami' al-Tirmidhi": "جامع الترمذي",
        "Sunan an-Nasa'i": "سنن النسائي",
        "Sunan Ibn Majah": "سنن ابن ماجه"
    ]
    
    // Hardcoded hadith counts
    let hadithCounts: [String: Int] = [
        "Sahih Bukhari": 7563,
        "Sahih Muslim": 3033,
        "Sunan Abi Da'ud": 5274,
        "Jami' al-Tirmidhi": 3960,
        "Sunan an-Nasa'i": 5758,
        "Sunan Ibn Majah": 4341
    ]

    init() {
        // Set the unselected tab items to the specified gray color
        UITabBar.appearance().unselectedItemTintColor = UIColor(
            red: 187/255,
            green: 187/255,
            blue: 187/255,
            alpha: 1.0
        )
        
        // Create the dark gray color to match background
        let darkGrayColor = UIColor(
            red: 40/255,
            green: 40/255,
            blue: 40/255,
            alpha: 1.0
        )
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = darkGrayColor
        
        // Remove the separator line
        tabBarAppearance.shadowColor = .clear
        
        // Apply the appearance settings
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    var body: some SwiftUI.View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                Group {
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let error = errorMessage {
                        Text("Error: \(error)")
                    } else {
                        ScrollView {
                            VStack(alignment: .center, spacing: 20) {
                                Text("Hadith Books")
                                    .font(.largeTitle)
                                    .padding()
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(bookNames, id: \.self) { bookName in
                                        NavigationLink(destination: ChapterView(bookName: bookName)) {
                                            VStack(spacing: 8) {
                                                Text(arabicNames[bookName.trimmingCharacters(in: .whitespaces)] ?? "")
                                                    .font(.title2)
                                                    .frame(maxWidth: .infinity)
                                                Text(bookName)
                                                    .font(.body)
                                                    .frame(maxWidth: .infinity)
                                                Text("\(hadithCounts[bookName.trimmingCharacters(in: .whitespaces)] ?? 0) Ahaadith")
                                                    .font(.caption)
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .padding()
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                            .frame(height: 160)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(gradient: Gradient(colors: [
                                                    Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                                    Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                                ]), startPoint: .leading, endPoint: .trailing)
                                                .cornerRadius(10)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .background(Color(red: 40/255, green: 40/255, blue: 40/255))
                        }
                        .background(Color(red: 40/255, green: 40/255, blue: 40/255))
                    }
                }
                .background(Color(red: 40/255, green: 40/255, blue: 40/255))
            }
            .onAppear(perform: loadUniqueBookNames)
            .background(Color(red: 40/255, green: 40/255, blue: 40/255))
            .edgesIgnoringSafeArea(.all)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Search Tab
            NavigationView {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
            
            // Saved Tab
            NavigationView {
                SavedView()
            }
            .tabItem {
                Image(systemName: "bookmark.fill")
                Text("Saved")
            }
            .tag(2)
            
            // Random Tab
            NavigationView {
                RandomView()
            }
            .tabItem {
                Image(systemName: "shuffle")
                Text("Random")
            }
            .tag(3)
        }
        .accentColor(Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255))  // Set the active tab color
    }

    private func loadUniqueBookNames() {
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }

        do {
            let db = try Connection(dbPath)
            
            // Get unique book names
            let books = try db.prepare("SELECT DISTINCT source FROM narrations WHERE text_en IS NOT NULL AND text_en != ''").map { row in
                row[0] as! String
            }.filter { $0 != "source" }
            
            DispatchQueue.main.async {
                self.bookNames = books
                self.isLoading = false
                print("Loaded \(books.count) unique book names")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading book names: \(error.localizedDescription)"
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}
