//
//  CarTagsApp.swift
//  CarTags
//

import SwiftUI

@main
struct CarTagsApp: App {
    @State private var languageService = LanguageService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageService.language)
                .task {
                    await StoreService.shared.checkEntitlements()
                }
        }
    }
}
