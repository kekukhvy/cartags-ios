//
//  SettingsView.swift
//  CarTags
//

import SwiftUI

struct SettingsView: View {
    @State private var languageService = LanguageService.shared
    #if DEBUG
    @State private var isPremium = UserDefaults.standard.bool(forKey: "debug_premium")
    #endif

    private let languages: [(code: String, label: String, flag: String)] = [
        ("en", "English", "🇬🇧"),
        ("de", "Deutsch", "🇩🇪"),
        ("ru", "Русский", "🇷🇺"),
        ("uk", "Українська", "🇺🇦"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(loc("settings.language.section")) {
                    HStack(spacing: 16) {
                        ForEach(languages, id: \.code) { lang in
                            Button {
                                languageService.language = lang.code
                            } label: {
                                Text(lang.flag)
                                    .font(.system(size: 36))
                                    .opacity(languageService.language == lang.code ? 1.0 : 0.35)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                #if DEBUG
                Section("Debug") {
                    Toggle("Premium", isOn: $isPremium)
                        .onChange(of: isPremium) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "debug_premium")
                            StoreService.shared.isPremium = newValue
                        }
                }
                #endif
            }
            .navigationTitle(loc("settings.title"))
        }
    }
}
