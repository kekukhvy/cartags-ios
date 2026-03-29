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

        hasSearched = true
        errorMessage = nil
        showRestrictedResult = false

        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            isLoading = true

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
                        showRestrictedResult = true
                        isLoading = false
                        return
                    }
                    if store.requestsToday >= StoreService.maxFreeRequestsPerDay {
                        showRestrictedResult = true
                        isLoading = false
                        return
                    }
                    found = inSelected
                }

                if !found.isEmpty {
                    store.recordRequest()
                }

                results = found
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                results = []
                isLoading = false
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
