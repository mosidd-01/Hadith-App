//
//  ChainView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/23/24.
//

import SwiftUI
import SQLite

struct Narrator {
    let name: String
    let birthInfo: String
    let deathInfo: String
}

struct ChainView: SwiftUI.View {
    let bookName: String
    let hadithID: String
    let chainIndx: String
    
    @State private var narrators: [Narrator] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            Group {
                if isLoading {
                    ProgressView("Loading chain...")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Reverse the order of narrators
                            ForEach(Array(narrators.reversed().enumerated()), id: \.offset) { index, narrator in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(narrator.name)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    
                                    if !narrator.birthInfo.isEmpty {
                                        Text("Birth: \(narrator.birthInfo)")
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    }
                                    
                                    if !narrator.deathInfo.isEmpty {
                                        Text("Death: \(narrator.deathInfo)")
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
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
        .navigationTitle("Chain of Narration")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadChain)
    }
    
    private func loadChain() {
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }
        
        do {
            let db = try Connection(dbPath)
            
            // Split the chain index into individual scholar indices
            let scholarIndices = chainIndx.split(separator: ",").map { String($0) }
            
            // Query narrator information for each scholar index
            var narratorsInfo: [Narrator] = []
            
            for scholarIdx in scholarIndices {
                let narratorQuery = "SELECT name, birth_date_place, death_date_place FROM narrators WHERE scholar_indx = ?"
                let statement = try db.prepare(narratorQuery) // Prepare the statement
                
                // Bind the scholar index
                for row in try statement.bind(scholarIdx.trimmingCharacters(in: .whitespaces)) {
                    let narrator = Narrator(
                        name: row[0] as? String ?? "",
                        birthInfo: row[1] as? String ?? "",
                        deathInfo: row[2] as? String ?? ""
                    )
                    narratorsInfo.append(narrator)
                }
            }
            
            DispatchQueue.main.async {
                self.narrators = narratorsInfo
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading chain: \(error.localizedDescription)"
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}


//#Preview {
//    NavigationView {
//        ChainView(bookName: " Sahih Bukhari ", hadithID: "0", chainIndx: "30418, 20005, 11062, 11213, 11042, 3") // Example chain index
//    }
//}

#Preview {
    ChainView(bookName: " Sahih Bukhari ", hadithID: "0", chainIndx: "30418, 20005, 11062, 11213, 11042, 3")
}
