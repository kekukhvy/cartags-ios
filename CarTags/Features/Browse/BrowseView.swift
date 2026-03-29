//
//  BrowseView.swift
//  CarTags
//

import SwiftUI

struct BrowseView: View {
    @State private var viewModel = BrowseViewModel()
    @State private var showCountryPicker = false

    var body: some View {
        NavigationStack {
            SwiftUI.List(viewModel.countries) { country in
                NavigationLink(destination: RegionsView(country: country)) {
                    HStack {
                        Text(flagEmoji(for: country.code))
                            .font(.title2)
                        Text(country.name)
                    }
                }
            }
            .navigationTitle(String(localized: "browse.title"))
            .toolbar {
                if !StoreService.shared.isPremium {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showCountryPicker = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .task { viewModel.loadCountries() }
            .sheet(isPresented: $showCountryPicker, onDismiss: { viewModel.loadCountries() }) {
                CountryPickerView()
            }
            .alert(String(localized: "error.title"), isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(String(localized: "button.ok")) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
