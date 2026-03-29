//
//  CarTagsApp.swift
//  CarTags
//

import SwiftUI

@main
struct CarTagsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await StoreService.shared.checkEntitlements()
                }
        }
    }
}
