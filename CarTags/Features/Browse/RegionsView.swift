//
//  RegionsView.swift
//  CarTags
//

import SwiftUI

struct RegionsView: View {
    @State private var viewModel: RegionsViewModel
    @State private var selectedRegion: RegionResult?

    init(country: CountryItem) {
        _viewModel = State(initialValue: RegionsViewModel(country: country))
    }

    var body: some View {
        List(viewModel.regions) { region in
            HStack {
                Text(flagEmoji(for: region.countryCode))
                    .font(.title2)
                Text(region.regionName)
                    .font(.body)
                Spacer()
                Text(region.code)
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
                if region.lat != nil {
                    Image(systemName: "map")
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if region.lat != nil {
                    selectedRegion = region
                }
            }
        }
        .navigationTitle(viewModel.country.name)
        .task { viewModel.loadRegions() }
        .sheet(item: $selectedRegion) { region in
            RegionMapView(region: region)
        }
        .alert(loc("error.title"), isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button(loc("button.ok")) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
