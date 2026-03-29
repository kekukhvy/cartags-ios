//
//  RegionsView.swift
//  CarTags
//

import SwiftUI

struct RegionsView: View {
    @State private var viewModel: RegionsViewModel

    init(country: CountryItem) {
        _viewModel = State(initialValue: RegionsViewModel(country: country))
    }

    var body: some View {
        SwiftUI.List(viewModel.regions) { region in
            HStack {
                Text(flagEmoji(for: region.countryCode))
                    .font(.title2)
                Text(region.regionName)
                    .font(.body)
                Spacer()
                Text(region.code)
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(viewModel.country.name)
        .task { viewModel.loadRegions() }
        .alert(String(localized: "error.title"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(String(localized: "button.ok")) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
