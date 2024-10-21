//
//  HadithData.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import Foundation

struct Hadith: Identifiable, Codable{
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

//id,hadith_id,source,chapter_no,hadith_no,chapter,chain_indx,text_ar,text_en

struct Rawi: Identifiable, Codable{
    var id: Int // scholar_idx
    var name: String
    var grade: String
    //need to be arrays
    var parents: String // "/" is the delimiter
    var spouse: String // ,
    var siblings: String // ,
    var children: String // ,
    var birthDatePlace: String
    var placesOfStay: String
    var deathDatePlace: String
    var teachers: String // ,
    var students: String // ,
    var areaOfInterest: String // ,
    var tags: String
    var books: String
    var studentsInds: String // ,
    var teachersInds: String // ,
    var birthPlace: String
    var birthDate: String
    var birthDateHijri: Int?
    var birthDateGregorian: Int?
    var deathDateHijri: Int?
    var deathDateGregorian: Int?
    var deathPlace: String
    var deathReason: String
}

//scholar_indx,name,grade,parents,spouse,siblings,children,birth_date_place,places_of_stay,death_date_place,teachers,students,area_of_interest,tags,books,students_inds,teachers_inds,birth_place,birth_date,birth_date_hijri,birth_date_gregorian,death_date_hijri,death_date_gregorian,death_place,death_reason


func loadHadithsFromCSV() -> [Hadith] {
    var hadiths: [Hadith] = []
    
    guard let path = Bundle.main.path(forResource: "all_hadiths_clean", ofType: "csv") else {
        print("CSV file not found")
        return hadiths
    }
    
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let rows = content.components(separatedBy: .newlines)
        
        // Skip the first row (header)
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 9 {
                let hadith = Hadith(
                    id: Int(columns[0]) ?? 0,
                    hadithId: Int(columns[1]) ?? 0,
                    source: columns[2].trimmingCharacters(in: .whitespacesAndNewlines),
                    chapterNo: Int(columns[3]) ?? 0,
                    hadithNo: Int(columns[4]) ?? 0,
                    chapter: columns[5].trimmingCharacters(in: .whitespacesAndNewlines),
                    chainIndx: columns[6].components(separatedBy: " ").compactMap { Int($0) },
                    textAr: columns[7].trimmingCharacters(in: .whitespacesAndNewlines),
                    textEn: columns[8].trimmingCharacters(in: .whitespacesAndNewlines)
                )
                hadiths.append(hadith)
            }
        }
    } catch {
        print("Error reading CSV file: \(error)")
    }
    
    return hadiths
}

// Instead of calling loadHadithsFromCSV() at the top level,
// we'll create a computed property to store the hadiths
struct HadithStore {
    static var hadiths: [Hadith] = {
        let loadedHadiths = loadHadithsFromCSV()
        print("Number of hadiths loaded: \(loadedHadiths.count)")
        if let firstHadith = loadedHadiths.first {
            print("First hadith: \(firstHadith)")
        }
        return loadedHadiths
    }()
}

class RawiStore {
    static var rawis: [Rawi] = []
    
    static func loadRawis() {
        guard let url = Bundle.main.url(forResource: "all_rawis", withExtension: "csv") else {
            print("CSV file not found")
            return
        }
        
        do {
            let csvData = try String(contentsOf: url)
            let rows = csvData.components(separatedBy: .newlines)
            
            // Skip the header row
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
                    rawis.append(rawi)
                }
            }
            
            print("Loaded \(rawis.count) rawis")
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
}

// Test function
func testHadithLoading() {
    let hadiths = HadithStore.hadiths
    print("Number of hadiths loaded: \(hadiths.count)")
    
    if let firstHadith = hadiths.first {
        print("\nFirst hadith:")
        print("ID: \(firstHadith.id)")
        print("Hadith ID: \(firstHadith.hadithId)")
        print("Source: \(firstHadith.source)")
        print("Chapter: \(firstHadith.chapter)")
        print("Arabic text: \(firstHadith.textAr)")
        print("English text: \(firstHadith.textEn)")
    }
    
    if let lastHadith = hadiths.last {
        print("\nLast hadith:")
        print("ID: \(lastHadith.id)")
        print("Hadith ID: \(lastHadith.hadithId)")
        print("Source: \(lastHadith.source)")
        print("Chapter: \(lastHadith.chapter)")
    }
    
    // Load and test Rawis
    RawiStore.loadRawis()
    let rawis = RawiStore.rawis
    print("\nNumber of rawis loaded: \(rawis.count)")
    
    if let firstRawi = rawis.first {
        print("\nFirst rawi:")
        print("ID: \(firstRawi.id)")
        print("Name: \(firstRawi.name)")
        print("Grade: \(firstRawi.grade)")
        print("Birth Date/Place: \(firstRawi.birthDatePlace)")
        print("Death Date/Place: \(firstRawi.deathDatePlace)")
    }
    
    if let lastRawi = rawis.last {
        print("\nLast rawi:")
        print("ID: \(lastRawi.id)")
        print("Name: \(lastRawi.name)")
        print("Grade: \(lastRawi.grade)")
        print("Birth Date/Place: \(lastRawi.birthDatePlace)")
        print("Death Date/Place: \(lastRawi.deathDatePlace)")
    }
}
