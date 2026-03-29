//
//  SearchView.swift
//  CarTags
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showCountryPicker = false
    @State private var selectedRegion: RegionResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                resultsList
            }
            .navigationTitle(loc("search.title"))
            .alert(loc("error.title"), isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button(loc("button.ok")) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showCountryPicker) {
                CountryPickerView()
            }
            .sheet(item: $selectedRegion) { region in
                RegionMapView(region: region)
            }
            .onAppear {
                if StoreService.shared.selectedCountries.isEmpty && !StoreService.shared.isPremium {
                    showCountryPicker = true
                }
            }
            .onChange(of: viewModel.searchCode) {
                viewModel.search()
            }
        }
    }

    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                }

                TextField(loc("search.placeholder"), text: $viewModel.searchCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.search() }

                if !viewModel.searchCode.isEmpty {
                    Button { viewModel.clear() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))

            Text(loc("search.latin_notice"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
        }
        .padding()
    }

    @ViewBuilder
    private var resultsList: some View {
        if viewModel.showRestrictedResult {
            restrictedState
        } else if viewModel.hasSearched && viewModel.results.isEmpty && !viewModel.isLoading {
            emptyState
        } else if !viewModel.hasSearched {
            placeholderState
        } else {
            List(viewModel.results) { region in
                RegionRow(region: region)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedRegion = region }
            }
            .listStyle(.plain)
        }
    }

    private var restrictedState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "lock.circle")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(loc("search.restricted.title"))
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(loc("search.restricted.message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(loc("search.restricted.subscribe")) {
                viewModel.showPaywall = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(String(format: loc("search.no_results %@"), viewModel.searchCode))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var placeholderState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "car.rear.road.lane")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(loc("search.empty_prompt"))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

struct RegionRow: View {
    let region: RegionResult

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(flagEmoji(for: region.countryCode))
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 4) {
                Text(region.code)
                    .font(.title2.bold())
                Text(region.regionName)
                    .font(.body)
                Text(region.countryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if region.lat != nil {
                Image(systemName: "map")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
