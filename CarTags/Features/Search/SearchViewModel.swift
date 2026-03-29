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
                    found = allFound.filter {
                        StoreService.shared.canSearch(countryCode: $0.countryCode)
                    }
                    if !allFound.isEmpty && found.isEmpty {
                        showRestrictedResult = true
                        isLoading = false
                        return
                    }
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
