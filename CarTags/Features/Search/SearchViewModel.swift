//
//  SearchViewModel.swift
//  CarTags
//

import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var searchCode = ""
    var results: [RegionResult] = []
    var isLoading = false
    var hasSearched = false
    var errorMessage: String?
    var showPaywall = false
    var showRestrictedResult = false

    private var searchTask: Task<Void, Never>?

    func search() {
        let trimmed = searchCode.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            if hasSearched { clear() }
            return
        }

        isLoading = true
        hasSearched = true
        errorMessage = nil
        showRestrictedResult = false

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let code = trimmed.uppercased()
                let lang = LanguageService.shared.language
                let allFound = try DatabaseService.shared.searchByCode(code, language: lang)

                guard !Task.isCancelled else { return }

                let store = StoreService.shared
                var found = allFound

                if !store.isPremium {
                    let inSelected = allFound.filter {
                        store.selectedCountries.contains($0.countryCode)
                    }
                    if !allFound.isEmpty && inSelected.isEmpty {
                        self.showRestrictedResult = true
                        self.isLoading = false
                        return
                    }
                    if store.requestsToday >= StoreService.maxFreeRequestsPerDay {
                        self.showRestrictedResult = true
                        self.isLoading = false
                        return
                    }
                    found = inSelected
                }

                if !found.isEmpty {
                    store.recordRequest()
                }

                self.results = found
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
                self.results = []
                self.isLoading = false
            }
        }
    }

    func clear() {
        searchTask?.cancel()
        searchCode = ""
        results = []
        hasSearched = false
        errorMessage = nil
        showRestrictedResult = false
    }
}
