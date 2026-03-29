#if DEBUG
//
//  StoreServiceMock.swift
//  CarTags
//

import Foundation

final class StoreServiceMock {
    static let shared = StoreServiceMock()

    private let defaults = UserDefaults.standard

    var isPremium: Bool {
        get { defaults.bool(forKey: "debug_premium") }
        set { defaults.set(newValue, forKey: "debug_premium") }
    }

    private init() {}

    func purchase(_ productID: String) async throws {
        defaults.set(true, forKey: "debug_premium")
    }

    func restorePurchases() async throws {
        _ = defaults.bool(forKey: "debug_premium")
    }
}
#endif
