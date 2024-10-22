//
//  ContentView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @State private var isLoading = true
    @State private var randomHadith: Hadith?
    @State private var randomRawi: Rawi?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hadith App")
                    .font(.largeTitle)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    // Display random Hadith and Rawi if available
                    
                /*
                 var id: Int
                 var hadithId: Int
                 var source: String
                 var chapterNo: Int
                 var hadithNo: Int
                 var chapter: String
                 var chainIndx: String
                 var textAr: String
                 var textEn: String
                 */
                    if let hadith = randomHadith, let rawi = randomRawi {
                        VStack(alignment: .leading) {
                            Text("Random Hadith:")
                                .font(.headline)
                            Text("Hadith ID: \(hadith.id)")
                            Text("Hadith ID: \(hadith.hadithId)")
                            Text("Source: \(hadith.source)")
                            Text("Chapter Number: \(hadith.chapterNo)")
                            Text("Hadith Number: \(hadith.hadithNo)")
                            Text("Chapter: \(hadith.chapter)")
                            Text("Chain: \(hadith.chainIndx)")
                            Text("Arabic text: \(hadith.textAr)")
                            Text("English text: \(hadith.textEn)")
                            
                            Text("\nRandom Rawi:")
                                .font(.headline)
                            Text("ID: \(rawi.id)")
                            Text("Name: \(rawi.name)")
                            Text("Grade: \(rawi.grade)")
                            Text("Birth Date/Place: \(rawi.birthDatePlace)")
                            Text("Death Date/Place: \(rawi.deathDatePlace)")
                        }
                        .padding()
                    }
                    
                    // Button to generate random Hadith and Rawi
                    Button(action: {
                        generateRandomHadithAndRawi()
                    }) {
                        Text("Get Random Hadith and Rawi")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
        }
    }
    
    private func generateRandomHadithAndRawi() {
        if let hadith = dataStore.hadiths.randomElement(),
           let rawi = dataStore.rawis.randomElement() {
            randomHadith = hadith
            randomRawi = rawi
        }
        print("Random Hadith: \(randomHadith?.textEn ?? "")")
        print("Random Rawi: \(randomRawi?.name ?? "")")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
