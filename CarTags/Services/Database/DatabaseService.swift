//
//  DatabaseService.swift
//  CarTags
//
//  Created by Vladyslav Kekukh on 28.03.26.
//

import GRDB
import Foundation

final class DatabaseService {
    static let shared = DatabaseService()
    private let db: DatabaseQueue

    private init() {
        guard let dbPath = Bundle.main.path(forResource: "cartags", ofType: "db") else {
            fatalError("cartags.db not found in bundle")
        }
        do {
            db = try DatabaseQueue(path: dbPath)
        } catch {
            fatalError("DB error: \(error)")
        }
    }

    func searchByCode(_ code: String, language: String = Locale.current.language.languageCode?.identifier ?? "en") throws -> [RegionResult] {
        try db.read { db in
            let sql = """
                SELECT r.plate_code AS code, t.value AS region_name,
                       c.code AS country_code, ct.value AS country_name,
                       r.latitude AS lat, r.longitude AS lon
                FROM regions r
                JOIN translations t ON t.entity_type = 'region' AND t.entity_id = r.id AND t.language_code = ? AND t.field = 'name'
                JOIN countries c ON c.id = r.country_id
                JOIN translations ct ON ct.entity_type = 'country' AND ct.entity_id = c.id AND ct.language_code = ? AND ct.field = 'name'
                WHERE UPPER(r.plate_code) = UPPER(?)
            """
            return try RegionResult.fetchAll(db, sql: sql, arguments: [language, language, code])
        }
    }

    func fetchCountries(language: String = Locale.current.language.languageCode?.identifier ?? "en") throws -> [CountryItem] {
        try db.read { db in
            let sql = """
                SELECT c.id, c.code, t.value AS name
                FROM countries c
                JOIN translations t ON t.entity_type = 'country' AND t.entity_id = c.id AND t.language_code = ? AND t.field = 'name'
                ORDER BY t.value
            """
            return try CountryItem.fetchAll(db, sql: sql, arguments: [language])
        }
    }

    func fetchRegions(countryId: Int64, language: String = Locale.current.language.languageCode?.identifier ?? "en") throws -> [RegionResult] {
        try db.read { db in
            let sql = """
                SELECT r.plate_code AS code, t.value AS region_name,
                       c.code AS country_code, ct.value AS country_name,
                       r.latitude AS lat, r.longitude AS lon
                FROM regions r
                JOIN translations t ON t.entity_type = 'region' AND t.entity_id = r.id AND t.language_code = ? AND t.field = 'name'
                JOIN countries c ON c.id = r.country_id
                JOIN translations ct ON ct.entity_type = 'country' AND ct.entity_id = c.id AND ct.language_code = ? AND ct.field = 'name'
                WHERE r.country_id = ?
                ORDER BY r.plate_code
            """
            return try RegionResult.fetchAll(db, sql: sql, arguments: [language, language, countryId])
        }
    }
}
