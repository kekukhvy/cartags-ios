//
//  CountryPickerViewModel.swift
//  CarTags
//

import Foundation
import Observation

@Observable
final class CountryPickerViewModel {
    var countries: [CountryItem] = []
    var errorMessage: String?

    func loadCountries() {
        do {
            countries = try DatabaseService.shared.fetchCountries(language: LanguageService.shared.language)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
