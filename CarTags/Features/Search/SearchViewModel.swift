//
//  SearchViewModel.swift
//  CarTags
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchCode = ""
    var results: [RegionResult] = []
    var isLoading = false
    var hasSearched = false
    var errorMessage: String?
    var showPaywall = false
    var showRestrictedResult = false

    func search() {
        let trimmed = searchCode.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        hasSearched = true
        errorMessage = nil

        Task {
            do {
                let allFound = try DatabaseService.shared.searchByCode(trimmed.uppercased(), language: LanguageService.shared.language)
                var found = allFound

                if !StoreService.shared.isPremium {
                    let inSelectedCountries = allFound.filter {
                        StoreService.shared.selectedCountries.contains($0.countryCode)
                    }
                    if !allFound.isEmpty && inSelectedCountries.isEmpty {
                        showRestrictedResult = true
                        isLoading = false
                        return
                    }
                    if StoreService.shared.requestsToday >= StoreService.maxFreeRequestsPerDay {
                        showRestrictedResult = true
                        isLoading = false
                        return
                    }
                    found = inSelectedCountries
                }

                StoreService.shared.recordRequest()
                results = found
            } catch {
                errorMessage = error.localizedDescription
                results = []
            }

            isLoading = false
        }
    }

    func clear() {
        searchCode = ""
        results = []
        hasSearched = false
        errorMessage = nil
        showRestrictedResult = false
    }
}
