//
//  SettingsView.swift
//  CarTags
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    @State private var languageService = LanguageService.shared
    @State private var storeService = StoreService.shared
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var showTerms = false

    private let languages: [(code: String, label: String, flag: String)] = [
        ("en", "English", "🇬🇧"),
        ("de", "Deutsch", "🇩🇪"),
        ("ru", "Русский", "🇷🇺"),
        ("uk", "Українська", "🇺🇦"),
    ]

    private let appStoreURL = URL(string: "https://apps.apple.com/app/id0000000000")!
    private let feedbackURL = URL(string: "mailto:services.vk@icloud.com")!

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

                Section {
                    Button {
                        Task {
                            isRestoring = true
                            do {
                                try await storeService.restorePurchases()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                            isRestoring = false
                        }
                    } label: {
                        Label(
                            loc("settings.restore_purchases"),
                            systemImage: "arrow.counterclockwise.circle")
                    }
                    .disabled(isRestoring)

                    Button {
                        UIApplication.shared.open(feedbackURL)
                    } label: {
                        Label(loc("settings.feedback"), systemImage: "message")
                    }

                    Button {
                        UIApplication.shared.open(appStoreURL)
                    } label: {
                        Label(loc("settings.rate"), systemImage: "heart")
                    }

                    ShareLink(item: appStoreURL) {
                        Label(loc("settings.share"), systemImage: "square.and.arrow.up")
                    }
                }

                Section {
                    Button {
                        showTerms = true
                    } label: {
                        Label(loc("settings.terms"), systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(loc("settings.title"))
            .alert(loc("error.title"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button(loc("button.ok")) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $showTerms) {
                TermsView()
            }
        }
    }
}