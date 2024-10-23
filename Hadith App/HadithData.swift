//
//  HadithData.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import Foundation
import SwiftUI
import SQLite

struct Hadith: Identifiable, Codable {
    var id: String
    var hadithId: String
    var source: String
    var chapterNo: String
    var hadithNo: String
    var chapter: String
    var chainIndx: String
    var textAr: String
    var textEn: String
}

struct Rawi: Identifiable, Codable {
    var id: String
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
    var birthDateHijri: String
    var birthDateGregorian: String
    var deathDateHijri: String
    var deathDateGregorian: String
    var deathPlace: String
    var deathReason: String
}

class DataStore: ObservableObject {
    @Published var hadiths: [Hadith] = []
    @Published var rawis: [Rawi] = []
    
    private var db: Connection?

    init() {
        loadData()
    }
    
    private func loadData() {
        do {
            let dbPath = Bundle.main.path(forResource: "source", ofType: "db")!
            db = try Connection(dbPath)
            DispatchQueue.global(qos: .background).async {
                self.loadHadiths()
                self.loadRawis()
            }
        } catch {
            print("Failed to connect to database: \(error)")
        }
    }
    
    private func loadHadiths() {
        print("Test_h")
        guard let db = db else { return }

        DispatchQueue.global(qos: .background).async {
            do {
                let hadithTable = Table("narrations")
//                let id = Expression<String>(value: "id")
//                let hadithId = Expression<String>(value: "hadith_id")
//                let source = Expression<String>(value: "source")
//                let chapterNo = Expression<Int>(value: "chapter_no")
                let hadithNo = Expression<Int>(value: "hadith_no")
//                let chapter = Expression<String>(value: "chapter")
//                let chainIndx = Expression<String>(value: "chain_indx")
//                let textAr = Expression<String>(value: "text_ar")
//                let textEn = Expression<String>(value: "text_en")
//
//                var loadedHadiths: [Hadith] = []
                let all = Array(try db.prepare(hadithTable.limit(2)))
                
                print(all)

                for hadith in try db.prepare(hadithTable) {
                    //print("hadith : \(try hadith.get(hadithNo))")
                    
//                    let newHadith = Hadith(
//                        id: hadith[id],
//                        hadithId: hadith[hadithId],
//                        source: hadith[source],
//                        chapterNo: hadith[chapterNo],
//                        hadithNo: hadith[hadithNo],
//                        chapter: hadith[chapter],
//                        chainIndx: hadith[chainIndx],
//                        textAr: hadith[textAr],
//                        textEn: hadith[textEn]
//                    )
//                    loadedHadiths.append(newHadith)
                }

//                DispatchQueue.main.async {
//                    self.hadiths = loadedHadiths
//                    print("Loaded \(loadedHadiths.count) hadiths")
//                }
            } catch {
                print("Error loading hadiths: \(error)")
            }
        }
    }
    
    func loadRawis() {
        print("Test_r")
        guard let db = db else { return }

        DispatchQueue.global(qos: .background).async {
            do {
                let rawiTable = Table("narrators")
                let id = Expression<String>(value: "scholar_indx")
                let name = Expression<String>(value: "name")
                let grade = Expression<String>(value: "grade")
                let parents = Expression<String>(value: "parents")
                let spouse = Expression<String>(value: "spouse")
                let siblings = Expression<String>(value: "siblings")
                let children = Expression<String>(value: "children")
                let birthDatePlace = Expression<String>(value: "birth_date_place")
                let placesOfStay = Expression<String>(value: "places_of_stay")
                let deathDatePlace = Expression<String>(value: "death_date_place")
                let teachers = Expression<String>(value: "teachers")
                let students = Expression<String>(value: "students")
                let areaOfInterest = Expression<String>(value: "area_of_interest")
                let tags = Expression<String>(value: "tags")
                let books = Expression<String>(value: "books")
                let studentsInds = Expression<String>(value: "students_inds")
                let teachersInds = Expression<String>(value: "teachers_inds")
                let birthPlace = Expression<String>(value: "birth_place")
                let birthDate = Expression<String>(value: "birth_date")
                let birthDateHijri = Expression<String>(value: "birth_date_hijri")
                let birthDateGregorian = Expression<String>(value: "birth_date_gregorian")
                let deathDateHijri = Expression<String>(value: "death_date_hijri")
                let deathDateGregorian = Expression<String>(value: "death_date_gregorian")
                let deathPlace = Expression<String>(value: "death_place")
                let deathReason = Expression<String>(value: "death_reason")

                var loadedRawis: [Rawi] = []

                for rawi in try db.prepare(rawiTable) {
                    let newRawi = Rawi(
                        id: rawi[id],
                        name: rawi[name],
                        grade: rawi[grade],
                        parents: rawi[parents],
                        spouse: rawi[spouse],
                        siblings: rawi[siblings],
                        children: rawi[children],
                        birthDatePlace: rawi[birthDatePlace],
                        placesOfStay: rawi[placesOfStay],
                        deathDatePlace: rawi[deathDatePlace],
                        teachers: rawi[teachers],
                        students: rawi[students],
                        areaOfInterest: rawi[areaOfInterest],
                        tags: rawi[tags],
                        books: rawi[books],
                        studentsInds: rawi[studentsInds],
                        teachersInds: rawi[teachersInds],
                        birthPlace: rawi[birthPlace],
                        birthDate: rawi[birthDate],
                        birthDateHijri: rawi[birthDateHijri],
                        birthDateGregorian: rawi[birthDateGregorian],
                        deathDateHijri: rawi[deathDateHijri],
                        deathDateGregorian: rawi[deathDateGregorian],
                        deathPlace: rawi[deathPlace],
                        deathReason: rawi[deathReason]
                    )
                    loadedRawis.append(newRawi)
                }

                DispatchQueue.main.async {
                    self.rawis = loadedRawis
                    print("Loaded \(loadedRawis.count) rawis")
                }
            } catch {
                print("Error loading rawis: \(error)")
            }
        }
    }
}
