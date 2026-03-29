//
//  StoreService.swift
//  CarTags
//

import Foundation
import Observation
import StoreKit

@Observable
final class StoreService {
    static let shared = StoreService()

    static let lifetimeID = "com.cartags.lifetime"

    static let maxFreeCountries = 3
    static let maxFreeRequestsPerDay = 500

    private let defaults = UserDefaults.standard

    var isPremium: Bool = false
    var selectedCountries: [String] = []
    private(set) var requestsToday: Int = 0

    private init() {
        loadSelectedCountries()
        refreshRequestsToday()
    }

    func canSearch(countryCode: String) -> Bool {
        if isPremium { return true }
        return selectedCountries.contains(countryCode)
            && requestsToday < StoreService.maxFreeRequestsPerDay
    }

    func recordRequest() {
        let today = currentDateString()
        let storedDate = defaults.string(forKey: "requests_date") ?? ""
        if storedDate != today {
            defaults.set(today, forKey: "requests_date")
            defaults.set(1, forKey: "requests_count")
            requestsToday = 1
        } else {
            let newCount = requestsToday + 1
            defaults.set(newCount, forKey: "requests_count")
            requestsToday = newCount
        }
    }

    func addCountry(_ code: String) {
        guard !selectedCountries.contains(code),
            selectedCountries.count < StoreService.maxFreeCountries
        else { return }
        selectedCountries.append(code)
        saveCountries()
    }

    func removeCountry(_ code: String) {
        selectedCountries.removeAll { $0 == code }
        saveCountries()
    }

    func purchase(_ productID: String) async throws {
        let products = try await Product.products(for: [productID])
        guard let product = products.first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified = verification else { return }
            await checkEntitlements()
        default:
            break
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await checkEntitlements()
    }

    @MainActor
    func checkEntitlements() async {
        var hasPremium = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == StoreService.lifetimeID {
                hasPremium = true
            }
        }
        isPremium = hasPremium
    }

    private func saveCountries() {
        guard let data = try? JSONEncoder().encode(selectedCountries) else { return }
        defaults.set(data, forKey: "selected_countries")
    }

    private func loadSelectedCountries() {
        guard let data = defaults.data(forKey: "selected_countries"),
            let decoded = try? JSONDecoder().decode([String].self, from: data)
        else {
            selectedCountries = []
            return
        }
        selectedCountries = decoded
    }

    private func refreshRequestsToday() {
        let today = currentDateString()
        let storedDate = defaults.string(forKey: "requests_date") ?? ""
        requestsToday = storedDate == today ? defaults.integer(forKey: "requests_count") : 0
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func currentDateString() -> String {
        StoreService.dateFormatter.string(from: Date())
    }

}
