//
//  RegionsViewModel.swift
//  CarTags
//

import Foundation
import Observation

@Observable
final class RegionsViewModel {
    var regions: [RegionResult] = []
    var errorMessage: String?
    let country: CountryItem

    init(country: CountryItem) {
        self.country = country
    }

    func loadRegions() {
        do {
            regions = try DatabaseService.shared.fetchRegions(countryId: country.id, language: LanguageService.shared.language)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
