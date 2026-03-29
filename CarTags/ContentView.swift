//
//  ContentView.swift
//  CarTags
//

import SwiftUI

struct ContentView: View {
    #if DEBUG
    @State private var showDebug = false
    #endif

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label(loc("search.title"), systemImage: "magnifyingglass")
                }
            BrowseView()
                .tabItem {
                    Label(loc("browse.title"), systemImage: "globe")
                }
            SettingsView()
                .tabItem {
                    Label(loc("settings.title"), systemImage: "gearshape")
                }
        }
        #if DEBUG
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 5)
                .onEnded { _ in showDebug = true }
        )
        .sheet(isPresented: $showDebug) {
            DebugView()
        }
        #endif
    }
}

#Preview {
    ContentView()
}
