//
//  BrowseViewModel.swift
//  CarTags
//

import Foundation
import Observation

@Observable
final class BrowseViewModel {
    var countries: [CountryItem] = []
    var errorMessage: String?

    func loadCountries() {
        do {
            let all = try DatabaseService.shared.fetchCountries()
            if StoreService.shared.isPremium {
                countries = all
            } else {
                let selected = StoreService.shared.selectedCountries
                countries = all.filter { selected.contains($0.code) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
