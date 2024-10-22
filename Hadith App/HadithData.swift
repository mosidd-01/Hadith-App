//
//  HadithData.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import Foundation
import SwiftUI

struct Hadith: Identifiable, Codable {
    var id: Int
    var hadithId: Int
    var source: String
    var chapterNo: Int
    var hadithNo: Int
    var chapter: String
    var chainIndx: [Int]
    var textAr: String
    var textEn: String
}

struct Rawi: Identifiable, Codable {
    var id: Int
    var name: String
    var grade: String
    var parents: String
    var spouse: String
    var siblings: String
    var children: String
    var birthDatePlace: String
    var placesOfStay: String
    var deathDatePlace: String
    var teachers: String
    var students: String
    var areaOfInterest: String
    var tags: String
    var books: String
    var studentsInds: String
    var teachersInds: String
    var birthPlace: String
    var birthDate: String
    var birthDateHijri: Int?
    var birthDateGregorian: Int?
    var deathDateHijri: Int?
    var deathDateGregorian: Int?
    var deathPlace: String
    var deathReason: String
}

func loadHadithsFromCSV() -> [Hadith] {
    var hadiths: [Hadith] = []
    guard let path = Bundle.main.path(forResource: "all_hadiths_clean", ofType: "csv") else {
        print("CSV file not found")
        return hadiths
    }
    
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let rows = content.components(separatedBy: .newlines)
        for row in rows.dropFirst() {
            // Split on commas, but handle quoted strings
            var columns: [String] = []
            var currentColumn = ""
            var insideQuotes = false
            
            for char in row {
                if char == "\"" {
                    insideQuotes.toggle()
                } else if char == "," && !insideQuotes {
                    columns.append(currentColumn.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentColumn = ""
                } else {
                    currentColumn.append(char)
                }
            }
            // Add the last column
            columns.append(currentColumn.trimmingCharacters(in: .whitespacesAndNewlines))

            if columns.count >= 9 {
                let chainIndices = columns[6].components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                let hadith = Hadith(
                    id: Int(columns[0]) ?? 0,
                    hadithId: Int(columns[1]) ?? 0,
                    source: columns[2],
                    chapterNo: Int(columns[3]) ?? 0,
                    hadithNo: Int(columns[4]) ?? 0,
                    chapter: columns[5],
                    chainIndx: chainIndices,
                    textAr: columns[7],
                    textEn: columns[8]
                )
                hadiths.append(hadith)
            }
        }
    } catch {
        print("Error reading CSV file: \(error)")
    }
    return hadiths
}


struct HadithStore {
    static var hadiths: [Hadith] = {
        let loadedHadiths = loadHadithsFromCSV()
        print("Number of hadiths loaded: \(loadedHadiths.count)")
        return loadedHadiths
    }()
}

class DataStore: ObservableObject {
    @Published var hadiths: [Hadith] = []
    @Published var rawis: [Rawi] = []
    
    init() {
        loadData()
    }
    
    private func loadData() {
        DispatchQueue.global(qos: .background).async {
            self.loadHadiths()
            self.loadRawis()
        }
    }
    
    private func loadHadiths() {
        DispatchQueue.main.async {
            self.hadiths = HadithStore.hadiths
        }
    }
    
    func loadRawis() {
        guard let url = Bundle.main.url(forResource: "all_rawis", withExtension: "csv") else {
            print("CSV file not found")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let csvData = try String(contentsOf: url)
                let rows = csvData.components(separatedBy: .newlines)
                
                var loadedRawis: [Rawi] = []
                
                for row in rows.dropFirst() {
                    let columns = row.components(separatedBy: ",")
                    if columns.count >= 25 {
                        let rawi = Rawi(
                            id: Int(columns[0]) ?? 0,
                            name: columns[1],
                            grade: columns[2],
                            parents: columns[3],
                            spouse: columns[4],
                            siblings: columns[5],
                            children: columns[6],
                            birthDatePlace: columns[7],
                            placesOfStay: columns[8],
                            deathDatePlace: columns[9],
                            teachers: columns[10],
                            students: columns[11],
                            areaOfInterest: columns[12],
                            tags: columns[13],
                            books: columns[14],
                            studentsInds: columns[15],
                            teachersInds: columns[16],
                            birthPlace: columns[17],
                            birthDate: columns[18],
                            birthDateHijri: Int(columns[19]),
                            birthDateGregorian: Int(columns[20]),
                            deathDateHijri: Int(columns[21]),
                            deathDateGregorian: Int(columns[22]),
                            deathPlace: columns[23],
                            deathReason: columns[24]
                        )
                        loadedRawis.append(rawi)
                    }
                }
                
                DispatchQueue.main.async {
                    self.rawis = loadedRawis
                    print("Loaded \(self.rawis.count) rawis")
                }
            } catch {
                print("Error reading CSV file: \(error)")
            }
        }
    }
}

