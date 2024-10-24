//
//  SavedView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI

struct SavedView: View {
    @AppStorage("savedHadiths") private var savedHadithsData: Data = Data()
    @State private var savedHadiths: Set<String> = []
    @State private var hadiths: [(id: String, bookName: String, number: String, textArabic: String, textEnglish: String)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 40/255, green: 40/255, blue: 40/255)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading saved hadiths...")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if hadiths.isEmpty {
                    Text("No saved hadiths")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(hadiths, id: \.id) { hadith in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(hadith.textArabic)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(hadith.textEnglish)
                                    Text("\(hadith.bookName), Hadith \(hadith.number)")
                                        .font(.caption)
                                }
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                        Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                    ]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(10)
                                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Saved Hadiths")
            .onAppear(perform: loadSavedHadiths)
        }
    }
    
    private func loadSavedHadiths() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: savedHadithsData) {
            savedHadiths = decoded
            loadHadithsFromDatabase()
        }
    }
    
    private func loadHadithsFromDatabase() {
        // Implement database loading logic similar to HadithsView
        // but filter by saved hadith IDs
        // This is where you'll need to query your SQLite database
    }
}

#Preview {
    SavedView()
}
