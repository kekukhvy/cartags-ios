//
//  CarTagsApp.swift
//  CarTags
//

import SwiftUI

@main
struct CarTagsApp: App {
    @State private var languageService = LanguageService.shared
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isReady {
                    ContentView()
                        .id(languageService.language)
                } else {
                    LaunchLoadingView()
                }
            }
            .task {
                await withCheckedContinuation { continuation in
                    DispatchQueue.global(qos: .userInitiated).async {
                        _ = DatabaseService.shared
                        continuation.resume()
                    }
                }
                await StoreService.shared.checkEntitlements()
                isReady = true
            }
        }
    }
}

private struct LaunchLoadingView: View {
    @State private var fillAmount: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "car.rear.road.lane")
                .font(.system(size: 60))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.3)],
                        startPoint: .bottom,
                        endPoint: UnitPoint(x: 0.5, y: 1.0 - fillAmount)
                    )
                )
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: fillAmount)
            ProgressView()
        }
        .onAppear { fillAmount = 1.0 }
    }
}
