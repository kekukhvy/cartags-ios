//
//  CountryPickerView.swift
//  CarTags
//

import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CountryPickerViewModel()
    @State private var showLimitAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.countries) { country in
                        CountryPickerRow(
                            country: country,
                            showLimitAlert: $showLimitAlert
                        )
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .navigationTitle(loc("countries.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc("button.done")) { dismiss() }
                }
            }
            .task { viewModel.loadCountries() }
            .alert(loc("error.title"), isPresented: $showLimitAlert) {
                Button(loc("button.ok")) {}
            } message: {
                Text(loc("countries.picker.limit"))
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
}

private struct CountryPickerRow: View {
    let country: CountryItem
    @Binding var showLimitAlert: Bool

    var body: some View {
        let isSelected = StoreService.shared.selectedCountries.contains(country.code)
        Button {
            if isSelected {
                StoreService.shared.removeCountry(country.code)
            } else if StoreService.shared.selectedCountries.count >= StoreService.maxFreeCountries {
                showLimitAlert = true
            } else {
                StoreService.shared.addCountry(country.code)
            }
        } label: {
            HStack {
                Text(flagEmoji(for: country.code))
                    .font(.title2)
                Text(country.name)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
