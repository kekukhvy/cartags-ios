#if DEBUG
//
//  DebugView.swift
//  CarTags
//

import SwiftUI

struct DebugView: View {
    @State private var isPremium = UserDefaults.standard.bool(forKey: "debug_premium")

    private let store = StoreService.shared
    private let defaults = UserDefaults.standard

    var body: some View {
        NavigationStack {
            List {
                Section("Subscription") {
                    Toggle("Premium enabled", isOn: $isPremium)
                        .onChange(of: isPremium) { _, newValue in
                            defaults.set(newValue, forKey: "debug_premium")
                            store.isPremium = newValue
                        }
                }

                Section("Usage") {
                    Button("Reset daily counter") {
                        defaults.removeObject(forKey: "requests_date")
                        defaults.removeObject(forKey: "requests_count")
                        store.refreshRequestsTodayDebug()
                    }

                    Button("Trigger paywall") {
                        store.setRequestsTodayDebug(999)
                    }
                }

                Section("Settings") {
                    Button("Reset selected countries", role: .destructive) {
                        defaults.removeObject(forKey: "selected_countries")
                        store.resetSelectedCountriesDebug()
                    }
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
