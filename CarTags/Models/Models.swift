//
//  Models.swift
//  CarTags
//
//  Created by Vladyslav Kekukh on 28.03.26.
//

import GRDB

struct RegionResult: FetchableRecord, Identifiable {
    var id: String { "\(code)_\(countryCode)" }
    let code: String
    let regionName: String
    let countryCode: String
    let countryName: String
    let lat: Double?
    let lon: Double?

    init(row: Row) {
        code = row["code"]
        regionName = row["region_name"]
        countryCode = row["country_code"]
        countryName = row["country_name"]
        lat = row["lat"]
        lon = row["lon"]
    }
}

struct CountryItem: FetchableRecord, Identifiable {
    let id: Int64
    let code: String
    let name: String

    init(row: Row) {
        id = row["id"]
        code = row["code"]
        name = row["name"]
    }
}
