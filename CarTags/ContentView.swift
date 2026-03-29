//
//  ContentView.swift
//  CarTags
//

import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
