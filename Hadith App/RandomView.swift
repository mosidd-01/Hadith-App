//
//  RandomView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct RandomView: SwiftUI.View {
    @State private var hadith: (id: String, number: String, textArabic: String, textEnglish: String, chainIndx: String)?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingChain = false
    @State private var isSaved = false
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading random hadith...")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if let hadith = hadith {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Reference text
//                        Text(hadith.textEnglish.components(separatedBy: ":").count > 1 
//                            ? hadith.textEnglish.components(separatedBy: ":")[0] + ":"
//                            : "Narrated:")
//                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
//                            .padding(.bottom, 4)
                        
                        Text(hadith.textArabic)
                            .font(.title3)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            .padding(.bottom, 8)
                        
                        Text(hadith.textEnglish)
                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            .padding(.bottom, 4)
                        
                        Text("Reference: \(hadith.id) | Hadith \(hadith.number)")
                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            .padding(.bottom, 8)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            // Chain Button
                            Button(action: {
                                showingChain = true
                            }) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("Chain")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                        Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                    ]), startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            // Save Button
                            Button(action: {
                                isSaved.toggle()
                                // Add save functionality here
                            }) {
                                HStack {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    Text(isSaved ? "Saved" : "Save")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                        Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                    ]), startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Random Button
                        Button(action: loadRandomHadith) {
                            Text("Get Another Random Hadith")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0x01/255, green: 0x26/255, blue: 0x77/255),
                                        Color(red: 0x02/255, green: 0x47/255, blue: 0xDD/255)
                                    ]), startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
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
                    .padding()
                }
            }
        }
        .navigationTitle("Random Hadith")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadRandomHadith)
        .sheet(isPresented: $showingChain) {
            if let hadith = hadith {
                ChainView(
                    bookName: hadith.id.components(separatedBy: "_")[0],
                    hadithID: hadith.number,
                    chainIndx: hadith.chainIndx
                )
            }
        }
    }
    
    private func loadRandomHadith() {
        isLoading = true
        errorMessage = nil
        
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }
        
        do {
            let db = try Connection(dbPath)
            
            // First get total count of valid hadiths
            let countQuery = """
                SELECT COUNT(*) 
                FROM narrations 
                WHERE text_en IS NOT NULL 
                AND text_en != ''
            """
            
            guard let totalCount = try db.scalar(countQuery) as? Int64 else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get total hadith count"])
            }
            
            // Get a random hadith
            let randomOffset = Int.random(in: 0..<Int(totalCount))
            let query = """
                SELECT 
                    hadith_no,
                    text_ar,
                    text_en,
                    chain_indx,
                    source,
                    rowid
                FROM narrations
                WHERE text_en IS NOT NULL 
                AND text_en != ''
                AND hadith_no IS NOT NULL
                AND hadith_no != ''
                LIMIT 1 OFFSET ?
            """
            
            let statement = try db.prepare(query)
            
            for row in try statement.bind(randomOffset) {
                let hadithNo = row[0] as? String ?? ""
                let textAr = row[1] as? String ?? ""
                let textEn = row[2] as? String ?? ""
                let chainIndx = row[3] as? String ?? ""
                let source = row[4] as? String ?? ""
                let rowId = row[5] as? Int64 ?? 0
                
                print("Debug hadith data:")
                print("Row ID: \(rowId)")
                print("Hadith No: '\(hadithNo)'")
                print("Source: '\(source)'")
                
                DispatchQueue.main.async {
                    let formattedSource = source.trimmingCharacters(in: .whitespaces)
                    self.hadith = (
                        id: formattedSource,
                        number: hadithNo.trimmingCharacters(in: .whitespaces),
                        textArabic: textAr,
                        textEnglish: textEn,
                        chainIndx: chainIndx
                    )
                    self.isLoading = false
                    print("Loaded random hadith: \(formattedSource) #\(hadithNo)")
                }
                return
            }
            
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hadith found"])
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading random hadith: \(error.localizedDescription)"
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationView {
        //RandomView()
    }
}
