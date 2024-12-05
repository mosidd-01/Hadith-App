//
//  NarratorView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 12/3/24.
//

import SwiftUI
import SQLite

struct NarratorDetail {
    let scholarIndex: String
    let name: String
    let grade: String
    let parents: String
    let spouse: String
    let siblings: String
    let children: String
    let birthDatePlace: String
    let placesOfStay: String
    let deathDatePlace: String
    let areaOfInterest: String
    let teachers: String
    let students: String
}

struct NarratorView: SwiftUI.View {
    let scholarIndex: String
    
    @State private var narrator: NarratorDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some SwiftUI.View {
        ZStack {
            Color(red: 40/255, green: 40/255, blue: 40/255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading narrator details...")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
            } else if let narrator = narrator {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            if !narrator.name.isEmpty {
                                Text("Name")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.name)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.grade.isEmpty {
                                Text("Grade")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.grade)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.parents.isEmpty {
                                Text("Parents")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.parents)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.spouse.isEmpty {
                                Text("Spouse")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.spouse)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.siblings.isEmpty {
                                Text("Siblings")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.siblings)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.children.isEmpty {
                                Text("Children")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.children)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.birthDatePlace.isEmpty {
                                Text("Birth")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.birthDatePlace)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.placesOfStay.isEmpty {
                                Text("Places of Stay")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.placesOfStay)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.deathDatePlace.isEmpty {
                                Text("Death")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.deathDatePlace)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.areaOfInterest.isEmpty {
                                Text("Area of Interest")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.areaOfInterest)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.teachers.isEmpty {
                                Text("Teachers")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.teachers)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                            }
                            if !narrator.students.isEmpty {
                                Text("Students")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
                                Text(narrator.students)
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
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Narrator Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadNarratorDetails)
    }
    
    private func loadNarratorDetails() {
        print("Starting to load narrator details for scholar index: '\(scholarIndex)'")
        
        guard let dbPath = Bundle.main.path(forResource: "source", ofType: "db") else {
            print("Database file not found")
            self.errorMessage = "Database file not found."
            self.isLoading = false
            return
        }
        
        do {
            let db = try Connection(dbPath)
            
            let narratorQuery = """
                SELECT 
                    scholar_indx,
                    name,
                    grade,
                    parents,
                    spouse,
                    siblings,
                    children,
                    birth_date_place,
                    places_of_stay,
                    death_date_place,
                    area_of_interest,
                    teachers,
                    students
                FROM narrators 
                WHERE scholar_indx = ?
            """
            
            let statement = try db.prepare(narratorQuery)
            
            for row in try statement.bind(scholarIndex.trimmingCharacters(in: .whitespaces)) {
                print("Found narrator with index: \(scholarIndex)")
                
                let narratorDetail = NarratorDetail(
                    scholarIndex: row[0] as? String ?? "",
                    name: row[1] as? String ?? "",
                    grade: row[2] as? String ?? "",
                    parents: row[3] as? String ?? "",
                    spouse: row[4] as? String ?? "",
                    siblings: row[5] as? String ?? "",
                    children: row[6] as? String ?? "",
                    birthDatePlace: row[7] as? String ?? "",
                    placesOfStay: row[8] as? String ?? "",
                    deathDatePlace: row[9] as? String ?? "",
                    areaOfInterest: row[10] as? String ?? "",
                    teachers: row[11] as? String ?? "",
                    students: row[12] as? String ?? ""
                )
                
                DispatchQueue.main.async {
                    self.narrator = narratorDetail
                    self.isLoading = false
                }
                return
            }
            
            print("No narrator found for scholar index: '\(scholarIndex)'")
            DispatchQueue.main.async {
                self.errorMessage = "No narrator found"
                self.isLoading = false
            }
            
        } catch {
            print("Error occurred: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Error loading narrator: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}


#Preview {
    NarratorView(scholarIndex: "3")
}
